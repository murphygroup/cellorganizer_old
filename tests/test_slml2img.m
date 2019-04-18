% Ulani Qi
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
    %TEST_SLML2IMG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Test)
        function test_empty_models_list( testCase )
            disp('test001: must return false when list of models is empty')
            instances = {};
            options = [];
            answer = slml2img( instances, options );
            testCase.verifyFalse( answer );
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
        
        function test_non_cell_array_model_list( testCase )
            disp('test002: must return false when list of models is not a cell array')
            instances = 1;
            options = [];
            answer = slml2img( instances, options );
            testCase.verifyFalse( answer );
            
            instances = rand(3);
            options = [];
            answer = slml2img( instances, options );
            testCase.verifyFalse( answer );
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
        
        function test_non_existing_file_in_model_list( testCase )
            disp('test003: Must return false if the list of files contains a non existing file')
            instances = {'non-existing-file.mat'};
            options = [];
            answer = slml2img( instances, options );
            testCase.verifyFalse( answer );
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
        
        function test_default_values_from_options( testCase )
            disp('test004: check default values from options structure')
            list_of_models = {'models/2D/endosome.mat'};
            options.debug = true;
            answer = slml2img( list_of_models, options );
            testCase.verifyTrue( answer );
            
            load( [ pwd filesep 'temp' filesep 'options.mat' ] );
            testCase.verifyTrue( options.debug );
            testCase.verifyFalse( options.display );
            
            clear options
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
        
        function test_checking_models_have_same_dimensionality( testCase )
            disp('test005: check that models have the same dimensionality')
            instances = {'models/2D/endosome.mat','models/3D/lamp2.mat'};
            options.debug = true;
            answer = slml2img( instances, options );
            testCase.verifyFalse( answer );
            
            tic
            instances = {'models/2D/endosome.mat', 'models/2D/lysosome.mat'};
            options.debug = true;
            answer = slml2img( instances, options );
            toc
            testCase.verifyTrue( answer );
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
        
        function test_missing_parameters( testCase )
            disp('test006: check that providing no parameters fail')
            % no parameters
            answer = slml2img( );
            testCase.verifyFalse( answer );
            
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
        
        function test_one_parameter( testCase )
            disp('test007: check that providing only one parameter fails')
            tic
            instances = {'models/2D/endosome.mat', ...
                'models/2D/lysosome.mat'};
            % one parameter, model list
            answer = slml2img( instances );
            toc
            testCase.verifyFalse( answer );
            
            tic
            options.debug = true;
            % one parameter, options structure
            answer = slml2img( options );
            toc
            testCase.verifyFalse( answer );
            
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
        
        function test_3D_models( testCase )
            disp('test008: check that two 3D model instances work')
            tic
            instances = {'models/3D/ellipsoid_model.mat', ...
                'models/3D/centro.mat'};
            % one parameter, model list
            answer = slml2img( instances , []);
            toc
            testCase.verifyTrue( answer );
            
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

