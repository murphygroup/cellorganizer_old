% Juan Pablo Hinojosa and Ruijia Chen
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

classdef test_slml2img < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                       Input Arguments                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %                          Empty Models                           %
        
        function test_empty_models(testCase)
            %Purpose of the test
            disp('Empty Models Test: This shall return 0 since slml2img requires a model')
            
            % data that will be used to try the test
            list_of_models = {};
            
            % parameter selection to test
            param = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Check that in fact the slml2img returned a False
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %                      2D Models - No Params                      %
        
        % One Model
        function test_one_model(testCase)
            %Purpose of the test
            disp('One model Test: This shall return 1 since the slml2img should work with one model')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        % Two Models - Same File Twice
        function test_two_models_same(testCase)
            %Purpose of the test
            disp('One model Test: This shall return 1 since the slml2img should work with two models')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat','../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        % Two Models - Different Files
        function test_two_models_different(testCase)
            %Purpose of the test
            disp('One model Test: This shall return 1 since the slml2img should work with two models')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat','../../models/2D/lysosome.mat'};
            
            % parameter selection to test
            param = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        %                     3D Models - No Params                      %
        
        % One Model
        function test_one_model_3d(testCase)
            %Purpose of the test
            disp('One model Test: This shall return 1 since the slml2img should work with one 3D model')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        % Two Models - Same File Twice
        
        function test_two_models_same_3d(testCase)
            %Purpose of the test
            disp('One model Test: This shall return 1 since the slml2img should work with two equal 3D models')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/lamp2.mat','../../models/3D/mit.mat'};
            
            % parameter selection to test
            param = [];
            param.numberOfGaussianObjects = 1;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        % 2D & 3D Models Mix - No Params                  %
        
        function test_two_models_mix_different(testCase)
            %Purpose of the test
            disp('Two models Mix Test: return 0 since the slml2img does not work with a mix of 2D and 3D')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat','../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                       Helper Options                            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%                           NO FILE                           %%%
        
        function test_debug_false(testCase)
            %Purpose of the test
            disp('Debug No File False Test: This shall return 0 since the function should not work')
            
            % data that will be used to try the test
            list_of_models = {};
            
            % parameter selection to test
            param = [];
            param.debug = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        function test_debug_true(testCase)
            %Purpose of the test
            disp('Debug No File True Test: This shall return 0 since the function should not work')
            
            % data that will be used to try the test
            list_of_models = {};
            
            % parameter selection to test
            param = [];
            param.debug = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        function test_display_false(testCase)
            %Purpose of the test
            disp('Display No File False Test: This shall return 0 since the function should not work')
            
            % data that will be used to try the test
            list_of_models = {};
            
            % parameter selection to test
            param = [];
            param.display = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        function test_display_true(testCase)
            %Purpose of the test
            disp('Display No File True Test: This shall return 0 since the function should not work')
            
            % data that will be used to try the test
            list_of_models = {};
            
            % parameter selection to test
            param = [];
            param.display = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        function test_verbose_false(testCase)
            %Purpose of the test
            disp('Verbose False No File Test: This shall return 0 since the function should not work')
            
            % data that will be used to try the test
            list_of_models = {};
            
            % parameter selection to test
            param = [];
            param.verbose = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        function test_verbose_true(testCase)
            %Purpose of the test
            disp('Verbose True No File Test: This shall return 0 since the function should not work')
            
            % data that will be used to try the test
            list_of_models = {};
            
            % parameter selection to test
            param = [];
            param.verbose = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyFalse( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        
        
        %%%                          ONE FILE                           %%%
        
        %                             Debug 2D                            %
        function test_debug_2D_false(testCase)
            %Purpose of the test
            disp('Debug 2D False Test: This shall return 1 since the function should work if the debug option is set to false')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.debug = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        function test_debug_2D_true(testCase)
            %Purpose of the test
            disp('Debug 2D True Test: This shall return 1 since the function should work if the debug option is set to true')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.debug = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
          
        %                             Debug 3D                            %
        function test_debug_3D_false(testCase)
            %Purpose of the test
            disp('Debug 3D False Test: This shall return 1 since the function should work if the debug option is set to false')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            param.debug = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        function test_debug_3D_true(testCase)
            %Purpose of the test
            disp('Debug True Test: This shall return 1 since the function should work if the debug option is set to true')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            param.debug = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %                             Display 2D                          %
        
        function test_display_2D_false(testCase)
            %Purpose of the test
            disp('Display False 2D Test: This shall return 1 since the function should work if the display option is set to false')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.display = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        function test_display_2D_true(testCase)
            %Purpose of the test
            disp('Display True 2D Test: This shall return 1 since the function should work if the display option is set to true')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.display = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        %                             Display 3D                          %
        
        function test_display_3D_false(testCase)
            %Purpose of the test
            disp('Display False 3D Test: This shall return 1 since the function should work if the display option is set to false')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            param.display = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        function test_display_3D_true(testCase)
            %Purpose of the test
            disp('Display True 3D Test: This shall return 1 since the function should work if the display option is set to true')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            param.display = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        
        %                             Verbose 2D                          %
        
        function test_verbose_2D_false(testCase)
            %Purpose of the test
            disp('Verbose False 2D Test: This shall return 1 since the function should work if the verbose option is set to false')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.verbose = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        function test_verbose_2D_true(testCase)
            %Purpose of the test
            disp('Verbose True 2D Test: This shall return 1 since the function should work if the verbose option is set to true')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.verbose = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        %                             Verbose 3D                          %
        
        function test_verbose_3D_false(testCase)
            %Purpose of the test
            disp('Verbose False 3D Test: This shall return 1 since the function should work if the verbose option is set to false')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            param.display = false;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        function test_verbose_3D_true(testCase)
            %Purpose of the test
            disp('Verbose True 3D Test: This shall return 1 since the function should work if the verbose option is set to true')
            
            % data that will be used to try the test
            list_of_models = {'../../models/3D/centro.mat'};
            
            % parameter selection to test
            param = [];
            param.display = true;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        
        
        
        
        %%%                        MULTIPLE FILES                       %%%
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                         Prefix Options                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%                     Input no prefix field                   %%%
        
        function test_no_prefix_2D(testCase)
            %Purpose of the test
            disp('Input no Prefix 2D Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%                     Input empty string                      %%%
        
        function test_prefix_empty_2D(testCase)
            %Purpose of the test
            disp('Prefix Filed Empty Test: This shall return 0 since the option should not be empty')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.prefix = '';
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%                     Input not empty string                  %%%
        
        function test_prefix_2D(testCase)
            %Purpose of the test
            disp(' Prefix exists Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.prefix = 'img';
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                numberOfSynthesizedImages                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%               Input 100 numberOfSynthesizedImages           %%%
        
        function numberOfSynthesizedImages_not_empty_2D(testCase)
            %Purpose of the test
            disp('numberOfSynthesizedImages not empty 2D Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.numberOfSynthesizedImages = -1;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%                     Input number as 0                       %%%
        
        function test_number_0(testCase)
            %Purpose of the test
            disp('numberOfSynthesizedImages equals to 0 Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.numberOfSynthesizedImages = 0;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                targetDirectory not defined                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%                set targetDirectory as pwd                   %%%
        function target_dir_as_pwd_2D(testCase)
            %Purpose of the test
            disp('targetDirectory as pwd 2D Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.targetDirectory = pwd;
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%             set targetDirectory option empty                %%%
        
        function target_dir_as_empty_2D(testCase)
            %Purpose of the test
            disp('targetDirectory as empty 2D Test: This shall return 0 since the function should not work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.targetDirectory = [];
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                      compression Options                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%              set compression option as 'none'               %%%
        function compression_none_2D(testCase)
            %Purpose of the test
            disp('targetDirectory as pwd 2D Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.compression = 'none';
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        
        %%%              set compression option as 'lzw'                %%%
        
        function compression_lzw_2D(testCase)
            %Purpose of the test
            disp('targetDirectory as pwd 2D Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.compression = 'lzw';
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
        %%%           set compression option as 'packbits'              %%%
        
        function compression_packbits_2D(testCase)
            %Purpose of the test
            disp('targetDirectory as pwd 2D Test: This shall return 1 since the function should work')
            
            % data that will be used to try the test
            list_of_models = {'../../models/2D/endosome.mat'};
            
            % parameter selection to test
            param = [];
            param.compression = 'packbits';
            
            % try the function with the specific parameters
            answer = slml2img( list_of_models, param );
            
            % Verification - Actual Answer
            testCase.verifyTrue( answer );
            
            % Erase the created folders
            temp = [ pwd filesep 'demo' ];
            
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'log' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
            
            temp = [ pwd filesep 'demo1.tif' ];
            if exist( temp )
                delete( temp );
            end
            
            temp = [ pwd filesep 'temp' ];
            if exist( temp )
                rmdir( temp, 's' );
            end
        end
    end
end