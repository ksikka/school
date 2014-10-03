function cells_mask = ml_getwatershed(nuclei_mask,cell)  

conn = 4;
cell = uint16(imcomplement(cell));

W = swatershed( cell, nuclei_mask, conn);

[r c] = find(nuclei_mask>0 & nuclei_mask<max(nuclei_mask(:)));
cells_mask = imfill(~W,[r c],conn);

return
