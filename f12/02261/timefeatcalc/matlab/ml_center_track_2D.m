function [obj_mark_track,trajec]= ml_center_track_2D(match_mat,features)

% [obj_mark_track,trajec]= ml_center_track_2D(match_mat,features)
% From the  matching matrix infer the object trajectory
% match_mat: the matching matrix
% features: object features including position of each object
% obj_mark_track: position of each object over time
% trajec: objects trajectory and object properties

% Copyright (C) 2007  Murphy Lab
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

n=length(match_mat{2});
if n==0
    display('there is no objects in this time series');
end
%set the first colume to the object number
obj_mark_track=(1:n)';

% attach the second match_mat vector directly 
match_mat_copy=match_mat{2};
match_mat_copy(n)=0;

obj_mark_track=[obj_mark_track,match_mat_copy];

nline=n; % will increase for new objects

%now go through each pic and each object pair
%notice, in obj_mark_track: each row represent a actual object
% and the value is the matched obj mark in current image
% it is the record of how the mark of the object changes

for pic=3:length(match_mat)
  if isempty(match_mat{pic})
       obj_mark_track(nline,pic)=-1; %it is an empty image, no object
  else
    for pre_mark=1:length(match_mat{pic})
      curr_mark=match_mat{pic}(pre_mark);   
      % find the true idx of what's called pre_mark in pic-1
      true_ind=find(obj_mark_track(:,pic-1)==pre_mark);
  
      % if there is no couterpart in ture idx, treat it as a new
      if isempty(true_ind)
          nline=nline+1; % for new objects
          obj_mark_track(nline,pic-1)=pre_mark;
          obj_mark_track(nline,pic)=curr_mark;
      else
          obj_mark_track(true_ind, pic)=curr_mark;
      end 
    end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% build the trajectory, for each obj/each row  
for i=1:size(obj_mark_track, 1)  % i is the actual obj
   % it actually appeared in this time points
   t{i}=find(obj_mark_track(i, :)>0);
   if length(t{i})>1  % meaning it got a match
     for j=1:length(t{i})
     pic=t{i}(j);
     mark_pic = obj_mark_track(i, pic);
     areas{i}(j)=features{pic}(mark_pic,1);
     intens{i}(j)=features{pic}(mark_pic,2);
     x{i}(j)=features{pic}(mark_pic,3);
     y{i}(j)=features{pic}(mark_pic,4);
    
     end
     trajec{i}=[t{i};areas{i};intens{i}; x{i};y{i}]';
   end 
end

%%%%%%%%%%%  plot %%%%%%%%%%%%%%%%%% 
%figure();
%iv=1;
%while isempty(x{iv})
%     iv=iv+1;
%end

%plot3(x{iv},y{iv},t{iv});

%title ('object movement trajectory');
%xlabel('x axis');
%ylabel('y axis');
%zlabel('time point');
%grid on
     
%for i=2:size(obj_mark_track, 1)
%  hold on
%  if length(t{i})>1   
%   plot3(x{i}, y{i}, t{i})

%   hold on
%  end
%end
%hold off





