function feats = ml_3dDTfeatures( protimg, protbin, dnaimg, dnabin )
% calculate intensity weighted average distance between protein image and
% reference (DNA) image and vice versa

%t=sum(protimg,3); figure; imshow(t,[min(t(:)) max(t(:))])
%t=sum(dnaimg,3); figure; imshow(t,[min(t(:)) max(t(:))])

dnadist=bwdist(dnabin);
pweightdist=single(protimg).*dnadist;

%t=sum(dnadist,3); figure; imshow(t,[min(t(:)) max(t(:))])
%t=sum(pweightdist,3); figure; imshow(t,[min(t(:)) max(t(:))])

protdist=bwdist(protbin);
dweightdist=single(dnaimg).*protdist;

%t=sum(protdist,3); figure; imshow(t,[min(t(:)) max(t(:))])
%t=sum(dweightdist,3); figure; imshow(t,[min(t(:)) max(t(:))])

feats(1) = mean(pweightdist(:));
feats(2) = mean(dweightdist(:));

