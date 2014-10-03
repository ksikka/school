function pval = imageProcessing4(imgpath1,imgpath2,configs)
%Notes:
%imgpath ='images/"

configs = fopen(configs);
configs = fgets(configs);
configs = parse_json(configs);
configs = configs{1}; 

imgs1 = dir(strcat(imgpath1,'*.tif'));      
numimgs1 = length(imgs1);    % Number of files found
imgSet1 = cell(1,numimgs1);
for i=1:numimgs1
   currentfilename = imgs1(i).name;
   imgSet1{i} = imread(currentfilename);
end

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

  
    % for each image in each image set calculate features
    for j=1:length(imgSet1)
        [~,feats1(j,:),~] = ml_featset(imgSet1{j},[],[],configs{i}.feat,[],[],configs{i}.bgsub,configs{i}.threshmeth);
    end

    for j=1:length(imgSet2)
        [~,feats2(j,:),~] = ml_featset(imgSet2{j},[],[],configs{i}.feat,[],[],configs{i}.bgsub,configs{i}.threshmeth);
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
            [pval(i),~] = ml_knntest2(score(1:numimgs1,:),score((numimgs1+1):(numimgs1+numimgs2),:));
        case 'hotelt2'
            [pval(i),~] = ml_ht2test2(score(1:numimgs1,:),score((numimgs1+1):(numimgs1+numimgs2),:),0);
        otherwise
            pval(i) = -1;
    end
    
end