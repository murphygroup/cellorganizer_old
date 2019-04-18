function answer = demo3D12( options )
% demo3D12
%
% Train 3D generative model of the nucleus, cell shape, and lysosome using
% 30 LAMP2 images in the Murphy Lab 3D HeLa dataset.
%
% Input 
% -----
% * a directory of raw or synthetic nucleus images
% * a directory of raw or synthetic cell shape images
% * a directory of raw or synthetic lysosome images
% * the resolution of the images (all images should have the same
%   resolution)
%
% Output
% ------
% * a valid SLML model file

% Ivan E. Cao-Berg
%
% Copyright (C) 2012-2017 Murphy Lab
% Computational Biology Department
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

% July 27, 2012 I. Cao-Berg Modified demo so that it looks for framework.mat in the current directory as well as in the demo3D11 folder
%
% July 30, 2012 I. Cao-Berg Fixed a bug in the method that would not set theocation of the framework file is the number of input
%                           arguments was not zero
%               I. Cao-Berg Fixed model parameter that describes pattern name
%               I. Cao-Berg Fixed cytonuclearflag so that it is set to be nuclear when the nucleoli pattern is selected
%
% July 31, 2012 I. Cao-Berg Fixed model.proteinModel.class that was set to lysosome for all patterns
%
% Jan 20, 2012 I. Cao-Berg Updated method so that if decompressed folder is
%                          found, it skips decompression of the tarballs
%
% May 15, 2013 I. Cao-Berg Updated method to support wildcards
%
% March 17, 2014 I. Cao-Berg Updated method so that 3D nuclear models types
%                             is labelled 'cylindrical_surface'
%
% April 24, 2014 I. Cao-Berg Fixed bug where it trying to load the
% framework from the models folder instead of the demo3D11 folder
%
% February 3, 2016 I. Cao-Berg Fixed small bug that would not allow the
% demo to download the image collection if the compressed file was present
% somewhere else in the working path
%
% March 9, 2016 I. Cao-Berg Fixed problem where resolution was not set and
% thus method would fail

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT MODIFY THIS BLOCK
if ~isdeployed()
  current_path = which(mfilename);
  [current_path, filename, extension] = fileparts( current_path );
  get_murphylab_image_collections( true );
  cd(current_path);
end

disp( 'demo3D12' );
disp( 'The estimated running time is 12 minutes. Please wait.' );

pattern = 'LAMP2';
dimensionality = '3D';

% generic model options
% ---------------------
options.model.name = 'all';
options.model.id = num2str(now);

% nuclear shape model options
% ---------------------------
% nucleus.type              Holds the nuclear model type. Default is "cylindrical_surface".
options.nucleus.type = 'cylindrical_surface';
options.nucleus.class = 'nuclear_membrane';
options.nucleus.id = num2str(now);

% cell shape model options
% ------------------------
options.cell.type = 'ratio';
options.cell.id = num2str(now);
options.cell.class = 'cell_membrane';

% protein shape model options
% ---------------------------
% protein.type              (optional) Holds the protein model type. The default is "vesicle".
options.protein.type = 'gmm';
options.protein.class = 'vesicle';
options.protein.id = num2str(now);

% protein.cytonuclearflag   (optional) Determines whether the protein pattern will be generated in
%                           the cytosolic space ('cyto'), nuclear space ('nuc') or everywhere ('all').
%                           Default is cyto.
if strcmpi( options.protein.class, 'vesicle' )
    options.protein.cytonuclearflag = 'nuc';
else
    options.protein.cytonuclearflag = 'cyto';
end

% other options
% -------------
options.verbose = true;
options.debug = false;

% documentation
% -------------
options.documentation.description='This model has been trained using demo3D12 from CellOrganizer';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
directory = '../../../images/HeLa/3D/processed';
for i = 1:10
    dna{i} = [directory filesep 'LAM_cell' num2str(i) '_ch0_t1.tif'];
    cellm{i} = [directory filesep 'LAM_cell' num2str(i) '_ch1_t1.tif'];
    protein{i} = [directory filesep 'LAM_cell' num2str(i) '_ch2_t1.tif'];
    options.masks{i} = [directory filesep 'LAM_cell' num2str(i) '_mask_t1.tif'];
end
options = ml_initparam( options, struct( ...
    'train', struct( 'flag', 'all' )));
options.model.resolution=[0.049, 0.049, 0.2000];
options.model.filename = 'LAMP2.xml';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

answer = img2slml( dimensionality, dna, cellm, protein, options );