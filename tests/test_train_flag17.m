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

classdef test_train_flag17 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            disp( 'demo3D23' );
            disp( 'The estimated running time is 9 hours. Please wait.' );

            pattern = 'LAMP2';

            directory = '../../../images/HeLa/3D/processed';
            dna = [directory filesep 'LAM*cell*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell*ch1*.tif'];
            param.masks = [directory filesep 'LAM*cell*mask*.tif'];

            dimensionality = '3D';

            % param.masks = [directory filesep 'cell*mask*.tif'];

            % generic model options
            % ---------------------
            % model.name                (optional) Holds the name of the model. Default is empty.
            param.model.name = 'all';

            % model.id                  (optional) Holds the id of the model. Default is empty.
            param.model.id = num2str(now);

            % model.filename            Holds the output filename.
            param.model.filename = [ lower(pattern) '.xml' ];

            % nucleus.id                (optional) Holds the id of the nuclear model. Default is empty.
            param.nucleus.type = 'diffeomorphic';
            param.nucleus.class = 'framework';
            param.nucleus.id = num2str(now);

            % cell shape model options
            % ------------------------
            % cell.type                 Holds the cell model type. Default is "ratio".
            param.cell.type = 'diffeomorphic';
            param.cell.class = 'framework';
            param.cell.id = num2str(now);

            % other options
            % -------------
            % verbose                   (optional) Displays messages to screen. The default is true.
            param.verbose = true;

            % debug                     (optional) Reports errors and warnings. Default is false.
            param.debug = false;

            % train.flag                (optional) Selects what model is going to be trained ('nuclear',
            %                           'framework', or 'all'). Default is 'all'
            param.train.flag = 'framework';

            %documentation
            param.documentation.description = 'This model has been trained using demo3D20_2D from CellOrganizer';

            %model resolution
            param.downsampling = [10,10,1];

            %this is the resolution of the datasets
            param.model.resolution = [0.049, 0.049, 0.2000];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            answer = img2slml( dimensionality, dna, cell, [], param );
            
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