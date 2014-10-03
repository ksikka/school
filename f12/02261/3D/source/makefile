# Author: Ivan E. Cao-Berg (icaoberg@scs.cmu.edu)
# Created: January 17, 2011
# Modified February 13, 2011 to remove ml_3dfindobj
#
# Copyright (C) 2011 Lane Center for Computational Biology
# Carnegie Mellon University
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
#
# For additional information visit http://murphylab.web.cmu.edu or
# send email to murphy@cmu.edu

all:
	${GCC} -c -IInclude -fPIC -ansi ml_3Dcvip_pgmtexture.c
	${MEX} -D_MEX_ ml_3dbgsub.c
	${MEX} -D_MEX_ ml_binarize.c
	${MEX}  -D_MEX_ ml_3Dtexture.c ml_3Dcvip_pgmtexture.o
	mv *.mex* ../matlab/mex
ml_3dgbsub:
	${MEX} -D_MEX_ ml_3dbgsub.c
	mv *.mex* ../matlab/mex
ml_binarize:
	${MEX} -D_MEX_ ml_3dbgsub.c
	mv *.mex* ../matlab/mex


