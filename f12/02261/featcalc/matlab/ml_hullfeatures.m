function [names, values, slfnames] = ml_nhullfeatures(imageproc, imagehull,output)
% Copyright (C) 2006--2008  Murphy Lab
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

% $Id: ml_hullfeatures.m,v 1.4 2008/01/13 21:54:27 lcoelho Exp $

if nargin < 3,
    output='default';
end

Ahull = bwarea(imagehull) ;
hullfract = length(find(imageproc))/Ahull ;
Phull = bwarea(bwperim(imagehull)) ;
hullshape = (Phull^2)/(4*pi*Ahull) ;

%
% Central moments of the convex hull
%
hull_mu00 = ml_imgcentmoments(imagehull,0,0) ;
hull_mu11 = ml_imgcentmoments(imagehull,1,1) ;
hull_mu02 = ml_imgcentmoments(imagehull,0,2) ;
hull_mu20 = ml_imgcentmoments(imagehull,2,0) ;

%
% Parameters of the 'image ellipse'
%   (the constant intensity ellipse with the same mass and
%   second order moments as the original image.)
%   From Prokop, RJ, and Reeves, AP.  1992. CVGIP: Graphical
%   Models and Image Processing 54(5):438-460
%
hull_semimajor = sqrt((2 * (hull_mu20 + hull_mu02 + ...
    sqrt((hull_mu20 - hull_mu02)^2 + ...
    4 * hull_mu11^2)))/hull_mu00) ;

hull_semiminor = sqrt((2 * (hull_mu20 + hull_mu02 - ...
    sqrt((hull_mu20 - hull_mu02)^2 + ...
    4 * hull_mu11^2)))/hull_mu00) ;
hull_eccentricity = sqrt(hull_semimajor^2 - hull_semiminor^2) / hull_semimajor ;

if strcmp(output,'hullsize') || strcmp(output,'dnahullsize'),
    nvalues=[Ahull sqrt(Ahull) Phull hull_semimajor hull_semiminor'];
    values=[nvalues 1./(nvalues+double(nvalues==0))];
    names=[cellstr('convex_hull:area') cellstr('convex_hull:sqrt(area)') cellstr('convex_hull:perimeter') ...
        cellstr('convex_hull:semi_major_axis') cellstr('convex_hull:semi_minor_axis') ...
        cellstr('convex_hull:area_inv') cellstr('convex_hull:sqrt(area)_inv') ...
        cellstr('convex_hull:perimeter_inv') cellstr('convex_hull:semi_major_axis_inv') cellstr('convex_hull:semi_minor_axis_inv') ];
    if strcmp(output,'hullsize'),
        slfnames=[cellstr('SLF27.1') cellstr('SLF27.2') cellstr('SLF27.3') cellstr('SLF27.4') cellstr('SLF27.5') ...
            cellstr('SLF27.6') cellstr('SLF27.7') cellstr('SLF27.8') cellstr('SLF27.9') cellstr('SLF27.10')];
    else
        slfnames=[cellstr('SLF28.1') cellstr('SLF28.2') cellstr('SLF28.3') cellstr('SLF28.4') cellstr('SLF28.5') ...
            cellstr('SLF28.6') cellstr('SLF28.7') cellstr('SLF28.8') cellstr('SLF28.9') cellstr('SLF28.10')];
    end
else, % default
    names = [cellstr('convex_hull:fraction_of_overlap') cellstr('convex_hull:shape_factor') cellstr('convex_hull:eccentricity')] ;
    slfnames = [cellstr('SLF1.14') cellstr('SLF1.15') cellstr('SLF1.16')] ;
    values = [hullfract hullshape hull_eccentricity] ;
end

% vim: set ts=4 sts=4 sw=4 expandtab smartindent:
