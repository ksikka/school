function [masks,outline] = ml_segwrap( img, inputs, resolution)

% Generic
param.resolution = resolution;

% Thresholding
switch lower(inputs.threshmeth)
    case 'local'
	param.seeding.method = 'local_thresh';
	param.seeding.min_localmax_intensity = 10;
    case 'global'
	param.seeding.method = 'global_thresh';	
    otherwise
	error( 'Improper threshmeth');
end

if inputs.preprocfgseeds 
    pixsize = 0.1;
    disksize = 1;
    hlevels = inputs.imhmax;
    nucsize = [inputs.mindiam inputs.maxdiam];
    nuclei_mask = fgseeds(img.nuc, pixsize, disksize, hlevels, nucsize);
else
    nuclei_mask_ori = ml_thresholding(img.nuc, param.resolution, param.seeding);

    % Prefiltering
    param.pre_filtering.min_nucleus_diam  = inputs.mindiam;
    param.pre_filtering.max_nucleus_diam  = inputs.maxdiam;
    param.pre_filtering.min_nucleus_roundness = 0.7; 
    param.pre_filtering.withWatershed = inputs.preprocsplit;

    nuclei_mask = ml_prefiltering(nuclei_mask_ori,param.resolution,param.pre_filtering);
end

% Segmentation
switch lower(inputs.segmeth)
    case 'voronoi'
	param.segmentation_method = 'voronoi'; 
    case 'seededwatershed'
	param.segmentation_method = 'seeded_watershed'; 
    case 'nucleardistance'
	param.segmentation_method = 'nuclear_distance'; 
    otherwise
	error( 'Improper segmentation method');
end

[cells_mask1,segstatus] = ml_segmentation(nuclei_mask,img.cell,param.segmentation_method);
if segstatus<0
    disp( ['Segmentation problem ' num2str(segstatus) ' see ml_segmentation.m']);
    masks = [];
    outline = [];
    return
end
% try
%     [cells_mask1,segstatus] = ml_segmentation(nuclei_mask,img.cell,param.segmentation_method);
% catch
%     cells_mask1 = nuclei_mask;
%     masks = [];
%     outline = nuclei_mask;
%     disp('Segmentation algorithm failed');
%     return
% end


% Postfiltering
param.post_filtering.min_nucleus_diam  = inputs.mindiam;
param.post_filtering.max_nucleus_diam  = inputs.maxdiam;
param.post_filtering.min_nucleus_roundness = 0.7;
param.post_filtering.remove_border_cells   = inputs.postprocrmborder;

if inputs.preprocfgseeds
   nuclei_mask(nuclei_mask~=0)=1; 
end
cells_mask = ml_postfiltering(cells_mask1,nuclei_mask,param.resolution,param.post_filtering);
if max(cells_mask(:))==0
    outline = [];
    masks = [];
    return
end

outline = del2(single(cells_mask)) ~= 0;

cells_mask = bwlabel( cells_mask, 4);
masks = [];
MCM = max(cells_mask(:));
masks{MCM} = [];
for i=1:max(cells_mask(:))
	masks{i} = cells_mask==i;
end

