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

classdef test_train_flag10 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            disp( 'demo3D51' );
            options.verbose = true;
            options.debug = ~false;
            options.display = false;
            options.model.name = 'demo3D51';
            options.train.flag = 'cell';
            options.cell.class = 'cell_membrane';
            options.cell.type = 'spharm_rpdm';

            % postprocess of parameterization: alignment
            options.spharm_rpdm.postprocess = ~false;
            % degree of the descriptor
            options.spharm_rpdm.maxDeg = 31;
            % cellular components: either {'cell'}, {'nuc'}, or {'cell', 'nuc'}
            options.spharm_rpdm.components = {'cell'};

            % latent dimension for the model
            options.latent_dim = 15;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % the following list of parameters are adapted to the LAMP3 image
            % collection, modify these according to your needs
            directory = '../../../images/HeLa/3D/processed/';
            dna = [ directory filesep 'LAM_cell[1-9]_ch0_t1.tif' ];
            cellm = [ directory filesep 'LAM_cell[1-9]_ch1_t1.tif' ];
            options.masks = [ directory filesep 'LAM_cell[1-9]_mask_t1.tif' ];

            options.model.resolution = [0.049, 0.049, 0.2000];
            options.downsampling = [5, 5, 1];
            options.model.filename = 'lamp2.xml';
            options.model.id = 'lamp2';
            options.model.name = 'lamp2';
            %set nuclei and cell model name
            options.nucleus.name = 'LAMP2';
            options.cell.model = 'LAMP2';
            %set the dimensionality of the model
            dimensionality = '3D';
            %documentation
            options.documentation.description = 'This model has been trained using demo2D05 from CellOrganizer';
            options.segminnucfraction = 0.1;

            answer = img2slml( dimensionality, [], cellm, [], options );

            
            testCase.verifyTrue( answer );
            testCase.verifyEqual( exist( './model.mat' ), 2 );
            if exist( './model.mat' )
                load('./model.mat');
                testCase.verifyTrue( ~isfield( model, 'nuclearShapeModel' ));
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