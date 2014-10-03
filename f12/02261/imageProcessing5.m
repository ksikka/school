
    
% imgpaths should end in '/' and contain tifs.
% configs should be the name of the file generated at springtask.me/compbio
function pval = imageProcessing5(imgpath1,imgpath2,configs)

configs = parse_json(fgets(fopen(configs))); 

% Read in all the *.tifs
imgs1 = dir(strcat(imgpath1,'*.tif'));      
numimgs1 = length(imgs1);    % Number of files found
imgSet1 = cell(1,numimgs1);
for i=1:numimgs1
   currentfilename = imgs1(i).name;
   imgSet1{i} = imread(currentfilename);
end

% Read in all the *.tifs
imgs2 = dir(strcat(imgpath2,'*.tif'));      
numimgs2 = length(imgs2);    % Number of files found
imgSet2 = cell(1,numimgs2);
for i=1:numimgs2
   currentfilename = imgs2(i).name;
   imgSet2{i} = imread(currentfilename);
end

pval = zeros(length(configs),1);

for i=1:length(configs)
    pval(i) = -1;
end

for i=1:length(configs)
    fprintf(1,'%d %s %s %s %s %s ', i, configs{i}.bgsub,...
                                       configs{i}.threshmeth,...
                                       configs{i}.feat,...
                                       configs{i}.dimred,...
                                       configs{i}.stat);
    switch (configs{i}.feat)
        case 'best37'
            num_feats = 37;
        case 'best34'
            num_feats = 34;
        case 'skel'
            num_feats = 5;
        case 'edge'
            num_feats = 5;
        case 'har'
            num_feats = 13;
        otherwise
            num_feats = -1;
    end

    %allocate space for features
    feats1 = zeros(length(imgSet1),num_feats);
    feats2 = zeros(length(imgSet2),num_feats);

    fvs = lookupCache(configs,configs{i});
    if isempty(fvs)
        % for each image in each image set calculate features
        for j=1:length(imgSet1)
            [~,feats1(j,:),~] = ml_featset(imgSet1{j},[],[],configs{i}.feat,[],[],configs{i}.bgsub,configs{i}.threshmeth);
        end

        for j=1:length(imgSet2)
            [~,feats2(j,:),~] = ml_featset(imgSet2{j},[],[],configs{i}.feat,[],[],configs{i}.bgsub,configs{i}.threshmeth);
        end

        % store result of feature computation in config struct
        configs{i}.fv = cat(3,feats1,feats2);
    else
        % extract f1 and f2 from result of cache lookup
        feats1 = fvs(:,:,1);
        feats2 = fvs(:,:,2);
    end

    %combine features into one vector
    feats = cat(1,feats1,feats2);

    %get zscore
    zfeats = zscore(feats);

    %dimensionality reduction
    switch (configs{i}.dimred)
        case 'pca'
           [~,score,~] = princomp(zfeats,'econ');
        case 'none'
            score = zfeats;
        otherwise
            score = -1;
    end

    %run statistical test
    switch (configs{i}.stat)
        case 'knn'
            [pval(i),~] = ml_knntest2(score(1:numimgs1,:),...
                                score((numimgs1+1):(numimgs1+numimgs2),:));
        case 'hotelt2'
            [pval(i),~] = ml_ht2test2(score(1:numimgs1,:),...
                                score((numimgs1+1):(numimgs1+numimgs2),:),0);
        otherwise
            pval(i) = -1;
    end
    
end
end

function eq = ppEq(c1,c2)
    eq = (strcmp(c1.bgsub,c2.bgsub) & ...
          strcmp(c1.threshmeth,c2.threshmeth) & ...
          strcmp(c1.feat,c2.feat));
end

function calced = fvIsCalculated(c1)
    calced = not(isempty(c1.fv));
end

function fv = lookupCache(cfgs,c)
    for ind = 1:length(cfgs)
       if fvIsCalculated(cfgs{ind}) & ppEq(cfgs{ind},c)
           fv = cfgs{ind}.fv;
           disp('Cache hit');
           return;
       end
    end
    fv = [];
    disp('Not found in cache');

end