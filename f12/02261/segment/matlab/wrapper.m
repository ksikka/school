
ImgPerLine = 3;
TotalImageSeg = 0;
SegProg = 0;
TotalMaskSeg = 0;
firstMask=1;
segparams.mindiam=1;
segparams.maxdiam=10;
segparams.threshmeth=2;
segparams.segmeth=1;
segparams.preprocsplit=0;
segparams.preprocrmnoise=1;
segparams.preprocbgseeds=0;
segparams.postprocrmsize=1;
segparams.postprocrmborder=1;
tmpdir='/home/webapps/develop/tmp/imageset';
resultpage='/home/webapps/develop/tmp/imageset/seg_x0x0jynOnex0x0__imageset_develop35C3EB4A202D3CD4918A356E1753BCC56_12,0,1,0,1,10,1,1.html';
savesqlfile='/home/webapps/develop/tmp/imageset/seg_x0x0jynOnex0x0__imageset_develop35C3EB4A202D3CD4918A356E1753BCC56.sql';
rmsqlfile='/home/webapps/develop/tmp/imageset/segmentation/seg_x0x0jynOnex0x0__imageset_develop3_12,0,1,0,1,10,1,1.sql';
saveshfile='/home/webapps/develop/tmp/imageset/segsave_x0x0jynOnex0x0__imageset_develop35C3EB4A202D3CD4918A356E1753BCC56_12,0,1,0,1,10,1,1.sh';
progressfile='/home/webapps/develop/tmp/imageset/segmentation/seg_x0x0jynOnex0x0__imageset_develop3.txt';
fid_SaveSql=fopen(savesqlfile,'w');
fid_RmSql = fopen(rmsqlfile,'w');
fid_Result=fopen(resultpage,'w');
fid_SaveSh=fopen(saveshfile,'w');
fid_prgs=fopen(progressfile,'w');
fprintf(fid_prgs,'%d',SegProg);
fclose(fid_prgs);
fprintf(fid_Result,'<H3 align=center><font color=red>Segmentation Results</font></H3>\n');
fprintf(fid_Result,'<hr>\n');
fprintf(fid_Result,'<h4>VORONOI</h4>\n'); 
fprintf(fid_Result,'<h5>Minimal diameter required for nuclei: %d%s</h5>\n ',1,' microns') ; 
fprintf(fid_Result,'<h5>Maximal diameter allowed for nuclei: %d%s</h5>\n',10,' microns'); 
fprintf(fid_Result,'<h5>Thresholding method: %d%s</h5>\n',2,' microns'); 
fprintf(fid_Result,'<h5>Segmentation method: %d%s</h5>\n',1,' microns'); 
fprintf(fid_Result,'<hr>\n');
fprintf(fid_Result,'<FORM method="get" action="http://pslid.cbi.cmu.edu:80/develop/discardmasks2.jsp">\n'); 
fprintf(fid_Result,'<input type=hidden name=Cur_Gen_Id value="%s">\n','71'); 
fprintf(fid_Result,'<input type=hidden name=settype value="%s">\n','imageset'); 
fprintf(fid_Result,'<input type=hidden name=setname value= "%s">\n','jynOne'); 
fprintf(fid_Result,'<input type=hidden name=method value= "%s">\n','1'); 
fprintf(fid_Result,'<input type=hidden name=params value= "%s">\n','2,0,1,0,1,10,1,1'); 
EMI=8146;
imageids=[107065 107249 ];
dnaids=[107129 107296 ];
prot_urls={'/images/Hela/3D/UCE/YQA/cell1/prot/slice_32.tif' ...
'/images/Hela/3D/UCE/YQA/cell2/prot/slice_24.tif' ...
};
dna_urls={'/images/Hela/3D/UCE/YQA/cell1/dna/slice_32.tif' ...
'/images/Hela/3D/UCE/YQA/cell2/dna/slice_24.tif' ...
};
cell_urls={'/images/Hela/3D/UCE/YQA/cell1/cell/slice_32.tif' ...
'/images/Hela/3D/UCE/YQA/cell2/cell/slice_24.tif' ...
};
isSegmented=[0 0 ];
resolutions=[0.0977 0.0977 ];
savedemodir='/home/webapps/develop/tmp/imageset/segmentation';
for i=1:length(dna_urls)
SegProg=SegProg+1; 
fid_prgs=fopen(progressfile,'w');
fprintf(fid_prgs,'%d',SegProg);
fclose(fid_prgs);
if ~isSegmented(i)
fullimg.nuc = []; 
fullimg.prot = []; 
fullimg.cell = []; 
try 
img=double(ml_readimage(dna_urls{i}));
fullimg.nuc=img;
catch 
continue; 
end 
try 
protimg=double(ml_readimage(prot_urls{i}));
fullimg.prot=protimg;
catch 
continue; 
end 
try 
cellimg=double(ml_readimage(cell_urls{i}));
fullimg.cell=cellimg;
catch 
continue; 
end 
resolution = resolutions(i);
[masks,mask_outline] = ml_segwrap(fullimg,segparams, resolution);
if ~length(masks) 
    fprintf(fid_SaveSql,'%s%d%s%d%s\n','insert into tblregion values(nextval(''region_seq''),',imageids(i),',',EMI,');');
   continue; 
end  
count_in=0;
TotalImageSeg = TotalImageSeg+1;
TotalMaskSeg = TotalMaskSeg+length(masks);
for j = 1:length(masks)
if firstMask 
fprintf(fid_Result,'<h5>Segmentation results are shown by superimposing images of dna (blue), protein (green) and mask (red).</h5><h5>If the segmenation result is satisfactory, you can start accessing the generated regions from the search page. If not satisfactory, please remove the segmentation by clicking the "discard" button.  </h5>\n'); 
fprintf(fid_Result,'<input type=submit value=discard>\n'); 
fprintf(fid_Result,'</FORM>\n'); 
fprintf(fid_Result,'<table>\n'); 
firstMask=0;
end 
    count_in = count_in+1;
databasename = 'develop3';
mask_name = ['/thumbnails/mask/imageset/seg_12,0,1,0,1,10,1,1','_',num2str(count_in),'_',num2str(imageids(i)),databasename, '.tif'];
imwrite (masks{j},mask_name,'tif');
singlecellimage = protimg;
singlecellimage(find(masks{j}==0))=0;
single_dna_image = img;
single_dna_image(find(masks{j}==0))=0;
[thum_url,jpg_url] = ml_getthumurl(prot_urls{i},mask_name);
[dna_thum_url,dna_jpg_url]=ml_getthumurl(dna_urls{i},mask_name);
ml_makedir(jpg_url);
ml_makedir(dna_jpg_url);
imwrite(mat2gray(singlecellimage),jpg_url,'jpg');
imwrite(mat2gray(single_dna_image),dna_jpg_url,'jpg');
singlecellthum=imresize(singlecellimage,40/size(singlecellimage,1));
single_dna_thum=imresize(single_dna_image,40/size(single_dna_image,1));
imwrite(mat2gray(singlecellthum),thum_url,'jpg');
imwrite(mat2gray(single_dna_thum),dna_thum_url,'jpg');
fprintf(fid_SaveSql,'%s%s%s%s\n','insert into tblmask values(nextval(''mask_seq''),','''',mask_name,''',null,null,71,1);');
fprintf(fid_SaveSql,'%s%d%s\n','insert into tblregion values(nextval(''region_seq''),',imageids(i),',currval(''mask_seq''));');
fprintf(fid_SaveSql,'%s%d%s\n','insert into tblregion values(nextval(''region_seq''),',dnaids(i),',currval(''mask_seq''));');
fprintf(fid_RmSql,'%s%s%s\n','update tblmask set generate_count=generate_count-1 where mask_url=''',mask_name, ''';');
fprintf(fid_RmSql,'%s%s%s\n','delete from tblregion where mask_id in (select mask_id from tblmask where mask_url=''',mask_name, ''' and generate_count=0);');
fprintf(fid_RmSql,'%s%s%s\n','delete from tblmask where mask_url=''',mask_name, ''' and generate_count=0;');
end
demo_tmp = ['/home/webapps/develop/tmp/imageset/segmentation/12,0,1,0,1,10,1,1_',num2str(imageids(i)),'.jpg'];
protimg=protimg/max(protimg(:));
finalimage(:,:,1)=mat2gray(mask_outline); 
finalimage(:,:,2)=mat2gray(protimg); 
finalimage(:,:,3)=mat2gray(img); 
imwrite (imresize(finalimage,180/size(finalimage,1)),demo_tmp,'jpg');
if mod(TotalImageSeg,ImgPerLine)==1 
    fprintf(fid_Result,'<tr><td><image src="http://pslid.cbi.cmu.edu:80/develop%s"> <br> Image Id=%d <hr></td>',demo_tmp(21+1:end),imageids(i));
elseif mod(TotalImageSeg,ImgPerLine)==2 
    fprintf(fid_Result,'<td><image src="http://pslid.cbi.cmu.edu:80/develop%s"> <br> Image Id=%d <hr></td>',demo_tmp(21+1:end),imageids(i));
elseif mod(TotalImageSeg,ImgPerLine)==0 
    fprintf(fid_Result,'<td><image src="http://pslid.cbi.cmu.edu:80/develop%s"> <br> Image Id=%d<hr></td></tr>\n',demo_tmp(21+1:end),imageids(i));
end 
else 
mask_hist = ml_dir(['/home/webapps/develop/tmp/imageset/segmentation/12,0,1,0,1,10,1,1_' num2str(imageids(i)) '.jpg']);
if ~length(mask_hist) 
    continue; 
end  
if firstMask 
fprintf(fid_Result,'<h5>Segmentation results are shown by superimposing images of dna (blue), protein (green) and mask (red).</h5><h5>If the segmenation result is satisfactory, you can start accessing the generated regions from the search page. If not satisfactory, please remove the segmentation by clicking the "discard" button.  </h5>\n'); 
fprintf(fid_Result,'<input type=submit value=discard>\n'); 
fprintf(fid_Result,'</FORM>\n'); 
fprintf(fid_Result,'<table>\n'); 
firstMask=0;
end 
TotalImageSeg = TotalImageSeg+1;
TotalMaskSeg = TotalMaskSeg+length(mask_hist);
for j= 1:length(mask_hist)
   if mod(TotalImageSeg,ImgPerLine)==1 
     fprintf(fid_Result,'<tr><td><image src="http://pslid.cbi.cmu.edu:80/develop%s/%s"> <br> Image Id=%d <hr></td>',savedemodir(21+1:end),mask_hist{j},imageids(i));
   elseif mod(TotalImageSeg,ImgPerLine)==2 
     fprintf(fid_Result,'<td><image src="http://pslid.cbi.cmu.edu:80/develop%s/%s"> <br> Image Id=%d <hr></td>',savedemodir(21+1:end),mask_hist{j},imageids(i));
   elseif mod(TotalImageSeg,ImgPerLine)==0 
      fprintf(fid_Result,'<td><image src="http://pslid.cbi.cmu.edu:80/develop%s/%s"> <br> Image Id=%d <hr></td></tr>\n',savedemodir(21+1:end),mask_hist{j},imageids(i)); 
   end 
end
end
end
if TotalMaskSeg==0 
   fprintf(fid_Result,'<input type=submit value=discard>\n'); 
   fprintf(fid_Result,'</FORM>\n'); 
  fprintf(fid_Result,'No mask was generated. Please change the parameter and try again'); 
else 
  if mod(TotalImageSeg,ImgPerLine)~=0 
    fprintf(fid_Result,'</tr>'); 
  end 
  fprintf(fid_Result,'</table>'); 
  fprintf(fid_Result,'<h5>Segmentation Summary: masks have been generated for %d out of %d images. </h5>\n',TotalImageSeg,2); 
end 
fprintf(fid_RmSql,'%s%d%s\n','delete from tblregion_generator where region_generator_id=71 and 1=(select count(*) from tblmask where generator_id =',71,');');
fprintf(fid_SaveSh,'/usr/bin/psql -U justin -f /home/webapps/develop/tmp/imageset/seg_x0x0jynOnex0x0__imageset_develop35C3EB4A202D3CD4918A356E1753BCC56.sql -d develop3\n');
fclose(fid_SaveSql);
fclose(fid_Result);
fclose(fid_RmSql);
fclose(fid_SaveSh);
unix(['sh ',saveshfile]);
unix(['rm ',saveshfile]);
unix(['rm ',savesqlfile]);
unix(['rm ',progressfile]);
unix('mv /home/webapps/develop/tmp/imageset/seg_x0x0jynOnex0x0__imageset_develop35C3EB4A202D3CD4918A356E1753BCC56_12,0,1,0,1,10,1,1.html /home/webapps/develop/tmp/imageset/segmentation/seg_x0x0jynOnex0x0__imageset_develop3_12,0,1,0,1,10,1,1.html');


