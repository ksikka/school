function regions = getwatershed( cell,seeds)

conn = 4;
W = swatershed( cell, seeds>0, conn);

[r c] = find(seeds>0 & seeds<max(seeds(:)));
regions = ~imfill(~W,[r c],conn);

return
