% Ivan E. Cao-Berg
%
% Copyright (C) 2018 Murphy Lab
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

classdef test_train_flag13 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            disp( 'demo2D05' );
            disp( 'The estimated running time is 1 minutes. Please wait...' );
            options.verbose = true;
            options.debug = false;
            options.display = false;
            options.model.name = 'demo2D05';
            options.train.flag = 'framework';
            options.nucleus.class = 'nuclear_membrane';
            options.nucleus.type = 'pca';
            options.cell.class = 'cell_membrane';
            options.cell.type = 'ratio';

            % latent dimension for the model
            options.latent_dim = 15;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % the following list of parameters are adapted to the LAMP2 image
            % collection, modify these according to your needs
            directory = '../../../images/HeLa/2D/LAM/';
            dna = [ directory filesep 'orgdna' filesep 'cell*.tif' ];
            cellm = [ directory filesep 'orgcell' filesep 'cell*.tif' ];
            options.masks = [ directory filesep 'crop' filesep 'cell*.tif' ];

            options.model.resolution = [ 0.049, 0.049 ];
            options.model.filename = 'lamp2.xml';
            options.model.id = 'lamp2';
            options.model.name = 'lamp2';
            %set nuclei and cell model name
            options.nucleus.name = 'LAMP2';
            options.cell.model = 'LAMP2';
            %set the dimensionality of the model
            dimensionality = '2D';
            %documentation
            options.documentation.description = 'This model has been trained using demo2D05 from CellOrganizer';
            %set model type
            options.train.flag = 'framework';

            answer = img2slml( dimensionality, dna, cellm, [], options );
            
            testCase.verifyTrue( answer );
            testCase.verifyEqual( exist( './model.mat' ), 2 );
            if exist( './model.mat' )
                load('./model.mat');
                testCase.verifyTrue( isfield( model, 'nuclearShapeModel' ));
                testCase.verifyTrue( isfield( model, 'cellShapeModel' ));
                testCase.verifyTrue( ~isfield( model, 'proteinModel' ));
            end
            
            testCase.verifyEqual( exist( './param' ), 7 );
            
            if exist( './log' )
                rmdir( './log', 's' );
            end
            
            if exist( './param' )
                rmdir( './param', 's' );
            end
            
            if exist( './temporary_results' )
                rmdir( './temporary_results', 's' );
            end

            if exist( './model.mat' )
                delete( './model.mat' );
            end
            
        end
    end
end