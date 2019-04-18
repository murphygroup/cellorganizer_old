% Ivan E. Cao-Berg
%
% Copyright (C) 2013 Murphy Lab
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

classdef TestTif2Img < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_non_existing_image_file( testCase )
            disp('Should return empty list if tif image does not  exists')
            filename ='img.tif';
            testCase.verifyEqual( tif2img(filename), [] );
            
            filename ='img.jpg';
            testCase.verifyEqual( tif2img(filename), [] );
            
            filename ='img.png';
            testCase.verifyEqual( tif2img(filename), [] );
        end
        
        function test_wrong_input_argument_class( testCase )
            disp('Should return empty list if tif image is not valid')
            disp( 'Passing a double' );
            filename = 1;
            testCase.verifyEqual( tif2img( filename ), [] );
            
            disp( 'Passing an array' )
            filename = rand(4);
            testCase.verifyEqual( tif2img( filename ), [] );
            
            disp( 'Passing a function handle' );
            filename = @rand;
            testCase.verifyEqual( tif2img( filename ), [] );
            
            disp( 'Passing an instance of a class' );
            filename = java.util.LinkedList;
            testCase.verifyEqual( tif2img( filename ), [] );
        end
        
        function test_existing_3Dimage_file( testCase )
            disp('If image is a multi tif, the output should be a 3D list');
            filename ='../../../images/HeLa/3D/raw/LAMP2/cell1_ch0_t1.tif';
            img = tif2img( filename );
            testCase.verifyEqual (length(size(img)), 3);
        end
        
        function test_existing_2Dimage_file( testCase )
            disp('If image is a single tif, the output should be a 2D list');
            filename = '../../../images/HeLa/3D/raw/LAMP2/cell1_ch0_t1.tif';
            img = tif2img( filename );
            img = img(:,:,1);
            img2tif( img, 'tmp.tif' );
            img = tif2img('tmp.tif' );
            testCase.verifyEqual( length(size(img)), 2 );
            delete('tmp.tif');
        end
    end
end

