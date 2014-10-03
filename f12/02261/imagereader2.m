function tricolorimg = imagereader2(imgpath)
%Notes:
%imgpath ='images/"

for i=1:5
    imgFITC= imread([imgpath,'GFP_Field',num2str(i),'_Induced.png']);
    imgDIC= imread([imgpath,'DIC_Field',num2str(i),'_Induced.png']);
    imgPI = imread([imgpath,'Cy3_Field',num2str(i),'_Induced.png']);
    tricolorimg{i} = uint8(zeros(size(imgFITC,1),size(imgFITC,2),3));

    tricolorimg{i}(:,:,1)=imgPI;
    tricolorimg{i}(:,:,2)=imgFITC;
    tricolorimg{i}(:,:,3)=imgDIC;

end

