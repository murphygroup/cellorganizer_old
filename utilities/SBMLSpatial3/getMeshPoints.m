function FV = getMeshPoints(image,savepath)
%GETMESHPOINTS This function gets mesh points given an image
%
%Inputs: 
%image = a 2D or 3D image 
%
%Outputs:
%FV = a struct containing the vertices etc for the mesh
%

%Author: Devin Sullivan September 19,2013
% Copyright (C) 2012 Murphy Lab
% Lane Center for Computational Biology
% School of Computer Science
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

if nargin<2
    savepath = pwd;
end

%Parameters
%%%
padAmount = 3;%This creates padding to close the sides, top and bottom of the mesh
%ideally this would be resolution dependent
 blurAmount = 11;%This smooths the image slightly to create a more smoothed mesh and reduce artifacts from pixelization
%This value was empirically chosen for the HeLa data, but may be different
%for different membrane properties, resolutions etc
patchsample = 0.05;%This is the amount of sub-sampling to be done. 
isopatch = 0.9;
%%%

disp('entering mesh code.')
%First trim the image to ensure we will not mesh things we don't need to.
%image2 = image;
xvals = find(sum(sum(image,3),1));
yvals = find(sum(sum(image,3),2));
zvals = find(sum(sum(image,1),2));
disp('trimming image')
image = image(min(yvals):max(yvals),min(xvals):max(xvals),min(zvals):max(zvals));
%Keep track of how much is cut off by this 

disp('padding image')
%need to pad the image so that the isosurface has no holes
image = padarray(image,[padAmount,padAmount,padAmount]);

%Smooth the image a little, should probably not hard code 11.
disp('smoothing image')
 D = smooth3(squeeze(image),'gaussian',[blurAmount,blurAmount,blurAmount]);
%D = image;
   % D = image;
disp('making grid')
    [x,y,z] = meshgrid(1:size(image,2),1:size(image,1),1:size(image,3));
%     x = x-mean(x(:));
%     y = y-mean(y(:));
%     z = z-size(image,3);%mean(z(:));
%     v = D;
    
    %make iso-surface (Mesh) of skin
    %should not hard code this.
%     patchsample = 0.05;

    save([savepath,filesep,'temp',filesep,'D.mat'],'D')
    disp('creating mesh')
    FV = isosurface(D,isopatch);
    disp('adjusting mesh')
    %Shift the vertices back to where they're supposed to be so they line
    %up with the objects inside the cell.
    %add the amount of shift, and subtract the padding
    %get the top value of the real image
    %Must subtract 1 from them to create zero indexing 
    topval = [max(xvals)-1,max(yvals)-1,max(zvals)-1];
    shift = round(max(FV.vertices)-topval);
    FV.vertices(:,1) = FV.vertices(:,1)-shift(1);
    FV.vertices(:,2) = FV.vertices(:,2)-shift(2);
    FV.vertices(:,3) = FV.vertices(:,3)-shift(3);
    
    
    % FV.vertices = FV.vertices-repmat(shiftvector_flag,size(FV.vertices,1),1);
     FV = reducepatch(FV,patchsample);
