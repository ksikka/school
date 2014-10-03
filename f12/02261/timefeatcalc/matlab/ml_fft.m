function [feat,featnames] = ml_fft(image_2Dt)

% feat = ml_fft(image_2Dt, fft_len, mask_img)
% Calculate fft features for 2D time series images
% image_2Dt: 3D matrix containing 2D images over time
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

% Yanhua Hu, 2007
% Modified by Yanhua Hu, 2009


fft_img = fft(image_2Dt, [],3);

% if a pixel is always 0, we don't consider the fft of it
sum_img = sum(image_2Dt, 3);
valid_idx = find(sum_img>0);

feat =[];
featnames = {};
for i = 1: (size(fft_img,3)/2+1)
    f_img = fft_img(:,:,i);
    m = quantile(f_img(valid_idx), [0.05,0.25, 0.5, 0.75, 0.95]);    
    mn = mean(f_img(valid_idx));
    s = std(f_img(valid_idx));
    m_s = mn/s; % mean/std 
    feat= [feat, m, mn, s, m_s];
    ii = num2str(i);
    featnames =  [featnames,{['5per_coeff_',ii]},{['25per_coeff_',ii]},...
		  {['50per_coeff_',ii]},{['75per_coeff_',ii]},...
		  {['95per_coeff_',ii]},{['mean_coeff_', ii]},...
		  {['std_coeff_',ii]},{['mean_over_std_coeff_', ii]}];
end

feat = abs(feat);