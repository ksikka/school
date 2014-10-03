function [average_velo, var_velo] = ml_velfeatures (trajec,scl,t)

% caculate velocity features from 
% trajec: traject{i} is [t,area, intens, x, y]
% scl: the resolution of the image
% t : the time interval 

%   Copyright (c) 2006 Murphy Lab
%   Carnegie Mellon University
%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published
%   by the Free Software Foundation; either version 2 of the License,
%   or (at your option) any later version.
%  
%   This program is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%  
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
%   02110-1301, USA.
%  
%   For additional information visit http://murphylab.web.cmu.edu or
%   send email to murphy@cmu.edu

%   Yanhua Hu

velo=[];
for i=1:length(trajec)
   curInfo = trajec{i};
   if not(isempty(curInfo))
     interval = size(curInfo,1)-1;
     
     distance =((curInfo(1,4)-curInfo(end,4))^2+(curInfo(1,5)-curInfo(end,5))^2)^0.5;
     
     curV= distance*scl/(interval*t);
     velo=[velo,curV];
   end  
end

average_velo=mean(velo);
var_velo=var(velo);