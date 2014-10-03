function cells_mask = ml_postfiltering(cells_mask,nuclei_mask,resolution,param);
% selection of nuclei which respect the constrains:
% size in between min and max diameters
% roundness higher than the value given in parameter

if ~exist('resolution','var')
     resolution=0.2; %micrometer
end
if ~exist('param','var')
     param.min_cell_diam=5; %micrometer
     param.max_cell_diam=20; %micrometer
     param.min_nucleus_roundness = 0.7;
     param.remove_border_cells = 0;
end

%% create nuclei with the same label as cells

labeled_cells_mask = bwlabel(cells_mask,4);
labeled_nuclei_mask = labeled_cells_mask.*double(nuclei_mask);

%% selection depending on size and shape
min_area_obj= (param.min_nucleus_diam/resolution)^2;
max_area_obj= (param.max_nucleus_diam/resolution)^2;
max_diam_obj= (param.max_nucleus_diam/resolution);


% [cells_labeled, nbLabels] = bwlabel(cells_mask,4);

stats = regionprops(labeled_nuclei_mask,'Area','Perimeter');
allAreas = [stats.Area];
allPerim = [stats.Perimeter];
allRoundness = 4*pi*allAreas./allPerim;

selected_idx_obj=(allAreas<=max_area_obj) & (allAreas>=min_area_obj) & (allRoundness>=param.min_nucleus_roundness);
selected_idx_obj = find(selected_idx_obj);
% figure(5),imshow(ismember(labeled_nuclei_mask,selected_idx_obj),[]),title('labeled_nuclei_mask'); 



%% remove regions which touch the border of the image 

% remove regions which touch the border of the image 
if param.remove_border_cells==1
%     [h,w]=size(labeled_cells_mask);
%     borderL = [labeled_cells_mask(:,1)',labeled_cells_mask(:,w)',labeled_cells_mask(1,:),labeled_cells_mask(h,:)];
%     borderL = unique(borderL);
%   above had the following problems:
%       1) using labeled_cells_mask would remove all regions which touch
%       the border, regardless of whether their nuclei were complete, so
%       switching to labeled_nuclei_mask instead
%       2) labeled_cells_mask and label_nuclei_mask have a 1-pixel-wide
%       black border
    [h,w]=size(labeled_nuclei_mask);
    borderL = [labeled_nuclei_mask(:,2)',labeled_nuclei_mask(:,w-1)',labeled_nuclei_mask(2,:),labeled_nuclei_mask(h-1,:)];
    borderL = unique(borderL);

    selected_idx_obj = setdiff(selected_idx_obj,borderL); 
end



%% create the cell_regions

cells_mask = uint8(ismember(labeled_cells_mask,selected_idx_obj));



