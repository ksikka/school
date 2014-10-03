function [nuclei_mask] = ml_thresholding(dna,resolution, seeding)
% FUNCTION [nuclei_masks,nuclei_mask_all, nuclei_mask_outline] = ML_SEEDING(dna,resolution)
% dna is the image matrix of the dna channel
% resolution: unit is micron per pixel
% seeding method: 'global' or 'local'
%                 'global' = background substration 'lowCommon' 
%                            + global threshold ('nih'= Ridler)
%                            + majority to remove noise
%                 'local' = background substration 'lowCommon' 
%                           + an average filter is applied on a sliding window representing 12 microns of diameter (half the diameter of big nuclei, small diameter of nuclei in tissue sample)
%                           + local maxima are detected and only those with
%                           an intensity higher than 5% of the maximum
%                           intensity and the intensity higher than 10 are used to remove maxima due to uneven background
%                           + a threshold ('nih'=Ridler) is applied on windows of width 25 microns centered on each local maxima


% it is assumed that nuclei are larger than 5 microns and smaller than 25
% microns and with an intensity at leat 10-gray-level higher than the
% background. The background substration use the method 'lowCommon': the
% value of the most common intensity between zero and the mean intensity of
% the image is subtracted to the whole image.


% Ivan, Aug4, 2005
% Modified by Yanhua Hu,using standard ml functions.
% Septmber 2007, Modified by Estelle Glory to split the segmentation into 4 steps

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

%% initialization
[height,width] = size(dna);

if ~exist('resolution','var')
     resolution=0.2; % microns
end
if ~exist('seeding','var')
     seeding.method = 'global_thresh'; 
     seeding.min_localmax_intensity = 10;
end

mask_all = [];

%% Thresholding
% check if there is only ONE gray level in the image (that means no nucleus in the DNA channel). 
% If it is the case, return a black image
if length(unique(dna))==1
    nuclei_mask = zeros(height,width);
    return;
end

if strcmp(seeding.method,'global_thresh')
    % processing : background substration + global threshold ('nih' = Ridler) 

    % [PROCIMAGE,IMAGEMASK,RESIMG] = ML_PREPROCESS( IMAGE, CROPIMAGE, WAY, BGSUB)
    [dna,nuclei_mask] = ml_preprocess(double(dna),[],'ml','lowcommon');
    % 'ml' = murphy lab approach = work only on the crop region if the 2nd argument of  ml_preprocess is not []
    % 'lowcommon' is the method of background substraction: the most common pixel between 0 and the mean                       of the image
   
else % strcmp(method,'local_thresh')
   [nuclei_mask] = ml_local_threshold(dna, resolution,'nih','lowcommon',seeding.min_localmax_intensity);
end

nuclei_mask = uint8(nuclei_mask);
