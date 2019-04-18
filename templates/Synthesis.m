function Synthesis(modelPath,savePath,numSynthImgs)
% Synthesis template 
%
% Synthesize image(s) from user specified models, 
% Results will be TIFF file(s). 
%   - In the 2D case there will be one file per cell where slices for 
%     cell boundary, nuclear boundary, and subsequent protein pattern.
%   - In the 3D case there will be a separate multi-tif image for each
%     "channel" in the image (nuc,cell,protein1,protein2,...)
%
% Inputs: 
% modelPath - cell array of path to the mat file(s) containing the model(s)
% you wish to synthesize. For multiple models use a cell array of models
% savePath - path of the directory you wish to save results in
% numSynthImgs - number of images to synthesize from this model, if blank
% will default to 1
% Note: The framework model will be taken from the first model specified in
% the list.
%
% Outputs: 
% Tiff images of the synthesized patterns
%
% Example:
% (if running from this dir)
% Synth2D({'../../models/2D/lysosomes.mat'},'./myimages')

% Author: Devin Sullivan 5/15/13
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

%Sets the random seed.
%%
%Note: comment out this code to get a different result each time
try
 state = rng(12345);
catch err
 state = RandStream.create('mt19937ar','seed',3);
 RandStream.setDefaultStream(state);
end
%%

%Check for a place to put the results.
%If no savePath specified, use pwd.
%If savePath specified by does not exist, create it
if ~exist('savePath','var')
    savePath = pwd;
elseif ~exist( savePath, 'dir' )
  mkdir( savePath );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAM STRUCTURE DEFINITION
%For this template, all fields are set, with default values indicated where
%appropriate

%Initialize param structure
param = [];

%%%%%%%%%
%REQUIRED FIELDS
%There are no required parpam fields for synthesis
%%%%%%%%%

%%%%%%%%%
%DEFAULTED FIELDS
%Fields which have specific default values 

%folder where your results will be saved
param.targetDirectory = savePath;%Any string, defualt='./' (passed by user)

%subfolder for each job ID 
param.prefix = 'synthimages';%Any string, default='demo'

%number of images to synthesize
%Any integer, default=1 (passed by user)
if ~exist('numSynthImgs','var')
    param.numberOfSynthesizedImages = 1;
else
    param.numberOfSynthesizedImages = numSynthImgs;
end

%specifies any compression you want
%recommended 'lzw' for 3D images
param.compression = 'lzw';%('none','lzw','packbits'), default='none'

%Displays intermediate results and additional messages on screen.
%Will also print the stack if your job crashes. Once you are sure your
%model works change to 'false' for fewer messages and faster run times.
param.debug = false;% (true,false), default=false

%Whether to display the final results after synthesis
param.display = false;% (true,false), default=false

%Displays intermediate messages to let you know what your job's stat us
%while running
param.verbose = true;%(true,false), default=true

%Allows for precomputed microscope psf to be used
param.microscope = 'none';%('none','lzw'), default='none'

%Specifies which type of synthesis to do.(nuc only,nuc+cell,nuc+cell+prot)
param.synthesis = 'all';%('nuclear','framework','all'), default='all'

%Specifies the output type where 'disc' is volumetric, and 'sampled' is
%individual particles within the volume
param.sampling.method = 'disc';%'(disc','sampled'), default='disc'


%%%%%%%%%

%%%%%%%%%
%OPTIONAL FIELDS
%Fields which otherwise are ignored

%Specifies the resolution of the cell model(in um). 
%Only used if the model has no resolution associated with it 
%resolution.cell = [0.2,0.2,0.2];

%Specifies the resolution of the object model(in um). 
%Only used if the model has no resolution associated with it 
%resolution.objects = [0.2,0.2,0.2];

%Specifies what type(s) of output to create
%param.output
%If no types are specified, tifimages will be set to true
%
%Specifies whether or not to create tif images
%param.output.tifimages = true;(true,false),special default=true (only when
%                         all other outputs are false
%
%Specifies whether or not to create blenderfiles
%param.output.blenderfile = true;(true,false)

%Special Blenderfile params for syn2blender(demo3D13)
%
%Specifies the fratction of the original resolution at 
%Required if param.output.blenderfile is true
%param.blender.downsample = 5;Any double (5=5x as small)
%
%What fraction of the meshvertices to save in the obj file. 
%param.blender.patchsample = 0.05;Any double<1 
%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%The main function call
slml2img( modelPath, param );

