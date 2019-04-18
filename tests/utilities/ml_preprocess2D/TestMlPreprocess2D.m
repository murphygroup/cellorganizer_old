% Yanyu Liang
%
% Copyright (C) 2013-2016 Murphy Lab
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

classdef TestMlPreprocess2D < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_empty_image( testCase )
            disp('test001: Should return empty images if input image is empty')
            image = [];
            cropimage = [];
            way = 'ml';
            bgsub = 'nobgsub';
            threshmeth = 'nih';
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);

            testCase.verifyEmpty( procImg );
            testCase.verifyEmpty( imgMask );
            testCase.verifyEmpty( resImg );
        end
        
        function test_non_matrix_image( testCase )
            disp('test002: Should return empty images if input image is not a matrix')
            image = 'notamatrix';
            cropimage = [];
            way = 'ml';
            bgsub = 'nobgsub';
            threshmeth = 'nih';
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);
            testCase.verifyEmpty( procImg );
            testCase.verifyEmpty( imgMask );
            testCase.verifyEmpty( resImg );
        end
        
        function test_non_matrix_croping( testCase )
            disp('test003: Should return images and display warning if cropimg is not a matrix')
            image = uint8(rand(1024,1024) * 255);
            cropimage = 'notamatrix';
            way = 'ml';
            bgsub = 'nobgsub';
            threshmeth = 'nih';
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);
            testCase.verifyNotEmpty( procImg );
            testCase.verifyNotEmpty( imgMask );
            testCase.verifyNotEmpty( resImg );
        end
        
        function test_improper_argument( testCase )
            disp('test004: Should use default value if improper way argument is passed in')
            image = uint8(rand(1024,1024) * 255);
            cropimage = [];
            way = 'notavalidway';
            bgsub = 'nobgsub';
            threshmeth = 'nih';
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);
            testCase.verifyNotEmpty( procImg );
            testCase.verifyNotEmpty( imgMask );
            testCase.verifyNotEmpty( resImg );
        end
        
        function test_non_string_argument( testCase )
            disp('test005: Should use a default value if way is not a string')
            image = uint8(rand(1024,1024) * 255);
            cropimage = [];
            way = 1;
            bgsub = 'nobgsub';
            threshmeth = 'nih';
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);
            testCase.verifyNotEmpty( procImg );
            testCase.verifyNotEmpty( imgMask );
            testCase.verifyNotEmpty( resImg );
        end
        
        function test_non_string_bgsub( testCase )
            disp('test006: Should use a default value if bgsub is not a string')
            image = uint8(rand(1024,1024) * 255);
            cropimage = [];
            way = 'ml';
            bgsub = false;
            threshmeth = 'nih';
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);
            testCase.verifyNotEmpty( procImg );
            testCase.verifyNotEmpty( imgMask );
            testCase.verifyNotEmpty( resImg );
        end
        
        function test_non_string_threshmeth( testCase )
            disp('test007: Should use a default value if threshmeth is not a string')
            image = uint8(rand(1024,1024) * 255);
            cropimage = [];
            way = 'ml';
            bgsub = 'yesbgsub';
            threshmeth = 1;
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);
            testCase.verifyNotEmpty( procImg );
            testCase.verifyNotEmpty( imgMask );
            testCase.verifyNotEmpty( resImg );
        end
        
        function test_improper_threshmeth( testCase )
            disp('test008: Should use default value if threshmeth is not a proper method')
            image = uint8(rand(1024,1024) * 255);
            cropimage = [];
            way = 'ml';
            bgsub = 'yesbgsub';
            threshmeth = 'notapropermethod';
            
            [procImg, imgMask, resImg] = ml_preprocess2D(image, cropimage, way, bgsub, threshmeth);
            testCase.verifyNotEmpty( procImg );
            testCase.verifyNotEmpty( imgMask );
            testCase.verifyNotEmpty( resImg );
        end
    end
end
