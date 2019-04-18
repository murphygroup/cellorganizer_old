function answer = demo3D24( options )
% demo3D24
%
% This demo converts a sample SBML file to an SBML-spatial instance using
% the "matchSBML" function. This function takes an SBML file, matches the
% compartments in the file with available models and synthesizes the
% appropriate instances.
%
% Input
% -----
% * sample SBML file
%
% Output
% ------
% * valid SBML model 

% Devin Sullivan
%
% Copyright (C) 2014-2017 Murphy Lab
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT MODIFY THIS BLOCK
if ~isdeployed()
  current_path = which(mfilename);
  [current_path, filename, extension] = fileparts( current_path );
  cd(current_path);
end

disp( 'demo3D24' );
warning('This demo is deprecated. The demo will be removed in future versions of CellOrganizer');
disp( 'The estimated running time is 1 minute. Please wait.' );

options.seed = 12345;
try
    state = rng( options.seed );
catch err
    rand( 'seed', options.seed ); %#ok<RAND>
end

options.targetDirectory = pwd;
options.numberOfSynthesizedImages = 1;
options.numberOfGaussianObjects = 1;
options.prefix = 'img';
options.compression = 'lzw';
options.microscope = 'none';
options.sampling.method = 'disc';
options.verbose = true;
options.debug = false;
options.output.tifimages = true;
options.rendAtStd = 1;
options.objstd = 1.1;
options.overlapsubsize = 1;

filename = 'Motivating_example_cBNGL2_13_sbml.xml';
url = 'http://www.cellorganizer.org/Downloads/files';

urlwrite([url filesep filename], filename);

if ~exist( filename )
    warning('Unable to download file. Exiting demo.' );
    return
end
options.output.SBML = 'Motivating_example_cBNGL2_13_sbml.xml';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK

% note, the framework will be synthesized using the first protein model
% found to match the given patterns in the SBML file.
% Changing the order/priority of this is not supported at this time.
modelpaths = {'../../../models/3D/tfr.mat'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

answer = slml2img(modelpaths,options);
end%demo3D24