function [cells_mask,status] = ml_segmentation(nuclei_mask,cell,segmentation_method);

% nuclei_mask: binary images with nuclear regions
% cell: image of the total protein
% segmentation_method = 'voronoi' or 'seeded_watershed' or% 'nuclear_distance' or 'graphical_model'

status = 1;
if isempty( nuclei_mask)
    cells_mask = [];
    status = -1;
    return
end

%diary( '/home/webapps/develop/thisisatest' );
%segmentation_method
%whos cell

switch segmentation_method
    case 'voronoi'
        cells_mask = ml_getvoronoi(nuclei_mask);
    case 'seeded_watershed'
        if isempty( cell)
            status = -2;
            cells_mask = [];
        else
            cells_mask = ml_getwatershed(nuclei_mask,cell);
        end
    case 'nuclear_distance'
        distNuc = bwdist(nuclei_mask);
        cells_mask = ml_getwatershed(nuclei_mask,distNuc);
    case 'graphical_model'
        disp('not functional yet');
    otherwise
      status = -3;
      disp('Unknown method')
end

if status == -3
    cells_mask = [];
else
    cells_mask = uint8(~cells_mask);
end
