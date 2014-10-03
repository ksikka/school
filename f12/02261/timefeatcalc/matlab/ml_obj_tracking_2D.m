function [obj_track,trajec,diff_mat, match_mat,std_mat, features] ...
	   = ml_obj_tracking_2D(img_path,mask_name,threshold,cutoff,num_time)

%[obj_track,trajec,diff_mat, match_mat,std_mat, features] ...
%	   = ml_obj_tracking_2D(img_path,mask_name,threshold,cutoff)
% This function takes a group of time-series images and return the track of all object
% Input: 
% img_dir: full path of the time series images. It can
% contain a regular expression of image format in the directory.
% mask_name: the file name of the mask that has been saved
% threshold: a threshold for distance. objects from different imges
%            can not match if their distance is larger than the
%            threshold. Default of the threshold is 4
% cutoff: the maximum number of objects to identify is less than 2*cutoff 
% Output: 
% obj_track: positions of each object in each image
% trajec: the trajectory of objects in each image
% diff_mat: difference matrix between pairs of objects
% match_mat: the matched object pairs
% std_mat: the standard deviation of object features
% features: object features

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

if (~exist('threshold'))
     threshold=4;
end
if (~exist('cutoff'))
     cutoff=500;
end

% Generate matrix showing the correlation between objects in adjacent pictures.

[diff_mat,features,std_mat]=ml_objfeatcmpr_2D(img_path,mask_name,cutoff,num_time);

if exist('std_mat','var')
    % match objects in adjacent pictures
    for i=2: size(diff_mat,2)
	if isempty(diff_mat{i})
	    match_mat{i}=[];
	else    
	    match_mat{i}=(ml_match_hungarian(diff_mat{i},threshold))';
	end
    end
    % Track the trajectories of objects
    [obj_track,trajec]=ml_center_track_2D(match_mat, features);
end
