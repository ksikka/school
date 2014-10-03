function [a,b,c,d] = ml_moments_1(image,labeled)
%ML_MOMENTS_1 Calculates the moments of the image. This method is an

%adaptation of ml_moments.c.

%

% input: image, original image, 2D matrix

%        labeled, labeled object image, 2D matrix

% output: a, moment00

%         b, moment10(X)

%         c, moment01(Y)

%         d, object sizes


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




if ~strcmp(class(image),'int32')
    error('Input IMAGE must be of class int32')
end
if ~strcmp(class(labeled),'int32')
    error('Input LABELLED IMAGE must be of class int32')
end

[yrows,xcols] = size(image);
moment_length = number_of_objects(labeled);

[a,b,c,d] = calc_moments(image,labels,xcols,yrows,moment_length);


function l = number_of_objects(label)
%Helper methods that returns the number of objects
l = max(label)+1;
l = l(1,1);

function [a,b,c,d] = calc_moments(image,labels,xcols,yrows,num_objs)
%Helper method that calculates the moments of the image
a = zeros(1,num_objs);
b = zeros(1,num_objs);
c = zeros(1,num_objs);
d = zeros(1,num_objs);

for i = 1 : xcols
    for j = 1 : yrows
        moment_index = labels(j,i);
        a(moment_index) = a(moment_index) + image(j,i);
        b(moment_index) = b(moment_index) + image(j,i)*(i+1);
        c(moment_index) = c(moment_index) + image(j,i)*(j+1);
        d(moment_index) = d(moment_index) + 1;
    end
end
