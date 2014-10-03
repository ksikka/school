function [diff_mat,std_mat]=ml_obj_compare_2D(features) 

% function [diff_mat,std_mat]=obj_compare_2D(features)
% features: object features
% diff_mat: differences between objects
% std_mat: standard deviation of the object features
 
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

% calculate the difference of the features in neighbor images
for pic = 2:length(features)  % pic: number of pictures
   prev_num=size(features{pic-1}, 1);
   curr_num=size(features{pic}, 1);   
   for i=1:prev_num   %i: number of objects in prev picture
    for j=1:curr_num  %j: number of objects in the current picture
        area_data{pic}(i,j)=features{pic}(j,1)-features{pic-1}(i,1);
        intensity_data{pic}(i,j)=features{pic}(j,2)-features{pic-1}(i,2);
        x_data{pic}(i,j)=features{pic}(j,3)-features{pic-1}(i,3);
        y_data{pic}(i,j)=features{pic}(j,4)-features{pic-1}(i,4);
         
     end
   end 
end

% calculate the std of the difference

x_com=[];
y_com=[];
intensity_com=[];
area_com=[];

for i=1:size(x_data(:),1)
 x_com=[x_com; x_data{i}(:)];
 y_com=[y_com; y_data{i}(:)];
 intensity_com=[intensity_com; intensity_data{i}(:)];
 area_com=[area_com; area_data{i}(:)];
end
 
x_std=nanstd(x_com(:));
y_std=nanstd(y_com(:));
intensity_std=nanstd(intensity_com(:));
area_std=nanstd(area_com(:));

std_mat = [area_std, intensity_std, x_std, y_std];

for pic = 2:size(x_data,2)
    diff_xcenter = x_data{pic}/x_std;
    diff_ycenter = y_data{pic}/y_std;
    diff_intensity = intensity_data{pic}/intensity_std;
    diff_area = area_data{pic}/area_std;
    diff_mat{pic}=(4*diff_xcenter.*diff_xcenter + 4*diff_ycenter.*diff_ycenter...
             + diff_intensity.*diff_intensity + diff_area.*diff_area).^0.5;
end

