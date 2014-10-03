function stretched = ml_stretch95(orig_img, graylevel)

% Streched the image intensity and so that 
% 95% percentile and above will be graylevel

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


if ~exist('graylevel','var')
    graylevel = 255;
end

pxl = orig_img(find(orig_img>0));      
p_95=prctile(pxl(:),95);
stretched = min(graylevel,orig_img*graylevel/p_95);
stretched = floor(stretched);
