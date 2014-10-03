% Author: Ivan E. Cao-Berg (icaoberg@scs.cmu.edu)
% September 18, 2012
%
% Copyright (C) 2012 Lane Center for Computational Biology
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

if ismac
  !gcc -c -IInclude -I/usr/include/malloc -fPIC -ansi cvip_pgmtexture.c
  mex -I/usr/include/malloc ml_texture.c cvip_pgmtexture.o
else
  !gcc -c -IInclude -I/usr/include/malloc -fPIC -ansi cvip_pgmtexture.c
  mex -I/usr/include/malloc ml_texture.c cvip_pgmtexture.o
end

!mex -DPI%M_PI ml_Znl.cpp
mex ml_moments_1.c

if ispc
    !move *.mex* ..\matlab\mex
else
	!mv *.mex* ../matlab/mex
end
