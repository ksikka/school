function feats = ml_3doverlapfeatures( scaledgfp, gfpthresh, scaleddna, dnathresh, nlevels )

nl = nlevels+1;
v1 = scaleddna(:)+1;
v2 = scaledgfp(:)+1;

Ind = [v1 v2];
CrossCM = accumarray(Ind, 1, [nl nl]);
propstruct = graycoprops(CrossCM);

feats(1) = propstruct.Contrast;
feats(2) = propstruct.Correlation;
feats(3) = propstruct.Energy;
feats(4) = propstruct.Homogeneity;
