function [x_center,y_center] = ml_COFfinding_2D(img)

% [X_CENTER, Y_CENTER] = ml_COFfinding_2D(IMG)
% Find the Center of Fluorescence (COF) of an image.

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

img_m00 = ml_imgmoments(img,0,0) ;
img_m01 = ml_imgmoments(img,0,1) ;
img_m10 = ml_imgmoments(img,1,0) ;
x_center = img_m10/img_m00;
y_center = img_m01/img_m00;
