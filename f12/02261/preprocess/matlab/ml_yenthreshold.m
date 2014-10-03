function threshold = ml_yenthreshold(img)  
% threshold = ml_yenthreshold(img)
%
% Returns a threshold according to Yen's method.
% See "Survey over image thresholding techniques and quantitative
%  performance evaluation" by Sezgin & Sankur for details.


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
%

    if length(size(img))>2
        img=reshape(img,size(img,1),prod(size(img))/size(img,1));
    end
    if max(img(:)) > 255,
        error('ml_kapurthreshold: img should not have values greater than 255 (scale it first)');
    end

    img=uint8(img);
    RHO=2;

    histo = imhist(img,256);
    histo(1)=[];
    cumhisto=cumsum(histo);
    histo = histo ./cumhisto(end);
    cumhisto=cumhisto ./ cumhisto(end);

    cumhisto_r=cumsum(histo .^ RHO);

    Best=-1;
    threshold=-1;
    T=1;

    while cumhisto_r(T) == 0,
        T = T + 1;
    end
    while cumhisto_r(T) < cumhisto_r(end),
        value = - log( cumhisto_r(T) / cumhisto(T)^RHO) ...
                - log( ( cumhisto_r(end) - cumhisto_r(T)) / ((1-cumhisto(T))^RHO) );
        if value > Best,
            threshold=T;
            Best = value
        end
        T = T + 1;
    end

% vim: set ts=4 sw=4 sts=4 expandtab smartindent:
