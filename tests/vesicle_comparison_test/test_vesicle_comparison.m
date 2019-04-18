% Ulani Qi
%
% Copyright (C) 2013-2017 Murphy Lab
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

classdef test_vesicle_comparison < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_2d_3d_model_combination( testCase )    
            model1 = './testmodels/2D/endosome.mat';
            model2 = './testmodels/3D/nuc.mat';
            outputPath = './outputPath';
            answer = vesicle_comparison( model1, model2, outputPath );
            disp(answer)
            testCase.verifyFalse( answer );
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end
        
        function test_3d_2d_model_combination( testCase )
            model1 = 'testmodels/3D/centro.mat';
            model2 = 'testmodels/2D/lysosome.mat';
            outputPath = './outputPath';
            answer = vesicle_comparison( model1, model2, outputPath );
            testCase.verifyFalse(answer);
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end
        
        function test_3d_3d_model_combination( testCase )
            model1 = 'testmodels/3D/centro.mat';
            model2 = 'testmodels/3D/nuc.mat';
            outputPath = './outputPath';
            answer = vesicle_comparison( model1, model2, outputPath );
            testCase.verifyFalse(answer);
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end

        function test_3d_diffeomorphic_model_combination( testCase )
            model1 = 'testmodels/3D/centro.mat';
            model2 = 'testmodels/3D/diffeomorphic/3t3_model.mat';
            outputPath = './outputPath';
            answer = vesicle_comparison( model1, model2, outputPath );
            testCase.verifyFalse(answer);
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end

        function test_diffeomorphic_2d_model_combination( testCase )
            model1 = 'testmodels/3D/diffeomorphic/cell_model_nuc_align.mat';
            model2 = 'testmodels/2D/lysosome.mat';
            outputPath = './outputPath';
            answer = vesicle_comparison( model1, model2, outputPath );
            testCase.verifyFalse(answer);
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end

        function test_2d_2d_model_combination( testCase )
            model1 = 'testmodels/2D/endosome.mat';
            model2 = 'testmodels/2D/lysosome.mat';
            outputPath = './outputPath';
            answer = vesicle_comparison( model1, model2, outputPath );
            testCase.verifyTrue(answer);
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end

        function test_missing_one_model( testCase )
            model1 = 'testmodels/3D/centro.mat';
            outputPath = './outputPath';
            answer = vesicle_comparison( model1, outputPath );
            testCase.verifyFalse(answer);
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end

        function test_missing_two_models( testCase )
            outputPath = './outputPath';
            answer = vesicle_comparison( outputPath );
            testCase.verifyFalse(answer);
            testCase.verifyTrue( exist('./outputPath/index.html','file')==2 );
        end

        function test_missing_output_path( testCase )
            model1 = 'testmodels/2D/endosome.mat';
            model2 = 'testmodels/2D/lysosome.mat';
            answer = vesicle_comparison( model1, model2 );
            testCase.verifyTrue(answer);
            testCase.verifyTrue( exist('./index.html','file')==2 );
        end
      
    end
end