function direction_map = ml_calc_direction(x,y,bins)

% direction_map = ml_calc_direction(x,y,bins)
% Calculate the direction of a vector from x and y
% direction_map is binned into certain number.

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

if ~exist('bins','var')
    bins = 8; 
end


if x==0 & y==0
    direction_map =0;
else
   

if x>0 & y>=0
    direction = atan(y/x);
elseif x<0 & y>=0
    direction = atan(y/x)+pi;
elseif x<0 & y<=0
    direction = atan(y/x)+pi;
elseif x>0 & y<=0
    direction =atan(y/x)+2*pi;
elseif x==0 & y>0
    direction = pi/2;
elseif x==0 & y<0
    direction =3/2*pi;
end
		
direction_map =floor(direction*bins/(2*pi))+1; %only 8 kinds of
                                               %direction 1:8
end