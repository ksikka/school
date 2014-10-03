function [arfeat] = ml_ar2dt(featm,n)

% [arfeat] = ml_ar2dt(featm,n)
% ml_ar2dt calculate autoregression features by columns
% Input:
% featm: feature matrix
% n: order of the model
% Output:
% arfeat: autoregression features

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

% Created by Juchang Hua and modified by Yanhua Hu

arfeat = [];
[nrow, ncol] = size(featm);
for i = 1:ncol
    feat = featm(:,i);
    th = ar(feat,n);
    param = th.ParameterVector'; 
    arfeat = [arfeat param];    
end