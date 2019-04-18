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

classdef test_train_flag01 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            disp( 'Based on demo2D01' );
            options.verbose = true;
            options.debug = true;
            options.display = false;
            options.model.name = 'test';
            options.train.flag = 'nuclear';
            options.nucleus.class = 'nuclear_membrane';
            options.nucleus.type = 'medial_axis';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % the following list of parameters are adapted to the LAMP2 image
            % collection, modify these according to your needs
            directory = '../images/HeLa/2D/LAM';
            dna = [ directory filesep 'orgdna' filesep '*.tif' ];
            cellm = [];
            protein = [];
            options.masks = [ directory filesep 'crop' filesep '*.tif' ];
            options.temporary_results = [ pwd filesep 'temporary_results' ];
            options.model.resolution = [ 0.049, 0.049 ];
            options.model.filename = 'model.xml';
            
            answer = img2slml( '2D', dna, cellm, protein, options );
            
            testCase.verifyEqual( answer );
            testCase.verifyEqual( exist( './model.mat' ), 2 );
            if exist( './model.mat' )
                load('./model.mat');
                testCase.verifyEqual( isfield( model, 'nuclearShapeModel' );
                testCase.verifyEqual( ~isfield( model, 'cellShapeModel' );
                testCase.verifyEqual( ~isfield( model, 'proteinModel' );
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
            
        end
    end
end