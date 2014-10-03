function match_mat = ml_match_hungarian (diff_mat,threshold)

% match_mat = ml_match_hungarian (diff_mat,threshold)
% this function picks up object pairs matching best in neighbor images
% This function implement the Hungarian's matching algorithm
% Input:
% diff_mat: distance matrix of objects
% threshold: a threshold for distance. objects from different imges
%            can not match if their distance is larger than the
%            threshold.
% Output:
% match_mat: a vector of indices of objects in the second
%            that matches the ones in the first image.

% Copyright (C) 2006  Murphy Lab
% Carnegie Mellon University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published
% by the Free Software Foundation; either version 2 of the License,
% or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.
%
% For additional information visit http://murphylab.web.cmu.edu or
% send email to murphy@cmu.edu

% Yanhua Hu, May 26, 2003

diff_mat(find (diff_mat > threshold))=NaN;
row_size = size (diff_mat,1);
col_size = size (diff_mat,2);

%make the smallest size as row
transposed=0;
if row_size > col_size 
    diff_mat=diff_mat';
    temp=row_size;
    row_size=col_size;
    col_size=temp;
    transposed=1;
end;

%max_match=row_size;
%NaN is automatically processed.

% covert the minimum cost problem to maximum benifit problem
diff_max= max(diff_mat (:))+1;
diff_mat=diff_max-diff_mat;

%the hungarian algorithm
lx=max(diff_mat,[],2);
ly=zeros(1,col_size);
for i=1:row_size
    for j=1:col_size 
	diff_mat(i,j) = lx(i)+ly(j)-diff_mat(i,j);
    end
end;
[cov,xSet,ySet,matchxy]=min_cover (diff_mat);
cov_pre=0;
while cov~=cov_pre
    
    cov_pre=cov; 
    %find the miminum non zero number that is not covered by xSet and ySet
    minNum=diff_max;
    for i=1:row_size
	for j=1:col_size
	    if and(and(not(ismember(i,xSet)),not(ismember(j,ySet))), diff_mat(i,j)<minNum)
		minNum=diff_mat(i,j);
	    end
	end 
    end
    
    %for every element in the mat:if both row and col is covered, add minNum
    %if both row and col is NOT covered, minus minNum
    for i=1:row_size
	for j=1:row_size
	    if and(ismember(i,xSet),ismember(j,ySet))
		diff_mat(i,j)=diff_mat(i,j)+minNum;
	    elseif not(or(ismember(i,xSet),ismember(j,ySet)))
		diff_mat(i,j)=diff_mat(i,j)-minNum;
	    end
	end
    end
    
    %change lx and ly: if x not covered, minus minNum
    % if y covered, add minNum
    for i=1:row_size
	if not(ismember(i,xSet))
	    lx(i)=lx(i)-minNum;
	end
    end
    
    for j=1:col_size
	if ismember(j,ySet)
	    ly(j)=ly(j)+minNum;
	end
    end
    
    %run cover program again
    [cov,xSet,ySet,matchxy]=min_cover(diff_mat);
end

%get the match_mat

if transposed
    if isempty(matchxy)
	match_mat=zeros(1,col_size);
    else
	for col=1:col_size
	    match_col= find(matchxy(:,2)==col);
	    if isempty (match_col)
		match_mat(col)=0;
	    else
		match_mat(col)=matchxy(match_col,1);
	    end
	end
    end
    
else
    if isempty(matchxy)  
	match_mat=zeros(1,row_size);
    else
	for row=1:row_size
	    match_row= find(matchxy(:,1)==row);
	    if isempty (match_row)
		match_mat(row)=0;
	    else
		match_mat(row)=matchxy(match_row,2);
	    end
	end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cov,xSet,ySet,matchxy] = min_cover (mat)
%this function finds the minimum coverage of matrix mat
% minimum coverage is defined as the minimum number of colomns or rows that cover all 0s.

row_size=size(mat,1);
col_size=size(mat,2);
mat=(mat==0); %turn 0 to 1, and other to 0
matchxy = max_match(mat);
cov=size(matchxy,1);
 
%the minimum cover number is equal to max match number
if isempty(matchxy)
    cov=0;
    xSet=[];
    ySet=[];
else
    xSet=matchxy(:,1);
    ySet=[];

    %if i is not in xSet but has a 0 in row i, col j, then add j to ySet
    %at the same time delete from xSet the row connedted to the j
    %do it cov times
    for t=1:size(mat,1)
	for i=1:row_size
	    if not(ismember(i,xSet))
		match_temp=find(mat(i,:)==1);
		f=0;
		for j=1:length(match_temp)
		    f=f+not(ismember(match_temp(j),ySet));
		    if f>0 break; end
		end
		if f==1
		    %add y to ySet
		    ySet=[ySet;match_temp(j)];
		    %delete the corrispondent x from xSet
		    for k=1:length(xSet)
			if mat(xSet(k),match_temp(j))==1
			    xSet(k)=[];
			    break;
			end
		    end
		end       
	    end
	end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = max_match (mat)
% max_match returns the maximum match for mat
%match in mat is 1 and non-match is 0

M=[];
U=[];
V=[];
row_size=size(mat,1);
col_size=size(mat,2);
xSet=zeros(1,row_size);
ySet=zeros(1,col_size);

%step one, if all x is labled nonzero in xSet, end
%otherwise, build U and V as following
for i=1:row_size
    if xSet(i)==0
	U=[i];
	V=[];
	N=[];%neighbor of U  
	
	%step3
	f=0;
	while f==0
	    %all the neighbor of U
	    for j=1:length(U)
		N=unique ([N,find(mat(U(j),:)==1)]);
		VNdiff=setdiff(N,V);
		%if not(isempty(VNdiff))
		%break;
		%end
	    end
	    
	    % V is same as N, lable xi as 2
	    if isempty(VNdiff)
		xSet(i)=2;
		f=1;
		% if V is not same as N  
	    else
		%%%first pick up P without conflicting, thus ySet(y)=0
		for h=1:length(VNdiff)
		    y=VNdiff(h);
		    if ySet(y)==0 break; end
		end
		
		if ySet(y)==1
		    %find the neighbor of this y and add it to U
		    %add y to V at the same time
		    for k=1:size(M,1)
			if M(k,2)==y
			    U=[U,M(k,1)];
			    V=[V,y];
			    break;
			end
		    end
		else 
		    %augmenting path P is (x1,y1,x2,y2...xn)
		    xSet(U(1))=1;
		    ySet(y)=1;
		    if length(V)>0
			V2=[V,y];
			M2=[U',V2'];
			U2=U;
			U2(1)=[];
			%M3=[U2;V];
			%M=setxor(M,union(M2,M3))
			t=1;
			while t<=size(M,1)
			    if ismember(M(t,1),U2)
				M(t,:)=[];
				t=t-1;
			    end
			    t=t+1;
			end
			M=[M;M2];
			f=1;
		    else
			M=[M;[U(1),y]];
			f=1;
		    end
		end
	    end %if
	end %while
    end %if
end %for



  
