function nuclei_mask = ml_prefiltering(nuclei_mask,resolution,param);
% selection of nuclei which respect the constrains:
% size in between min and max diameters
% roundness higher than the value given in parameter

if ~exist('resolution','var')
     resolution=0.2; %micrometer
end
if ~exist('param','var')
     param.min_nucleus_diam=5; %micrometer
     param.max_nucleus_diam=20; %micrometer
     param.min_nucleus_roundness = 0.7;
     param.withWatershed = 1;
end

min_area_obj= (param.min_nucleus_diam/2/resolution)^2;
max_area_obj= (param.max_nucleus_diam/2/resolution)^2;
max_diam_obj= (param.max_nucleus_diam/resolution);

nuclei_labeled = bwlabel(nuclei_mask);

stats = regionprops(nuclei_labeled,'Area','Perimeter','MajorAxisLength');
allAreas = [stats.Area];
allPerim = [stats.Perimeter];
allMajorAxis = [stats.MajorAxisLength];
allRoundness = 4*pi*allAreas./allPerim;

% select object bigger than min diameter, smaller than max diameter and
% higher roundness than min_roundness
selected_correct_obj=(allAreas<=max_area_obj) & (allAreas>=min_area_obj) & (allRoundness>=param.min_nucleus_roundness) & (allMajorAxis<=max_diam_obj);
selected_idx_obj = find(selected_correct_obj);
nuclei_mask = uint8(ismember(nuclei_labeled,selected_idx_obj));

% select object bigger than max diameter, whatever is the roundess
if param.withWatershed==1
    selected_big_obj=(allAreas>max_area_obj) |(allMajorAxis>max_diam_obj);%& (allRoundness>=param.min_roundness);
    big_nuclei_mask = ismember(nuclei_labeled,find(selected_big_obj));
%         figure, imshow(big_nuclei_mask,[]), title('big_nuclei_mask');
    imComplement = uint8(imcomplement(big_nuclei_mask));
    distImg =  uint8(bwdist(imComplement));
    imComplement2 =  uint8(imcomplement(distImg));
    cellImg = watershed(imComplement2);
    big_nuclei_mask(find(cellImg==0))=0;
   
    % remove objects found by the watershed which are smaller than the min_area_obj
    nuclei_watershed_labeled = bwlabel(big_nuclei_mask);
%     figure, imshow(nuclei_watershed_labeled,[]),title('nuclei_watershed_labeled');
    stats_big = regionprops(nuclei_watershed_labeled,'Area','Perimeter');
    allAreas_big = [stats_big.Area];
    
    selected_big_obj=(allAreas_big>=min_area_obj) ;
    big_nuclei_mask = uint8(ismember(nuclei_watershed_labeled,find(selected_big_obj)));


%     figure, imshow(imComplement2,[]),title('dist');
%     figure, imshow(cellImg,[]),title('watershed');
%     figure, imshow(big_nuclei_mask,[]), title('big_nuclei_mask');

	nuclei_mask(find(big_nuclei_mask))=1;

end



%%%%%%%%%%%%%%%%%%%%% WATERSHED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % A. Select Region with two maxima and ratio Area/Convex<0.95 for Watershed
% % A. Select region not submitted to the watershed
% % B.Apply watershed
% % C. Merge watershed and not watershed
% [imgToKeep, imgForWater] = selectParticleForWatershed(dnaImgRoi,dnaImgBinary,solidity);
% %     figure, imshow(imgToKeep,[]), title('imgToKeep');
% %     figure, imshow(imgForWater,[]), title('imgForWater');
% imgWater = segmentWatershed(imgForWater,min_nucls_diam);
% if size(imgWater)== size(imgToKeep)
% 
% 
%     imgNuclei = imgWater+imgToKeep;
% else
%     imgNuclei = imgToKeep; 
% end
% imgNuclei= imopen(imgNuclei,strElemt);
% imgNuclei = im2bw(imgNuclei);
% 
% %%%%%%%%%%%%%% MASK %%%%%%%%%%%%%%%%  
% masks={};
% mask_all = [];
% 
% [labelImg, nL] = bwlabel(imgNuclei);
% [h w] = size(imgNuclei);
% listLabels=1:nL;
% 
% % individual masks 
% cptLab = 1;  
% for label=listLabels
%     masks{cptLab} = zeros(size(labelImg));
%     masks{cptLab} = ismember(labelImg,label);
%     cptLab= cptLab+1;
% end
% 
% % global mask
% mask_all = zeros(size(labelImg));
% mask_all = ismember(labelImg,listLabels);
% 
% 
% %--------------------------------------------------------------------------
% 
% function [idxSelectedParticle] = getParticleIncludingPixel(particleAnalysis, xPixel, yPixel); 
% % 
% j=1; found=0;idxSelectedParticle=1;
% while j<=length(particleAnalysis) & found==0 
%     pixels = particleAnalysis(j).PixelList ;
%     k=1; 
%     while k<=length(pixels(:,1)) & found==0
%         p=pixels(k,:);
%         if p(1)==xPixel & p(2)==yPixel
%             found=1;
%         end
%         k=k+1;
%     end
%     if found==1
%         idxSelectedParticle = j;
%     else
%         j=j+1;    
%     end  
% end
%     
% %--------------------------------------------------------------------------
% 
% function bwSelectedObjectsImg = getObjectsW2Maxima(objectImg,bwMaximaImg);
% imgForWatershed = zeros(size(objectImg));
% listParticles = zeros(length(particleAnalysis),1);
% 
% %--------------------------------------------------------------------------
%   
% function [imgToKeep, imgForWater] = selectParticleForWatershed(imgRoi,imgSeed,solidity, imgNuclei,areaMin);
% % Since the watershed algorithm provides over-segmentation of isolated nuclei
% % the watershed algorithm will be applied only on region where there are 2 seeds!
% 
% if ~exist('imgNuclei', 'var')
%     imgNuclei = [];
% end
% 
% if ~exist('areaMin', 'var')
%     areaMin=1; % unit = pixels
% end
% 
% 
% [imgRoiL,nRoi] = bwlabel(imgRoi,8);
% 
% [imgSeedL,nSeed] = bwlabel(imgSeed,8);
% seedAnalysis = regionprops(imgSeedL,'basic');
% particleAnalysis = regionprops(imgRoiL,'all');
% 
% % Seek particles with more than one seed/maxima inside
% [idxParticlesToProcess,idxParticlesToKeep] = selectIdxParticleForWatershed(imgRoiL,nRoi,particleAnalysis,seedAnalysis,solidity);  
% 
% imgToKeep = ismember(imgRoiL,idxParticlesToKeep);
% if length(idxParticlesToProcess)>0
%     imgForWater = ismember(imgRoiL,idxParticlesToProcess);
% else
%     imgForWater = [];
% end
% 
% 
% 
% %--------------------------------------------------------------------------
% 
% function [imgWater] = segmentWatershed(imgForWater, minDiamNuc);
%     if length(imgForWater)~=0
%         imgDist = bwdist(~imgForWater);
%         imgDist = -imgDist;
%         imgDist=imfilter(imgDist,fspecial('average',15),'replicate');
%         
%         imgDist(~imgForWater) = -Inf;
%         %     figure, imshow(imgDist,[])
%         
%         imgWater = watershed(imgDist,8);
%         % [imgWater,n] = bwlabel(imgWater,8);
%         imgWater(~(imgForWater)) = 0;
%         strElemt = strel('diamond',2);
%         imgWater = imopen(imgWater,strElemt);
% %         figure, imshow(imgWater,[]),title('after watershed')
% 
%         % check the area of regions found are not too small for beeing 1
%         % nucleus
%         imCheck = bwlabel(imgWater,8);
% % figure, imshow(imCheck,[]),title('imCheck')
%         stats = regionprops(imCheck,'basic');
%         allArea = [stats.Area];
%         idxSmall = find([stats.Area]<(minDiamNuc*minDiamNuc/2));
%         
%        
%         
%         centroidToFind=[];
%         for i=1:length(idxSmall)
%             centroidToFind = [centroidToFind; round(stats(idxSmall(i)).Centroid)];
% %              figure, imshow(ismember(imCheck,idxSmall(i)),[]),title(['imCheck' i])
%         end
% % centroidToFind
% % figure, imshow(ismember(imCheck,idxSmall(i)),[]),title(['idxSmall'])
% %         centroidToFind = centroidToFind(idxSmall,:)
% 
% 
%         idxImgOri = [];
%         [imLabel,n] = bwlabel(imgForWater,8);
%         
%         analysis = regionprops(imLabel,'PixelList');
%         
%         for j=1:n
%             listPixels = analysis(j).PixelList;
%             if length(find(ismember(listPixels,centroidToFind,'rows')==1)) > 0
%                 idxImgOri = [idxImgOri j];
%             end
%         end
% 
%         imgForWater = ismember(imLabel,idxImgOri);
% %  figure, imshow(imgForWater,[]),title('a recuperer')
%         imgWater = im2bw(imgWater,0.0001);
%         imgWater(find(imgForWater>0))=1;
% %  figure, imshow(imgWater,[]),title('imgWater')
%     else 
%         imgWater=[];
%     end
%     
% 
% 
% %------------------------------------------------------------
% function [listParticlesToProcess,listParticlesToKeep] = selectIdxParticleForWatershed(labelObj,nObj,particleAnalysis,seedAnalysis,solidity);  
% listParticles = zeros(nObj,1);
% 
% % select particles which contain more than one regional maxima
% for i=1:length(seedAnalysis)
%     j=1;
%     found=0;
%     centr = seedAnalysis(i).Centroid;
%     idxObj = labelObj(floor(centr(2)),floor(centr(1)));
%     if idxObj>0
%         listParticles(idxObj) = listParticles(idxObj)+1;
%     end
%     %     fprintf('\nseed %i, particle %i, trouve= %i',i,(j-1),found);
% end
% 
% % select particles which have a solidity = area/convexHull below 0.95
% for i=1:length(particleAnalysis)
%     if particleAnalysis(i).Solidity<solidity
%         listParticles(i)= listParticles(i)+1;
%     else
%         listParticles(i)= listParticles(i)-1;
%     end
% end
% % for i=1:length(particleAnalysis)
% %     if particleAnalysis(i).Solidity<0.95
% %         listParticles(i)= listParticles(i)+1;
% %     end
% %     if particleAnalysis(i).Solidity>0.97
% %         listParticles(i)= listParticles(i)-1;
% %     end
% % end
% listParticlesToProcess = find(listParticles>1);
% listParticlesToKeep = find(listParticles<2);
% %---------------------------------------------------------------



%% watershed
