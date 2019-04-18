% Ivan E. Cao-Berg
%
% Copyright (C) 2019 Murphy Lab
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

classdef test_pca_001 < matlab.unittest.TestCase
    properties
    end

    methods (Test)
        function test_basic_run( testCase )
          options.verbose = true;
          options.debug = true;
          options = ml_initparam( options, struct( ...
          'train', struct( 'flag', 'framework' )));
          options.nucleus.class = 'framework';
          options.nucleus.type = 'pca';
          options.cell.class = 'framework';
          options.cell.type = 'pca';

          % latent dimension for the model
          options.latent_dim = 15;
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

          % the following list of parameters are adapted to the LAMP2 image
          % collection, modify these according to your needs
          directory = '../images/HeLa/2D/LAM/';
          dna = {}; cellm = {}; options.masks = {};
          for i=1:1:10
            dna{length(dna)+1} = [ directory filesep 'orgdna' filesep 'cell1.tif' ];
            cellm{length(cellm)+1} = [ directory filesep 'orgcell' filesep 'cell1.tif' ];
            options.masks{length(cellm)+1} = [ directory filesep 'crop' filesep 'cell1.tif' ];
          end

          options.model.resolution = [ 0.049, 0.049 ];
          options.model.filename = 'model.xml';
          options.model.name = 'lamp2';
          %set nuclei and cell model name
          options.nucleus.name = 'LAMP2';
          options.cell.model = 'LAMP2';
          dimensionality = '2D';
          answer = img2slml( dimensionality, dna, cellm, [], options );
          end
    end
end
