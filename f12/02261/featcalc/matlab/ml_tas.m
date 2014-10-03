function [names, values, slfnames] = ml_tas(img)
% ML_TAS --- Calculate Threshold Adjacency Statistics
% [NAMES, VALUES, SLFNAMES] = ML_TAS(IMAGE);
%
%  This algorithm was presented by Hamilton et al.
% in "Fast automated cell phenotype image classification"
% (http://www.biomedcentral.com/1471-2105/8/110)
%
%  The current implementationis an adapted version which has no parameters:
% the thresholding is done beforehand (automatically),
% the margin around the mean of pixels to be included is the standard deviation of the pixel values
% and not fixed to 30, as before.
%
%  To obtain the original version of the features, define a global variable
% USE_ORIGINAL_TAS_PARAMETERS and set it to anything which evaluates as true.
% 
%
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

global USE_ORIGINAL_TAS_PARAMETERS;

pixels = uint16(img(:));
if USE_ORIGINAL_TAS_PARAMETERS,
    pixels(pixels <= 30) = [];
else,
    pixels(pixels == 0)=[];
end

mu = mean(pixels);

if USE_ORIGINAL_TAS_PARAMETERS,
    Margin=30;
else,
    Margin=std(pixels);
end

%disp(['mu: ' num2str(mu)])
%disp(['margin: ' num2str(Margin_Top)])

bimg=(img > mu - Margin) .* (img < mu + Margin);

values=calculatetas(1.-bimg);
values=[values calculatetas(bimg)];

names = {'tas_0', 'tas_1', 'tas_2', 'tas_3', 'tas_4', 'tas_5', 'tas_6', 'tas_7', 'tas_8', ...
    'ntas_0', 'tas_1', 'tas_2', 'tas_3', 'tas_4', 'tas_5', 'tas_6', 'tas_7', 'tas_8' };
slfnames = {'tas_0', 'tas_1', 'tas_2', 'tas_3', 'tas_4', 'tas_5', 'tas_6', 'tas_7', 'tas_8', ...
    'ntas_0', 'tas_1', 'tas_2', 'tas_3', 'tas_4', 'tas_5', 'tas_6', 'tas_7', 'tas_8' };
end

function [values] = calculatetas(bimg),
M=[1 1 1; 1 10 1; 1 1 1];
V=conv2(double(bimg),double(M),'valid');
V=V(:);
V(V > 9)=[];
values=histc(V,(1:9)-1);
values=values'/sum(values);

end

% vim: set ts=4 sts=4 expandtab smartindent:
