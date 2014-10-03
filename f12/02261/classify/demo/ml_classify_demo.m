% Copyright (C) 2006  Murphy Lab
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

addpath('/home/ejr/ml/classify/netlab/matlab');
addpath('/home/ejr/ml/classify/matlab');
load('/home/ejr/ml/featcalc/features/19990526_hela03a_all.mat');

features = hela03a_features_all;
[nn, stopidx, confmat, confmats, crates] = ...
    ml_make_nn_classifier(features, idx_sasbest2);

confmat
