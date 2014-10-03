function image = ml_loadimage2(imagedir, pattern, thresh)

% FUNCTION IMAGE = ML_LOADIMAGE2(IMAGEDIR, EXT, THRESH)
% @param imagedir: the directory where this class of images is stored
% @param ext: the extension of the image, tif default
% @param thresh: cutoff value.  Following rule will be used if not specified:
%        if a value is greater than 300 and greater than 1.5 * the next value
%        below it, the next value below it will be set as the thresh
%        -1 means no thresh needed.
% Load all the sections of images into a 3-D matrix

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


% changed from xc_loadimage, which can remove outlier pixels.  Y.H. 2007

if (~exist('thresh', 'var'))
     thresh = 0;
end
if (~exist('pattern', 'var'))
     ext = '*.tif';
end

imagenames = ml_dir(fullfile(imagedir,pattern));
fullpath = fullfile(imagedir, imagenames{1});
temp = ml_readimage(fullpath);
imagesize = size(temp);

image = repmat(uint16(0),imagesize, length(imagenames));
image(:,:,1) = temp;
u = unique(temp);
u = u';
for i = 2 : length(imagenames)
    fullpath = fullfile(imagedir, imagenames{i});
    eval('image(:,:,i) = ml_readimage(fullpath);', 'image(:,:,i) = [];');
    ut = unique(image(:,:,i));
    u = unique([u ut']);
end

if (~thresh)
    n = 1;
    while (n < length(u))
        t1 = double(u(n));
        t2 = double(u(n + 1));
        if (t2 > 1.5  * t1) * (t2 >= 300)
	    thresh = t1;
	    break;
	end
	n = n + 1;
    end
end

if (thresh > 0)
    image(find(image > thresh)) = min(u);
end

