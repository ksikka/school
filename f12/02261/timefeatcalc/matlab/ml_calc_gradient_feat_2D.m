function [feat_vals_this,tnames] = ...
        ml_calc_gradient_feat_2D(img_curr,img_pre,...
			bins, countin,graylevel,noise_allowed)

% feat_vals_this = ml_calc_gradient_feat_2D(img_curr, img_pre,bins, ...
%			countin,graylevel,noise_allowed)
% Calculate gradient features
% img_curr: image at current time point
% img_pre: image at the previous time point
% bins: the graylevel for the directions of movement
% countin: pixels positions within mask
% graylevel: gray level
% noise_allowed: maximum speed allowed

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

if (isempty(img_curr) || isempty(img_pre))
    feat_vals_this =[];
    return;
end
        
[fx,fy]=gradient(img_curr);
It=img_curr-img_pre;
Un=-It./sqrt(fx.^2+fy.^2);
Un=abs(Un);
% allow the biggest Un to be noise_allowed And then
% rescale to graylevel
Un(find(Un==inf))=0; 
Un(find(isnan(Un)))=0;
Un = min(Un, noise_allowed);
m = max(Un(:));
Un = floor(Un*graylevel/m);

drt_map=zeros(size(Un));

for ii=1:length(countin)
    j=countin(ii); %only for the areas within the mask
    x=fx(j);
    y=fy(j);
    drt_map(j) = ml_calc_direction(x,y,bins);
end

mask_img =[]; % Un and drt_map has only values within mask, so mask
              % is not neccessary here. Since resizing was done
              % earlier (before calling this function) use 1 and 1
              % for scale and har_pix_size
[t1,feat_vals1,t2] = ml_features(Un,[], mask_img,[],{'har'}, ...
				 1, [],[],1, graylevel);
tnames1 = {};
for i = 1:length(t1)
    tnames1 = [tnames1,{[t1{i} '_Un']}];
end
    
[t3,feat_vals2,t4] = ml_features(drt_map,[], mask_img,[],{'har'}, ...
				 1, [],[],1,graylevel);      
tnames2 = {};
for i = 1:length(t3)
    tnames2 = [tnames2,{[t3{i} '_drt']}];
end

mean_Un = mean(Un(countin));
std_Un = std(Un(countin));

% new features Mar 16, 2007
h = hist(drt_map(countin),bins);
uniform_h = length(countin)/bins*ones(1,bins);
div_from_uniform = sum(abs(h-uniform_h));    

% new features Sept 24, 2006
uu = It.*fx./(fx.^2+fy.^2);
vv = It.*fy./(fx.^2+fy.^2);
div = divergence(uu, vv);
pos_div = mean(div(find(div>=0)));
neg_div= mean(div(find(div<=0)));
cur = curl(uu,vv);
pos_curl = mean(cur(find(cur>=0)));
neg_curl= mean(cur(find(cur<=0)));
feat_new = [pos_div, neg_div, pos_curl, neg_curl];

% for this pair of image
feat_vals_this = [feat_vals1,mean_Un,std_Un,mean_Un/std_Un, ...
		  feat_vals2, div_from_uniform, feat_new];
tnames = [tnames1,{'mean_Un','std_Un','mean_over_std_Un'},...
	      tnames2,{'div_from_uniform','pos_div','neg_div',...
		       'pos_curl','neg_curl'}];

if(sum(isnan(feat_vals_this)))
    feat_vals_this = []; 
end
