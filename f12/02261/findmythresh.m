function segimgs = findmythresh(tricolorimg)

for i=1:length(tricolorimg)
    for j=1:3
        threshold=ml_rcthreshold(tricolorimg{i}(:,:,j));
        segimgs{i}(:,:,j)=tricolorimg{i}(:,:,j)>threshold;
    end
end

end

