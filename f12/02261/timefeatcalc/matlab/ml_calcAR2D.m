function [feat_vals,feat_all,featnames] = ml_calcAR2D (img_path, ...
			mask_name, nmin, nmax, maxt)
% [feat_vals,feat_all] = ml_calcAR2D (img_path,...
%      mask_name, nmin, nmax,maxt) 
% Calculate Autoregression features
% img_path: is the full path of the time series images. It can
% contain a regular expression of image format in the directory.
% mask_name: the full path name of the mask
% nmin: the minimum number of time points to look back
% nmax: the maximum number of time points to look back
% maxt: the maximum number of time points to go through in total


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

% Yanhua Hu

if isempty(mask_name)
   crop = [];
else
   crop = double(mlimread(mask_name));
end
filenames = ml_dir(img_path);
filenames = filenames(1:maxt);
img_dir = fileparts(img_path);
feat_all =[];

for i = 1: length(filenames)
    img=double(ml_loadimage2(img_dir,filenames{i}));
    [feat_names, feat_vals, feat_slf] = ml_featset( img, ...
			crop,[],'mcell',0.11,0,'yesbgsub','rc');
    feat_all(i,:)=feat_vals;
end

feat_vals = []; 
feat_all(find(isnan(feat_all)))=0;
featnames = {};
for j = nmin:nmax
    feat_vals = [feat_vals ml_ar2dt(feat_all,j)];
    for k = 1:length(feat_slf)
	for l = 1:j
	    featnames = [featnames,{[feat_names{k},'_AR','_', ...
		    num2str(j), '_', num2str(l)]}];
	end
    end	
end
	      