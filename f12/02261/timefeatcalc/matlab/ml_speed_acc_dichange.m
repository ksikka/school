function [avg_spd, var_spd,avg_acc,var_acc,avg_dichange, var_dichange] ...
    = ml_speed_acc_dichange (trajec,scl,t)

% [avg_spd, var_spd,avg_acc,var_acc,avg_dichange, var_dichange] ...
%    = ml_speed_acc_dichange (trajec,scl,t)
% Calculate object tracking features from the trajectory of objects
% trajec: the trajectory of objects
% scl: the resolution of the image
% t : the time interval between images

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

% Yanhua Hu, 2007


spd=[];
acc=[];
dichange=[];
for i=1:length(trajec)  % for each object
    curInfo = trajec{i};
    if not(isempty(curInfo))
	interval = size(curInfo,1)-1;
	speedlist=[];
	LENlist =[];
	vctlist=[];
	for j=1:interval  % for each time point that this object exist
	    curLEN =((curInfo(j,4)-curInfo(j+1,4))^2+(curInfo(j,5)-curInfo(j+1,5))^2)^0.5;
	    LENlist(j)=curLEN; % distance moved during each interval
			       % vctlist is 2*interval 
            vctlist(:,j)=[(curInfo(j+1,4)-curInfo(j,4));(curInfo(j+1,5)-curInfo(j,5))];
	    curV= curLEN*scl/t;
	    speedlist(j)=curV; % velocity during each inteval
	    spd=[spd,curV];  % NOT same as speedlist, is a summary of ALL spd
	end
	
	if length(speedlist)>1
	    % acceleration
	    spd_dif=[speedlist,0]-[0,speedlist]; % V(n) -V(n+1)
	    spd_dif(end)=[];
	    spd_dif(1)=[];
	    acc=[acc,spd_dif/t];   % ALL acc  
				   % direction change        
	    drch_dif = sum([[1;1],vctlist].*[vctlist,[1;1]],1); %dot product
	    drch_dif(1)=[];
	    drch_dif(end)=[];
	    LENproduct=[1,LENlist].*[LENlist,1];
	    LENproduct(1)=[];
	    LENproduct(end)=[];
	    %acos is inverse cos
	    dichange=[dichange,acos(drch_dif./LENproduct)];
	end    
    end  
end
	     
avg_spd=mean(spd);
var_spd=var(spd);
avg_acc=mean(acc);
var_acc=var(acc);
avg_dichange=mean(dichange);
var_dichange=var(dichange);

