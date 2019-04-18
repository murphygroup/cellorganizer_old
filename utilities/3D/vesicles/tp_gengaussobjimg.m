function [obj,protimg,newpos] = tp_gengaussobjimg( varargin )
% Generate a set of gaussian objects from the model
% Graphical Model: Y <-- X --> Z
%This method can be run in two modes. The mode is determined by the number
%of input arguments.
%
%If the variables protimg and newpos ARE NOT specified the function will
%generate gaussian discs saved as a cell array within the output 'obj'.
%These discs are sampled from the model mean and the generated cov. below.
%They are cut off at 2 standard deviations. protimgsampled will be returned
%[]
%
%If the variables protimg and newpos ARE specified, the function will
%return an image containing the sampled gaussians in the 'protimgsampled'
%image. 'obj' and img will be returned []

% Author: Tao Peng
%
% Copyright (C) 2008-2015 Murphy Lab
% Lane Center for Computational Biology
% School of Computer Science
% Carnegie Mellon University
%
% March 9, 2012 I. Cao-Berg Changed report of synthesized objects
% March ??, 2012 D. Sullivan
%   - added sampling method
%   - added direct object addition
%   - added trimmed method
% March ??, 2012 I. Cao-Berg Added varargin structure
% March 13, 2012 D. Sullivan
%   - added user specified sampling density as varargin{6}
%   - fixed trimmed contrast stretching
%   - fixed trimmed point mass
%   - fixed trimmed object 'add' instead of 'replace'
% March 25, 2012 D. Sullivan
%   - changed sampling method to be uniform random within vesicle rather
%   than gaussian
%   - restructured code to optimize efficiency
% August 4, 2012 D. Sullivan Removed "trimmed" method, no longer supported, fixed
%                            memory bugs
% August 4, 2012 D. Sullivan Moved object sampling inside for loop so that
%                            the objects don't have to be held in
%                            memory before being added
% August 4, 2012 D. Sullivan Added check that a sampled object is
%                            representative of the distribution
% August 7, 2012 D. Sullivan Reverted back to adding objects to the images
%                            after they were all sampled.
% July 23, 2013  D. Sullivan Changed x,y,z for sizes to sizex,sizey,sizez
%                            and kept them for each object created. These
%                            are then saved in a temporary file for
%                            primitive type output
% August 8, 2013 D. Sullivan & R. Arepally added support for primitives
% Sept 19, 2013 G. Johnson   Improved object placement to obey cell and
%                            nuclear boundaries on top and bottom of image
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

i = 1;

if(nargin<2)
    %icaoberg 8/6/2012
    error('Wrong number of input arguments');
end

model = varargin{1};
n = varargin{2};

probimg = varargin{3};
objectmethod = varargin{4};
%D. Sullivan 3/14/13 added param structure to list of varargin. need to
%call it before setting the param.samplingDensity
param = varargin{6};
param.samplingDensity = varargin{5};

param = ml_initparam(param, struct('debug', false));

param2 = param;

if isfield(param, 'overlapsubsize')
    overlapsubsize = param.overlapsubsize;
else
    overlapsubsize = 0.3;
end

if isfield(param, 'rendAtStd')
    param.objstd = param.rendAtStd;
else
    %icaoberg 12/11/2013
    param.objstd = 2;
    param.rendAtStd = 2;
end

if isfield(param, 'overlapthresh')
    param2.rendAtStd = param.overlapthresh;
    param2.objstd = param2.rendAtStd;
else
    param2.rendAtStd = 1;
    param2.objstd = 1;
end

if param2.rendAtStd == 0
    probinds = find(probimg > 0);
else
    %D. Sullivan 10/25/14
    %We care about object overlap
    %let's make a little padding near the border of the cell and nucleus
    %that cannot contain objects
    %first we must binirize the image
    binimg = probimg>0;
    %Then pad the cell - this allows edges up against image border to be
    %eroded
    padsize = 3;
    binpadimg = padarray(binimg,[padsize,padsize,padsize]);
    %Then we erode the image slightly
    %For now we will use 1% of the cell size
    erodeSize = ceil(max(size(probimg))*0.005);
    se = strel('disk',erodeSize);
    erodeimg = imerode(binpadimg,se);
    %remove padding
    erodeimg = erodeimg(padsize+1:size(erodeimg,1)-padsize,padsize+1:size(erodeimg,2)-padsize,padsize+1:size(erodeimg,3)-padsize);
    %mask image with original
    probimg = probimg.*erodeimg;
    
    
end

imsize = size(probimg);
protimg = zeros(imsize);

placeimg = probimg > 0;
boundsub = imresize(probimg > 0, overlapsubsize, 'bilinear');

try
    debug = param.debug;
catch
    debug = false;
end

%icaoberg 8/6/2012
clear varargin;


if ~(strcmpi(objectmethod,'sampled')|| ...
        strcmpi(objectmethod,'disc'))
    warning('CellOgranizer: Unrecognized object fill method, defaulting to disc');
    objectmethod = 'disc';
end

obj = [];
img = [];

%fprintf( 1, '%s%%', '0');

%devins 8/6/2012
%D. Sullivan 3/14/13 changed to normal param structure
% paramobj.imagesize = size(protimg);
param.imagesize = size(protimg);
invalid_objs = 0;

newpos = zeros(n, ndims(probimg));

% devins 8/7/2012
% while i < n
%changed from i<n to i<=n
sizex = zeros(1,n);
sizey = zeros(1,n);
sizez = zeros(1,n);
objrotvec = zeros(n,3);
objsizevec = zeros(n,3);

successes = 0;
total_failures = 0;
failures = 0;

while i <= n
    % Generate covariance matrices
    PofSizex=0;
    PofSizey=0;
    PofSizez=0;
    objtry = -1;
    while ( PofSizex < 0.1 || PofSizex > 0.9 || PofSizey < 0.1 ||...
            PofSizey > 0.9 ||PofSizez < 0.1 || PofSizez > 0.9 )
        objtry = objtry+1;
        
        sizex(i) = ml_rnd(model.x);
        %x = 2;
        model.y_x.mu = model.y_x.a1*(1-exp(-model.y_x.b1*sizex(i)));
        model.z_x.mu = model.z_x.a1*(1-exp(-model.z_x.b1*sizex(i)));
        model.y_x.sigma = model.y_x.a2*(1-exp(-model.y_x.b2*sizex(i)));
        model.z_x.sigma = model.z_x.a2*(1-exp(-model.z_x.b2*sizex(i)));
        sizey(i) = ml_rnd(model.y_x);
        sizez(i) = ml_rnd(model.z_x);
        
        %D. Sullivan 11/3/14 - this is getting pulled out to after cubic
        %%%
        %         newSigma = diag([sizex(i) sizey(i) sizez(i)].^2);
        
        %resizing
        %         objsizevec(i,:) = ceil(param.rendAtStd * sqrt(diag(newSigma)))';
        %         objsizevec(i,:) = (param.rendAtStd * sqrt(diag(newSigma)))';
        
        %D. Sullivan 4/15/14
        %Check that the object will be at least 1 pixel in the image - this
        %is to ensure the object overlap code works(with no downsampling).
        %         if any(objsizevec(i,:)<0.5)
        %             toosmall = 1
        %             continue
        %         end
        %if any of the sigmas are less than 1 pixel, set them to 1.
        %this prevents point masses
        %         if(sum(newSigma(newSigma>0)<1)>0)
        %             newSigma(newSigma~=0&newSigma<1) = 1;
        %         end
        %%%
        
        PofSizex = logncdf(sizex(i),model.x.mu,model.x.sigma);
        PofSizey = normcdf(sizey(i),model.y_x.mu,model.y_x.sigma);
        PofSizez = normcdf(sizez(i),model.z_x.mu,model.z_x.sigma);
        
    end
    
    %11/3/14 - D. Sullivan, We need to adjust the objects to be in a cubic
    %voxel space before rotating them and inserting them into the image
    %Note: The cell and nucleus are already in the cubic space - see
    %model2instance (~line 225)
    if isfield(param,'cubicOverride') && param.cubicOverride
        %This option is not recommended and issues a warning in
        %model2instance
    else
        sizex(i) = sizex(i).*(param.resolution.objects(1)/param.resolution.cubic(1));
        sizey(i) = sizey(i).*(param.resolution.objects(2)/param.resolution.cubic(2));
        sizez(i) = sizez(i).*(param.resolution.objects(3)/param.resolution.cubic(3));
    end
    
    newSigma = diag([sizex(i) sizey(i) sizez(i)].^2);
    %save the object sizes (for SBML-spatial)
    objsizevec(i,:) = (param.rendAtStd * sqrt(diag(newSigma)))';
    
    %if any of the sigmas are less than 1 pixel, set them to 1.
    %this prevents point masses
    %D. Sullivan 11/3/14 - this is done after the size saving since the
    %real sizes are in continuous space and thus may be smaller than 1voxel
    if(sum(newSigma(newSigma>0)<1)>0)
        newSigma(newSigma~=0&newSigma<1) = 1;
    end
    
    %grj 6/30/13 move rotation code out of build-a-valid-gaussian loop.
    % Random rotation
    t = rand * pi;
    Rx = [1 0 0;0 cos(t) -sin(t);0 sin(t) cos(t)];
    t = rand * pi;
    Ry = [cos(t) 0 sin(t);0 1 0;-sin(t) 0 cos(t)];
    t = rand * pi;
    Rz = [cos(t) -sin(t) 0;sin(t) cos(t) 0;0 0 1];
    R = Rz*Ry*Rx;
    newCov = R*newSigma*R';
    
    %8/8/13 D. Sullivan & R. Arepally recovered the per-axis rotations for
    %primitive representations into mat files.
    %decompose rotation matrix
    thetax = atan2(R(3,2),R(3,3));
    thetay = atan2(-R(3,1),sqrt(R(3,2)^2+R(3,3)^2));
    thetaz = atan2(R(2,1),R(1,1));
    %Convert to degrees
    objrotvec(i,:) = [thetax,thetay,thetaz].*(180/pi);
    
    if i ==0
        i = 1;
    end
    
    invalid_objs = invalid_objs+objtry;
    %generate gaussian object (vesicle)
    %     obj{i} = ml_gaussobj(newCov,param);
    
    %     if(sizez(i)<0)
    %         wait = 1;
    %     end
    
    %     objsizevec(i,:) = ceil(param.objstd * sqrt(diag(newCov)))';
    %D. Sullivan 4/29/14 - make sure we have a legal Cov.
    if ~isreal(eig(newCov))
        disp('Attempted to sample non-real covariance, trying again.')
        continue
    end
    obj{i} = ml_gaussobj(newCov, param);
    
    
    %      obj = ml_gaussobj(newCov,paramobj);
    if (strcmpi(objectmethod,'sampled'))
        numsamples{i} = ceil(param.samplingDensity*sum(abs(newCov(:))));%c*inten_coeff;
        %randomly sample the multivariate gaussian
    end
    
    if param2.rendAtStd > 0
        %         objerode = padarray(ml_gaussimg(newCov, param2)>0);
        %D. Sullivan 5/28/14 added padding to allow for proper sub-sampling
        objerode = padarray(ml_gaussimg(newCov, param2)>0,[2,2,2]);
        %         objbound = ml_gaussimg(newCov, param)>0;
        objbound = padarray(ml_gaussimg(newCov, param)>0,[2,2,2]);
        %         objerode = ml_gaussimg(newCov, param)>0;
        %         objbound = ml_gaussimg(newCov, param2)>0;
        
        
        placesub = imresize(logical(placeimg), overlapsubsize, 'bilinear');
        
        probsub = imresize(probimg,overlapsubsize, 'bilinear');
        
        objerodesub = imresize(objerode,overlapsubsize, 'bilinear');
        objboundsub = imresize(objbound, overlapsubsize, 'bilinear');
        %         size(objerodesub)
        if sum(objerodesub(:))==0
            noobject = 1;
            adjustedsubsize = min(1./size(objerode(1:2)));
            objerodesub = imresize(objerode,adjustedsubsize, 'bilinear');
            objboundsub = imresize(objbound, adjustedsubsize, 'bilinear');
            newpos(i,:) = findObjFit( placesub, boundsub, probsub, objerodesub, objboundsub) .* [(1/adjustedsubsize), (1/adjustedsubsize), 1];
        else
            newpos(i,:) = findObjFit( placesub, boundsub, probsub, objerodesub, objboundsub) .* [(1/overlapsubsize), (1/overlapsubsize), 1];
            %             newpos(i,:) = findObjFit( placesub, boundsub, probsub, objerodesub, objerodesub) .* [(1/overlapsubsize), (1/overlapsubsize), 1];
        end
        %         if size(objerodesub)<1
        %             noobject = 1
        %         end
        
        %return and grab a new object if this one doesnt fit
        if any(newpos(i,:) <= 0 )
            failures = failures + 1;
            continue;
        end
        
        objsize = size(objerode);
        [x,y,z] = ind2sub(objsize, find(objerode > 0));
        
        pos = round([x,y,z] + repmat(-objsize/2 + newpos(i,:), [length(x),1]));
        
        %remove any pixels that are oob by rounding error
        pos(any(pos <= 0 | pos>repmat(imsize, [size(pos,1),1]),2),:) = [];
        
        ind = sub2ind(imsize, pos(:,1), pos(:,2), pos(:,3));
        
        %remove the new object from our set of legal placements
        if any(placeimg(ind)==0)
            if param.debug
                disp('Illegal object generated. Trying again.');
            end
            %             i = i-1;
            continue
            %             shit = 1
        end
        placeimg(ind) = 0;
    else
        ind = randsample(probinds, 1, true, probimg(probinds));
        [y, x, z] = ind2sub(size(probimg), ind);
        
        newpos(i,:) = [y,x,z];
    end
    
    i = i+1;
    successes = successes + 1;
    total_failures = total_failures + failures;
    if failures == 0
        disp( [ 'Generated object ' num2str( i-1 ) '' ] );
    else
        if failures > 1
            disp( [ 'Generated object ' num2str( i-1) '. Failed to make object ' num2str(failures) ' times' ] );
        else
            disp( [ 'Generated object ' num2str( i-1 ) '. Failed to make object ' num2str(failures) ' time' ] );
        end
    end
    failures = 0;
end

disp( [ 'On average there were ' num2str(total_failures/n) ' failures per object.' ] );

%fprintf( 1, '%s\n', '' );

%D. Sullivan 7/23/13 added objsizevec for blender primitive generation
% if isfield(param.output,'primitives') && param.output.primitives==true
% objsizevec = imsize;
objposvec = [newpos(:,2),newpos(:,1),newpos(:,3)];
% objsizevec = objsizevec.*repmat(model.resolution,[size(objsizevec,1),1]);
%save the objectsizevector in the temp results
%8/8/13  D. Sullivan & R. Arepally added collection of object primitives
save([param.temporary_results filesep 'primitives' ...
    num2str(param.currentmodelnum) '.mat'],'objsizevec','objposvec','objrotvec');
clear objsizevec
clear objposvec
clear objrotvec
clear imsize

%devins 8/7/2012 reverted back to adding objects after they were sampled
if(strcmpi(objectmethod,'disc'))
    protimg = ml_imaddobj2(protimg,obj,...
        struct('method','replace','pos',newpos,'objectmethod',objectmethod));
elseif(strcmpi(objectmethod,'sampled'))
    %properly fill the vesicles based on the method
    paramsampling = struct('method','add','pos',newpos,...
        'objectmethod',objectmethod);
    paramsampling.numsamplescell = numsamples;
    protimg = ml_imaddobj2(protimg,obj,paramsampling);
    
end

%devins 8/6/2012
if debug
    disp(['The number of invalid objects was: ' num2str(invalid_objs)]);
end
%

%do the contrast stretching before converting to uint8
protimgtmp = ml_bcimg(protimg,[],[0 255]);
protimg = uint8(protimgtmp);
