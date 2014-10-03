% differennce between 'lowcommon' and 'common' for the background substraction
% differennce between 'nih' and 'adaptative' for the threshold method
% Used by ELVIRA on RandTag images : threshold = 'adaptative'; bkgsub = 'common'

% function [mask_all] = ml_local_threshold(dna, resolution, min_nucls_diam, max_nucls_diam, min_max_intensity,solidity);
function [nuclei_mask] = ml_local_threshold(dna, resolution, threshold, bkgsub,min_max_intensity);

%   EGA_2D_LOCAL_THRESHOLD_NUCLEI(DNAIMG, RESOLUTION);
% dna is the image matrix of the dna channel
% resolution: unit is micron per pixel

%   Returns the total mask with all nuclei.

% This algorithm segments nuclei with a local threshold. 
% The local threshold is performed in a window around each potential
% nucleus. A potential nucleus is located as a local maximum of image after it has been blurred with a gaussian filter.  
% Objects with more than one maxima or irregular shape
% (area/convexHull<95%) are submitted for the watershed. The watershed is
% processed on the distance map inner the objects.
 
% 9-APRIL-2007 write by E. Glory


%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('bkgsub','var')
    bkgsub = 'lowcommon';
end
if ~exist('threshold','var')
    threshold = 'nih'; %'adaptative','Otsu', 'derivative','Ridler','Ridler_old'  
end

% test
min_nucls_diam = 10; % micrometer
max_nucls_diam = 25; % micrometer

min_nucls_diam = min_nucls_diam/resolution;
max_nucls_diam = max_nucls_diam/resolution; 
winSize = ceil(min_nucls_diam);

[height,width] = size(dna);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

%%%%%% PREPROCESSING = backgroundnsubstraction %%%
dna = ml_imgbgsub(double(dna), bkgsub);
dna = uint8(dna);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%% LOCAL THRESHOLD %%%%%%%%%%%%%%%%%%%%
dnaImgRoi = zeros(size(dna));

% Smoothing
dnaImgFiltered=imfilter(dna,fspecial('average',winSize),'symmetric');


% Selection of regional maxima which have an intensity above 5% of the local maximum of the smooth image
dnaImgBinary = imregionalmax(dnaImgFiltered);
[dnaImgBinary,n] = bwlabel(dnaImgBinary,8);

% figure,imshow(dnaImgBinary,[])
particleAnalysis = regionprops(dnaImgBinary,'basic');
thresRegMaxima = ceil(0.05 * double(max(max(dnaImgFiltered)))); %0.05

% imwrite(dnaImgBinary,['C:\Data\Images\3T3\RandTag\Unlabeled\AA7B2\set01\Segmentation_channel_0\' num2str(dnaImgName) '_maxima.tif']);

% ROI around the neighbor of seeds  
for idxParticle=1:length(particleAnalysis)
    centr = particleAnalysis(idxParticle).Centroid;
    valMax =  dnaImgFiltered(floor(centr(2)),floor(centr(1)));


 
    % select regional maxima that are upper than thresRegMaxima (5% of Max(Maxima))
    if valMax>thresRegMaxima & valMax>min_max_intensity

        xInf = max(1,floor(centr(1)-max_nucls_diam/2));
        xSup = min(width,ceil(centr(1)+max_nucls_diam/2));
        yInf = max(1,floor(centr(2)-max_nucls_diam/2));
        ySup = min(height,ceil(centr(2)+max_nucls_diam/2));
        nucRoi = double(imcrop(dna,[xInf yInf (xSup-xInf+1) (ySup-yInf+1)]));
% figure,imshow(nucRoi,[])       
        nbIteration=0;
        stop = 0;
        level = 0;
        while stop~=1

            if level==0
                nucRoiBinary = ml_threshcrop(nucRoi, [], threshold);
                
                level = length(find(nucRoiBinary==0)); 
%                 level = graythresh(nucRoi);% Otsu's threshold
            end
            %             if threshold == 'derivative'
            %                 eval('level = ml_choosethresh(dna);', ...
            %                     'disp(''could not get threshold''); level = 0.04');
            %             end
            
            if level~=0 % to prevent the total surface of the ROI is selected as one connected component
%                 nucRoiBinary = im2bw(nucRoi,level);

                strElemt = strel('disk',2);
                nucRoiBinary = imopen(nucRoiBinary,strElemt);
                nucRoiBinary = imfill(nucRoiBinary,'holes');
%                 figure, imshow(nucRoiBinary,[]),title(['nucRoiBinary' num2str(idxParticle)]);
                nucRoiBinaryL = bwlabel(nucRoiBinary,8);
                
                % check that the seed of the region is in the background of the
                % threshold crop image
                if nucRoiBinary(floor(centr(2)-yInf+1),floor(centr(1)-xInf+1))==0
                    if nbIteration==0;
                        % try a lower threshold
                        level = level-0.1;
                        if level<0
                            level=0.001;
                        end
                    else
                        % the thresholded region which does not belong to the expected particle is dilated and removed from 
                        % the roi crop image
                        newMyRoi= nucRoi;
                        strElemt = strel('disk',25);
                        nucRoiBinary = imdilate(nucRoiBinary,strElemt);
                        
                        newMyRoi(nucRoiBinary)=0;
                        nucRoi = newMyRoi;
                        %             figure, imshow(newMyRoi,[]),title('new roi creation');   
                    end
                    nbIteration = nbIteration+1;
                    if nbIteration >3
                        stop=1;
                    end
                else 
                    stop=1;
                    %find the particle that contains the centroid of interest
                    particleAnalysisListPixel = regionprops(nucRoiBinaryL,'PixelList');
                    
                    idxSelectedParticle = getParticleIncludingPixel(particleAnalysisListPixel, floor(centr(1)-xInf+1), floor(centr(2)-yInf+1));    
                    
                    pixels = particleAnalysisListPixel(idxSelectedParticle).PixelList ;
                    pixels = pixels + [xInf.*ones(length(pixels),1),yInf.*ones(length(pixels),1)];
                    %copy the pixels of the particle in the real size image
                    for p=1:length(pixels)
                        if (pixels(p,2)<=height) & (pixels(p,1)<=width)
                            dnaImgRoi(pixels(p,2),pixels(p,1))=1;
                        end
                    end
                end
            else
                stop=1;
            end
        end
    end
end

nuclei_mask = dnaImgRoi;

%--------------------------------------------------------------------------

function [idxSelectedParticle] = getParticleIncludingPixel(particleAnalysis, xPixel, yPixel); 
% 
j=1; found=0;idxSelectedParticle=1;
while j<=length(particleAnalysis) & found==0 
    pixels = particleAnalysis(j).PixelList ;
    k=1; 
    while k<=length(pixels(:,1)) & found==0
        p=pixels(k,:);
        if p(1)==xPixel & p(2)==yPixel
            found=1;
        end
        k=k+1;
    end
    if found==1
        idxSelectedParticle = j;
    else
        j=j+1;    
    end  
end
    


