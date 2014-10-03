function [featurename, feat_vals]  = ml_objmotionfeatures(trajec,scl,t)

%[featurename, feat_vals]  = ml_objmotionfeatures(trajec,scl,t)
% top level function to calcualte object tracking features 
% Calculate object tracking features from the trajectory of objects
% trajec: the trajectory of objects
% scl: the resolution of the image
% t : the time interval between images

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


[avg_velo, var_velo]= ml_velfeatures (trajec,scl,t);

[avg_spd, var_spd,avg_acc,var_acc,avg_dichange, var_dichange] = ...
    ml_speed_acc_dichange (trajec,scl,t);
featurename={'avg_velo', 'var_velo','avg_spd', 'var_spd',...
    'avg_acc','var_acc','avg_dichange', 'var_dichange'};
feat_vals=[avg_velo, var_velo, avg_spd, var_spd,avg_acc,var_acc,avg_dichange, var_dichange];
