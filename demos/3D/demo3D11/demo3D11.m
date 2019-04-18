function answer = demo3D11( options )
% demo3D11
%
% Train 3D generative model of the cell framework (nucleus and cell shape)
% using the Murphy Lab 3D HeLa TfR dataset.
%
% Input 
% -----
% * a directory of raw or synthetic nucleus images
% * a directory of raw or synthetic cell shape images
% * the resolution of the images (all images should have the same
%   resolution)
%
% Output
% ------
% * a valid model

% Ivan E. Cao-Berg
%
% Copyright (C) 2012-2018 Murphy Lab
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

% May 15, 2013 @icaoberg Updated method to support wildcards
%
% February 2, 2016 @icaoberg Updated method to match the refactoring of
% CellOrganizer v2.5
%
% March 4, 2016 @icaoberg Updated method so that it saves the resolution
% of the image collection. It will also force the values for
% options.model.resolution and options.downsampling if the flag
% options.use_preprocessed_images is set to true
%
% February 16, 2017 @icaoberg Changed demo to use a single pattern from the 
% 3D HeLa dataset instead of the whole collection

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT MODIFY THIS BLOCK
if ~isdeployed()
  current_path = which(mfilename);
  [current_path, filename, extension] = fileparts( current_path );
  get_murphylab_image_collections( true );
  cd(current_path);
end

disp( 'demo3D11' );
disp( 'The estimated running time is 10 seconds. Please wait.' );

options.sampling.method = 'disc';
options.debug = true;
options.verbose = true;
options.display = false;
options.temporary_results = [ pwd filesep 'temporary_results' ];
options.downsampling = [5,5,1];
options = ml_initparam( options, struct( ...
    'train', struct( 'flag', 'framework' )));
options.model.filename = '3D_HeLa_framework.xml';

% generic model options
% ---------------------
options.model.name = '3d_hela_framework_model';
options.model.id = num2str(now);

% nuclear shape model options
% ---------------------------
options.nucleus.type = 'cylindrical_surface';
options.nucleus.class = 'nuclear_membrane';
options.nucleus.name = 'all';
options.nucleus.id = num2str(now);

% cell shape model options
% ------------------------
options.cell.type = 'ratio';
options.cell.class = 'cell_membrane';
options.cell.model = 'framework';
options.cell.id = num2str(now);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
options.model.resolution = [0.049, 0.049, 0.2000];
directory = '../../../images/HeLa/3D/processed/';

dimensionality = '3D';

for i = 1:15
    dna{i} = [directory filesep 'LAM_cell' num2str(i) '_ch0_t1.tif'];
    cellm{i} = [directory filesep 'LAM_cell' num2str(i) '_ch1_t1.tif'];
    protein{i} = [directory filesep 'LAM_cell' num2str(i) '_ch2_t1.tif'];
    options.masks{i} = [directory filesep 'LAM_cell' num2str(i) '_mask_t1.tif'];
end

% documentation
% -------------
options.documentation.author = 'Murphy Lab';
options.documentation.email = 'murphy@cmu.edu';
options.documentation.website = 'murphy@cmu.edu';
options.documentation.description = 'This is the framework model is the result from demo3D11.';
options.documentation.date = date;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

answer = img2slml( dimensionality, dna, cellm, [], options );
