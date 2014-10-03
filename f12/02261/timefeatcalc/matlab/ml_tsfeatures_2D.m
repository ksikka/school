function [feats,feats_names] = ml_tsfeatures_2D(img_path,mask_path,time_interval,featsets,scale,har_pixsize,graylevel,cor_bleaching,num_time)

% ML_TSFEATURES_2D Calculate time series features for 2D movies
% FEATS is the feature matrix
% ML_TSFEATURES_2D(IMG_PATH,MASK_PATH,TIME_INTERVAL,FEATSETS,SCALE,HAR_PIXSIZE,
% GRAYLEVEL,COR_BLEACHING)
% IMG_PATH is the full path of the time series images. It can
% contain a regular expression of image format in the directory.
% MASK_PATH is the full path of the mask image for the whole time series
% TIME_INTERVAL: time interval between images
% FEATSETS identifies the sets of features to be calculated.
% They are calculated in the order specified. 
%   har      - haralick temporal texture features
%   grad     - normal flow features
%   fft      - Fourier Transform features
%   tracking - Object tracking features
%   AR       - Autoregression features
% SCALE is the resolution (mircometers/pixel) 
% HAR_PIXSIZE: the resolution to be rescaled to
% GRAYLEVEL: gray level of the images, default is 255
% COR_BLEACHING: default is 1 for photobleaching correction, 0 otherwise

% Copyright (C) 2006  Murphy Lab
% Carnegie Mellon University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published
% by the Free Software Foundation; either version 2 of the License,
% or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.
%
% For additional information visit http://murphylab.web.cmu.edu or
% send email to murphy@cmu.edu

% By Yanhua Hu, July 2005. Code format follows the ml_features.m as
% the previous work in the lab.
% Parameters Modified on May 8, 09 by Yanhua Hu

% Check arguments & use defaults where necessary

DEFAULT_HAR_PIXEL_SIZE = 1.1;
DEFAULT_INTENSITY_BINS = 255;
DEFAULT_CORBLEACHING = 1;
LEVEL = 5;

if( ~exist('mask_path','var') | mask_path==0)
	mask_path = [];
end

if ~exist('har_pixsize', 'var')
     har_pixsize=DEFAULT_HAR_PIXEL_SIZE;
end

if ~exist('graylevel', 'var')
     graylevel=DEFAULT_INTENSITY_BINS;
end

if ~exist('cor_bleaching','var')
    cor_bleaching = DEFAULT_CORBLEACHING;
end
 
feats = [];
feats_names = {};
feat_vals = [];

for i = 1 : length( featsets)
  switch featsets{i}
   case 'har'
       [feat_vals,feat_names] = ml_har_temporal_texture_feat_2D ...
	   (img_path,mask_path,LEVEL,...
	    graylevel,scale,har_pixsize,cor_bleaching,num_time);
   case 'grad'
      [feat_vals,feat_names] = ml_gradienttext_2D(img_path, ...
		mask_path,LEVEL,graylevel,scale,har_pixsize,...
		cor_bleaching,num_time);
   case 'fft'
       [feat_vals,feat_names] = ml_calcfft(img_path,mask_path,...
			num_time,scale,har_pixsize,cor_bleaching);
   case 'tracking'
       threshold = 4;
       num_objs = 20;
       [obj_track,trajec,diff_mat, match_mat,std_mat,features] ...
	     = ml_obj_tracking_2D(img_path, mask_path, ...
				     threshold, num_objs, num_time);
       [feat_names, feat_vals]  = ...
		 ml_objmotionfeatures(trajec,scale,time_interval); ...

   case 'AR'
       nmin = 2;
       nmax = 4;
       [feat_vals,feat_all,feat_names] = ml_calcAR2D (img_path, ...
						 mask_path,nmin,nmax,num_time);
  end
  feats = [feats,feat_vals];
  feats_names = [feats_names,feat_names];
end
