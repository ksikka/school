function [feat,featnames] = ml_gradienttext_2D(img_path,mask_name,...
				level,graylevel,scale,har_pixsize,...
			        cor_bleaching, num_time)
% [feat,featnames] = ml_gradienttext_2D(img_path,mask_name,
%                  level,graylevel,scale,har_pixsize,cor_bleaching)
% The top level function to calculate flow features
% IMG_PATH: is the full path of the time series images. It can
% contain a regular expression of image format in the directory.
% MASK_NAME: file name for the one mask of all the images in the movie
% LEVEL: how many different time intervals to consider
% GRAYLEVEL: gray level of the image
% SCALE: the real resolution of the image (micron/pixel)
% HAR_PIXSIZE: image will be rescaled to har_pixsize (micron/pixel)
% COR_BLEACHING, correct photo bleaching, 1 for yes, 0 for no
	
% Copyright (C) 2007  Murphy Lab
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

% Yanhua Hu, revised on Mar 16, 07
% Yanhua Hu, May, 09

d=ml_dir(img_path);
d = d(1:num_time);
dir_name = fileparts(img_path);

img_first=double(ml_readimage([dir_name '/' d{1}]));
if isempty(mask_name)
   mask_img = ones(size(img_first));
else
   mask_img = double(imread(mask_name));
end

noise_allowed=16;
bins = 8;  % graylevel in the direction map
har_rescale_factor = scale / har_pixsize;
resize_mask = imresize(mask_img,har_rescale_factor,'bilinear');
countin=find(resize_mask>0);  % indices of where the mask reside

feat = [];
featnames = {};
img_all = [];

for i = 1: num_time
     img_curr=double(ml_loadimage2(dir_name,d{i}));
     img_curr = ml_preprocess(img_curr,mask_img,'ml','yesbgsub', ...
			       'rc');
     if ~isempty(img_curr)
	  img_curr = imresize(img_curr, har_rescale_factor, ...
			      'bilinear');
	  img_curr = max(0, img_curr);
	  
     	  if cor_bleaching
	      img_curr = ml_stretch95(img_curr,graylevel);
	  else
	      img_curr = min(graylevel,orig_img*graylevel/255);
	      img_curr = floor(img_curr);
	  end
     end
     img_all(:,:,i)=img_curr;
end

clear mask_img;
clear img_first;

for i=1:level % different time interval
  feat_vals=[];
  for jj = 1:(num_time-i)
      img_curr= img_all(:,:,jj);     
      img_pre= img_all(:,:,jj+i);
      if (~isempty(img_curr) & ~isempty(img_pre))	 	  
	  [feat_vals_this,tnames] = ml_calc_gradient_feat_2D(img_curr, ...
	     img_pre,bins,countin,graylevel,noise_allowed);
	  % for same kind of time interval
	  feat_vals = [feat_vals; feat_vals_this]; 
      end
      
  end % for the certain time interval
  if isempty(feat_vals)
      % if not avaiblable, but 0 here. 34 is the length of the features
      feat_mean = zeros(1,34);
      feat_var = zeros(1,34);
  else 
      feat_mean= mean(feat_vals,1);
      feat_var= var(feat_vals,0,1);
  end  
  feat = [feat, feat_mean, feat_var];
  for ii = 1:length(tnames)
       featnames = [featnames,{['mean_' tnames{ii} '_level' ...
			   num2str(i)]}];
  end
  for ii = 1:length(tnames) 
       featnames = [featnames,{['var_' tnames{ii} '_level' ...
			   num2str(i)]}];
  end
end  %for all possible time interval
