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

classdef test_train_flag04 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            disp( 'demo3D11' );
            disp( 'The estimated running time is 10 seconds. Please wait.' );

            options.sampling.method = 'disc';
            options.debug = true;
            options.verbose = true;
            options.display = false;
            options.temporary_results = [ pwd filesep 'temporary_results' ];
            options.downsampling = [5,5,1];
            options.train.flag = 'nuclear';
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

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            options.model.resolution = [0.049, 0.049, 0.2000];
            imageDirectory = '../../../images/HeLa/3D/processed/';

            dimensionality = '3D';
            pattern = 'framework';

            dna = [imageDirectory filesep 'TfR*cell*ch0*.tif'];
            options.masks = [imageDirectory filesep 'TfR*mask*.tif'];

            % documentation
            % -------------
            options.documentation.author = 'Murphy Lab';
            options.documentation.email = 'murphy@cmu.edu';
            options.documentation.website = 'murphy@cmu.edu';
            options.documentation.description = 'This is the framework model is the result from demo3D11.';
            options.documentation.date = date;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            answer = img2slml( dimensionality, dna, [], [], options );
            
            testCase.verifyTrue( answer );
            testCase.verifyEqual( exist( './model.mat' ), 2 );
            if exist( './model.mat' )
                load('./model.mat');
                testCase.verifyTrue( isfield( model, 'nuclearShapeModel' ));
                testCase.verifyTrue( ~isfield( model, 'cellShapeModel' ));
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