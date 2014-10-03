function outimg = ml_3dbgsub(image)
% ml_3dbgsub substracts the most common pixel value of the image. 

% This method is an adaptation of ml_3dbgsub.c.

% Input: image, must be a 3D array

% Output: outimg, the output image, 3D array


% Author: Yue Yu (yuey1@andrew.cmu.edu)

% Created: June 18, 2012

%

% Copyright (C) 2006-2012 Lane Center for Computational Biology

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


NDims = size(size(image),2); % get the dimension of image
if NDims ~= 3
    error('image must be a 3D array')
end
if ~strcmp(class(image),'uint8')
    error('The argument to ml_3dbgsub() should be a 3D matrix of type uint8')
end

[Height,Width,Depth] = size(image);
n_voxels = Width * Height * Depth;


img = reshape(image,1,n_voxels);
MostCommonPixelValue = mode(img);
MostCommonPixelValue = MostCommonPixelValue(1,1); % find the most common pixel value in the image

outimg = image - MostCommonPixelValue;
outimg(outimg < 0) = 0;
