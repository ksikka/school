function [diff_mat,features,std_mat]=ml_objfeatcmpr_2D(img_path,...
						  mask_name,cutoff,num_time)

% [diff_mat,features,std_mat]=ml_objfeatcmpr_2D
%                        (img_path, mask_name,cutoff)
% This function read time-series 2D images, extract objects from
% these images and make a distance matrix comparing objects in neighbor images.
% Input:
% img_path: is the full path of the time series images. It can
% contain a regular expression of image format in the directory.
% mask_name: the full path and file name of the mask
% cutoff: the maximum number of the objects
% Output: 
% diff: matrix to show the correclation between objects in adjacent pictures
% features: object features
% std_mat: standard deviation of object features

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

% Yanhua Hu, 2007
% Yanhua Hu, 2009

if ~exist('cutoff','var')
    cutoff = 0;
end

other_feature={};
center_feature={};
d = ml_dir(img_path);
d = d(1:num_time);
dir_name = fileparts(img_path);

if ~exist('cutoff','var')
    cutoff = 0;
end

%%%%%%%%%%%%%%%%

for i=1:num_time
   % Read in images, and preprocess each image individually, and
   % then stretch
   img =double(ml_loadimage2(dir_name,d{i}));
   if isempty(mask_name)
       mask_img = [];
   else
       mask_img = ml_readimage(mask_name);
   end
   
   [img, img_bin] = ml_preprocess(img, mask_img,'ml','yesbgsub','rc');
   img = ml_stretch95(img); % stretch 95 percentile to 256


   % Identify the objects in frequency domain
   % the objects are too small in this case
   % [img_marked,img_binary] = waveletobj_2D (img,3,2,1e-5); 
   img_marked=bwlabel(img_bin,8);  

   if max(img_marked(:))
       features{i}=...
           ml_obj_feature_2D(img, img_marked, cutoff); 
   else
       features{i}=[];
       
   end
end

display(['Features of ',num2str(num_time),' images, in ',dir_name, '/', d{i},' have been calculated']);

%Compare each object in current picture and next picture, get differeces 
%diff{current_pic}(current)(previous)
[diff_mat,std_mat]=ml_obj_compare_2D(features);