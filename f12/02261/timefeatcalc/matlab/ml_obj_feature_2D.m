function [obj_feats]=ml_obj_feature_2D(img_ori, img_marked, cutoff)

% [obj_feats]=ml_obj_feature_2D(img_ori, img_marked, cutoff)
% img_ori is the original image 
% img_marked is the image marked objects by objects
% cutoff: the maximum number of objects to identify is less than 2*cutoff 
% obj_feats is a n*4 matrix and n is the number objects


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


num_objs = max(img_marked(:));
emptyobj_ind=[];
obj_feats = zeros(num_objs, 4);

for obj=1:num_objs %obj: the nth object in each picture
       
   % object feature 1: area
   % area=sum(obj_marked(:)); <- this old version is wrong
   area = length(find(img_marked==obj));
      
   % object feature 2:: total intensity
   intensity=sum(img_ori(find(img_marked==obj)));
     
   obj_feats(obj,1)=area;
   obj_feats(obj,2)=intensity;
 
end

% if there is no limitation of how many objects in an image 
if cutoff==0
    cutoff= 1000;  % set 1000 as the biggest number of objects
end

areas = obj_feats(:,1);
avg_intens = obj_feats(:,2)./obj_feats(:,1);

[areas_sorted, areas_idx]=sort(areas,1,'descend');
[avgi_sorted, avgi_idx]=sort(avg_intens,1,'descend');

cutoff_a = min(length(areas_idx),cutoff);
cutoff_i = min(length(avgi_idx),cutoff);

keep_area = areas_idx(1:cutoff_a);
keep_intens = avgi_idx(1:cutoff_i);
keeps = union(keep_area,keep_intens);


% to delete those not to keep
toDelete = setdiff(1:size(obj_feats,1), keeps);
obj_feats(toDelete, :)=[];


% And then for those to keep, find the COF, which takes time

for i=1:length(keeps) %obj: the nth object in each picture
   % extract each object, obj_marked, and obj_ori
   obj = keeps(i);
   obj_ori=img_ori; 
   obj_ori(find(img_marked~=obj))=0;

   % object feature 3: center
   [xcenter_obj, ycenter_obj]=ml_COFfinding_2D(obj_ori);
     
   obj_feats(i,3) = xcenter_obj;
   obj_feats(i,4) = ycenter_obj;
   
end
