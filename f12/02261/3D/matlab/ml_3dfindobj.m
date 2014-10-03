function objects = ml_3dfindobj(binimg,findholes,min_obj_size)

% OBJECTS = ML_3DFINDOBJ( BINIMG, FINDHOLES, MIN_OBJ_SIZE)
%
% Find the objects in binary image BINIMG. If FINDHOLES is nonzero then
% holes are found too. The default is not to find holes.
% If MIN_OBJ_SIZE is specified, then objects smaller
% than that size are ignored.

% Copyright (C) 2010,2011  Murphy Lab
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

% Meel Velliste 5/20/02
% Modified February 12, 2011    R.F. Murphy     Use bwlabeln
%   note that this .m function gives a different number of holes than the C
%   mex version. The code in this function should be correct.
% Modified February 13, 2011    R.F. Murphy     Use bwconncomp.
%   Since it returns structure with indices of each object, it is 5-6 times
%   faster than using bwlabeln (which requires refinding each object).
%   Lines needed to switch back to bwlabeln are commented with %bwlabeln%

if( ~exist( 'min_obj_size', 'var'))
    min_obj_size = 1;
end

if( ~exist( 'findholes', 'var'))
    findholes = 0;
end

if strcmp(class(binimg),'double')
    binimg = uint8(floor(binimg));
end

imgsiz = size(binimg);
%bwlabeln%[labeledobjects,nobjects] = bwlabeln(binimg);
objstruct = bwconncomp(binimg);

% The regionprops function does not support calculating Euler numbers for
% 3D ojects.  If this support is added later, the code below can be used
% instead of the object-by-object hole finding in the for loop below
%E%%bwlabeln%Eulernumbers = regionsprops(labeledobjects,'EulerNumber');
%E%Eulernumbers = regionprops(objstruct,'EulerNumber');

% create an image with ones everywhere for later use in hole finding
if findholes
    objimg = ones(imgsiz);
end

% Get Number of Objects
%bwlabeln%objno = max(max(max(labeledobjects)));
objno = objstruct.NumObjects;

objects = {};
nreturnedobjects = 0;
for m = 1 : objno
    %bwlabeln%     objectvoxels = find(labeledobjects(:,:,:)==m);
    objectvoxels = objstruct.PixelIdxList{m};
    % number of voxels in the object
    voxelno = length(objectvoxels);
    
    if voxelno >= min_obj_size
        [v1,v2,v3] = ind2sub(imgsiz,objectvoxels);
        voxels = uint16([v1 v2 v3]');
        
        if findholes
            %E% holeno = voxelno-Eulernumbers(m);
            if size(voxels,2) > 1
                lbound = min(voxels')';
                lbound = lbound-uint16(lbound>1);
                ubound = max(voxels')';
                ubound = ubound+uint16(ubound<imgsiz');
                % clear voxels for current object-produces inverted image of that object
                objimg(objectvoxels) = 0;
                % count objects in the inverted image = holes in original object
                [ignore,holeno] = bwlabeln(objimg(lbound(1):ubound(1),lbound(2):ubound(2),lbound(3):ubound(3)));
                % correct for "hole" containing the rim of the image
                holeno = holeno - 1;
            else
                holeno = 0;
            end
            % reset inverted image for next object
            objimg(objectvoxels) = 1;
        else
            holeno = NaN;
        end
        
        % created struct for the object and attach it to the result
        nreturnedobjects = nreturnedobjects + 1;
        objects{nreturnedobjects} = struct('size', voxelno, 'voxels', voxels, 'n_holes', holeno);
    end
end
objects = objects';
