function Train(dnapath,cellpath,protpath,croppath,resolution,filename,dimensionality,isdiffeomorphic)
% Training template
%
% Trains a generative model of protein location
% Results will be one .mat file containing a CellOrganizer model
%
% Inputs: 
% Here, paths include wild card characters for reading multiple images
% dnapath - path to the directory where your dna images are stored.
% cellpath - path to the directory where your cell images are stored.
% protpath - path to the directory where your protein images are stored.
% croppath - path to the directory where your cropped images are stored.(if
%            you don't wish to use crops pass [])
% resolution - the resolution at which the images were acquired.
% filename - string where you would like the model to be saved.
% dimensionality - string ('2D','3D') tells the model what dimension the
% data is
%
% Outputs: 
% name.mat file containing a CellOrganizer model
%
% Example:
% (if running from this dir)
% directory = '/Users/me/myimages/'
% dna = [ directory filesep 'orgdna' filesep '*.tif' ];
% cell = [ directory filesep 'orgcell' filesep '*.tif' ];
% protein = [ directory filesep 'orgprot' filesep '*.tif' ];
% resolution = [ 0.049, 0.049 ];
% filename = './mymodel';
% Train2D(dna,cell,protein,resolution,filename)

% Author: Devin Sullivan 5/16/13
%
% Edited: 
% D. Sullivan 5/18/13 - added croppath to allow user to pass in a cropped
% image.
%
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
%
% For additional information visit http://murphylab.web.cmu.edu or
% send email to murphy@cmu.edu

% curr_path = which('demo2D01.m');
% curr_path = curr_path(1:end-10);
% cd(curr_path);

clc;
tottime = tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAM STRUCTURE DEFINITION
%For this template, all fields are set, with default values indicated where
%appropriate

%Initialize param structure
param = [];

%%%%%%%%%
%REQUIRED FIELDS

%names the output file
options.model.filename = [ filename '.xml' ];

%specifies the resolution
options.model.resolution = resolution;
%%%%%%%%%

%%%%%%%%%
%DEFAULTED FIELDS
%Fields which have specific default values 

%Specifies downsampling for training 
if ~exist('dimensionality','var')
    %if only 2 resolution points specified, it's 2D
    if length(resolution==2)
        dimensionality = '2D';
    elseif length(resolution==3)
        dimensionality = '3D';
    else
        error('unsupported number of resolution dimensions');
    end
end
if strcmpi(dimensionality,'2D')
    options.downsampling = [1,1];%default is [1,1] in 2D 
end
if strcmpi(dimensionality,'3D')
    options.downsampling = [5,5,1];%default is [5,5,1] in 3D 
end

%Specifies the amount to upsample the z dimension when protein model
%training (the reason for wanting to do this is to make cubic voxels 
% options.model.proteinUpsampleZ = 5; it is ignored if not specified

if ~exist('isdiffeomorphic', 'var') || ~isdiffeomorphic
    %Specifies the type of nuclear model to train
    options.nucleus.type = 'cylindrical_surface';%('medial axis','diffeomorphic'), default='medial axis'

    %Specifies the type of cell model to train
    options.cell.type = 'ratio';%('ratio','diffeomorphic'), default='ratio'
else
    %Specifies the type of nuclear model to train
    options.nucleus.type = 'diffeomorphic';%('medial axis','diffeomorphic'), default='medial axis'

    %Specifies the type of cell model to train
    options.cell.type = 'diffeomorphic';%('ratio','diffeomorphic'), default='ratio'
end

%Specifies the type of protein model to train
options.protein.type = 'vesicle';%('vesicle'), default='vesicle'

%Specifies the allowable compartments to train the protein model
%Note: because we use local thresholds, this is recommended even if there is
%very little signal in a compartment 
options.protein.cytonuclearflag = 'cyto';%('cyto,'nuc','all'), default='cyto'

%Prints messages about the status of the training
options.verbose = false;%(true,false), default=true

%Prints intermediate results to the screen, keeps temp files and prints
%stack if the training crashes
options.debug = true;%(true,false), default=false

%Specifies which patterns within a dataset to train on
%if 'nuclear', only a nuclear model is trained.
%if 'framework', only a framework(nuclear+cell) model is trained.
%if 'all', nuclear, cell and protein models are trained
options.train.flag = 'all';%('all','nuclear','framework'), default = 'all'

%This parameter is used if you have preprocessed masks you would like to
%use for making segmentation faster. If it is not provided it is ignored
if ~isempty(croppath)
options.masks = croppath;%Any string with wild cards default = []
end
%%%%%%%%%

%%%%%%%%%
%OPTIONAL FIELDS
%Fields which otherwise are ignored and not included in the final model
%These are all for documentation only and do not affect the outputs of the
%model. They are meant for maintaining a record of what the model is and
%who built it for other users 

%Specifies the name of the model
options.model.name = 'mymodel';%Any string,

%Specifies the id of the model
options.model.id = 'mymodel';%Any string,

%All of these name/id the specified component of the model
%they may be Any string
% options.nucleus.name
% options.nucleus.id
% options.cell.name
% options.cell.id
% options.protein.name
% options.protein.id 

%Names the class of proteins
%options.protein.class = [];%Any string

%Name of the author
%options.documentation.author = [];%Any string

%Email adress of author
%options.documentation.email = [];%Any string


%If the output model file is found, it will tell you and skip the training
if ~exist( [pwd filesep lower(filename) '.mat'] )
    %Check that the directory where we are putting the outputs exists
    %If not, make it
    %get folder divisions in the filepath
    dirseparators = find(filename==filesep);
    %If there aren't any it will save the file in the current directory, so
    %go ahead with model building
    if ~isempty(dirseparators)
      %Find the last one and separate the previous part of the path from
      %the file name
      savedir = filename(1:dirseparators(end));
      %Check if the save dir exists, if not create it
      if ~exist(savedir)
          mkdir(savedir);
      end
    end 
    img2slml( dimensionality, dnapath, cellpath, protpath, param );
else
    disp( 'Model found. Skipping recalculation.' );
end
toc(tottime);