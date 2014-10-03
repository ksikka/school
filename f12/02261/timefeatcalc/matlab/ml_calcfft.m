function [feat,featnames] = ml_calcfft(img_path,mask_name,fft_len, ...
				       scale, har_pixsize,cor_bleaching)
% feat = ml_calcfft(img_path,mask_name,fft_len, ...
%				       scale, har_pixsize)
% Top level function to calculate fft features
% IMG_PATH: is the full path of the time series images. It can
% contain a regular expression of image format in the directory.
% MASK_NAME: file name for the one mask of all the images in the movie
% FFT_LEN: number of time points to consider
% SCALE: the real resolution of the image
% HAR_PIXSIZE: image will be rescaled to har_pixsize per pixel,
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

% Yanhua Hu, 2007

har_rescale_factor = scale / har_pixsize;
d=ml_dir(img_path);
d = d(1:fft_len);
dir_name = fileparts(img_path);

img_first=double(ml_readimage([dir_name '/' d{1}]));
if isempty(mask_name)
   mask_img = ones(size(img_first));
else
   mask_img = double(imread(mask_name));
end

feat=[]; 
image_2Dt = []; 

for i = 1: fft_len
     img =double(ml_loadimage2(dir_name,d{i}));
     img = ml_preprocess(img,mask_img,'ml','yesbgsub', ...
			       'rc');
    
     if ~isempty(img)
	  img = imresize(img, har_rescale_factor, ...
			      'bilinear');
	  img = max(0, img);
      	  if cor_bleaching
	      img = ml_stretch95(img);
	  end
     end
     image_2Dt(:,:,i)=img;
end

[feat,featnames] = ml_fft(image_2Dt);
