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

classdef test_train_flag22 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            disp( 'Based on demo3D12' );
            options.verbose = true;
            options.debug = true;
            options.display = false;
            options.model.name = 'test';
            options.train.flag = 'all';
            options.nucleus.class = 'nuclear_membrane';
            options.nucleus.type = 'cylindrical_surface';
            options.cell.class = 'cell_membrane';
            options.cell.type = 'ratio';
            options.protein.class = 'vesicle';
            options.protein.type = 'gmm';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % the following list of parameters are adapted to the LAMP2 image
            % collection, modify these according to your needs
            directory = '../images/HeLa/3D/processed';
            for i = 1:20
                dna{i} = [directory filesep 'LAM_cell' num2str(i) '_ch0_t1.tif'];
                cellm{i} = [directory filesep 'LAM_cell' num2str(i) '_ch1_t1.tif'];
                protein{i} = [directory filesep 'LAM_cell' num2str(i) '_ch2_t1.tif'];
                options.masks{i} = [directory filesep 'LAM_cell' num2str(i) '_mask_t1.tif'];
            end
            options.train.flag = 'all';
            options.model.resolution=[0.049, 0.049, 0.2000];
            options.model.filename = 'model.xml';
            
            answer = img2slml( '3D', dna, cellm, protein, options );
            
            testCase.verifyTrue( answer );
            testCase.verifyEqual( exist( './model.mat' ), 2 );
            if exist( './model.mat' )
                load('./model.mat');
                testCase.verifyTrue( isfield( model, 'nuclearShapeModel' ));
                testCase.verifyTrue( isfield( model, 'cellShapeModel' ));
                testCase.verifyTrue( isfield( model, 'proteinModel' ));
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
                delete( './model.mat' )
            end
        end
    end
end