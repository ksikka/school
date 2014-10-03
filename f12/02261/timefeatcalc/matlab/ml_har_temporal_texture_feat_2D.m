function [feat,featnames] = ml_har_temporal_texture_feat_2D (img_path, ...
	mask_name,level,graylevel,scale,har_pixsize,cor_bleaching,num_time)

% [FEAT, FEATNAMES] = ML_HAR_TEMPORAL_TEXTURE_FEAT_2D(IMG_PATH,MASK_NAME,LEVEL,GRAYLEVEL,SCALE,HAR_PIXSIZE,COR_BLEACHING)
% ML_HAR_TEMPORAL_TEXTURE_FEAT_2D calculate 2D haralick temporal texture features
% IMG_PATH: is the full path of the time series images. It can
% contain a regular expression of image format in the directory.
% MASK_NAME: file name for the one mask of all the images in the movie
% LEVEL: how many different time intervals to consider
% GRAYLEVEL: gray level of the image
% SCALE: the real resolution of the image
% HAR_PIXSIZE: image will be rescaled to har_pixsize per pixel,
% COR_BLEACHING, correct photo bleaching, 1 for yes, 0 for no

%   Copyright (c) 2006 Murphy Lab
%   Carnegie Mellon University
%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published
%   by the Free Software Foundation; either version 2 of the License,
%   or (at your option) any later version.
%  
%   This program is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%  
%  Yanhua Hu, Dec 2005. 
%  Yanhua Hu, May 2009


har_rescale_factor = scale / har_pixsize;

tnames = {'angular_second_moment' 'contrast' 'correlation' 'sum_of_squares' 'inverse_diff_moment' 'sum_avg' 'sum_var' 'sum_entropy' 'entropy' 'diff_var' 'diff_entropy' 'info_measure_corr_1' 'info_measure_corr_2'};

d = ml_dir(img_path);
d = d(1:num_time);
dir_name = fileparts(img_path);
img_first = double(ml_readimage(fullfile(dir_name, d{1})));
if isempty(mask_name)
   mask_img = ones(size(img_first));
else
   mask_img = double(imread(mask_name));
end

clear img_first

feat = []; 
featnames = {};
img_all =[];

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

for k=1:level % different time interval
 feat_vals=[];
 for i=1:num_time
   if i+k<=num_time
      img1 = img_all(:,:,i);
      img2 = img_all(:,:,i+k);
    
      if (~isempty(img1) & ~isempty(img2))
         
         cocmat = ml_updtCOCMAT(img1,img2,[],graylevel);
     
         % make it sparse
         h=1;
         while h<size(cocmat,1)
           if sum(cocmat(h,:))==0
            cocmat(h,:)=[];
            cocmat(:,h)=[];
            h=h-1;
           end
           h=h+1;
         end

         cocmat=single(cocmat/sum(cocmat(:)));
         [row,col]=size(cocmat);
         if not(isempty(cocmat)|row==1|col==1)
           vals=ml_Har_Temporal_Texture(cocmat);
           vals=(vals(1:13))';
           feat_vals=[feat_vals;vals]; % for the same time interval
         else 
           warn=d{i}
         end
     end 
   end
 end

 if ~isempty(feat_vals)
  feat_valsize = size(feat_vals)
  feat_vals=double(feat_vals);
  feat_mean= mean(feat_vals,1);
  feat_var= var (feat_vals);
  feat = [feat,feat_mean,feat_var];
  for ii = 1:length(tnames)
       featnames = [featnames,{['mean_' tnames{ii} '_level' ...
			   num2str(k)]}];
  end
  for ii = 1:length(tnames) 
       featnames = [featnames,{['var_' tnames{ii} '_level' ...
			   num2str(k)]}];
  end
 end

end 
