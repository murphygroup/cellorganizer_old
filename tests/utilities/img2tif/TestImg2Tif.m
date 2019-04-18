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

classdef TestImg2Tif < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_non_existing_image_to_file( testCase )
            disp('Should return empty list if tif image does not  exists')
            filename ='img.tif';
            image = 'ss';
            testCase.verifyFalse( img2tif( image, filename ) );
            
            filename ='img.tif';
            image = [];
            testCase.verifyFalse( img2tif( image, filename ) );
        end
        
        function test_invalid_filename( testCase )
            disp('Should return false if the filename is not a valid string')
            filename = 2;
            image = rand(100);
            testCase.verifyFalse( img2tif(1,2) );
        end
        
        function test_missing_file_extension( testCase )
            disp('test003: Should add .tif as a suffix if there is no suffix')
            image = rand(100);
            img2tif( image, 'image' );
            testCase.verifyNotEqual( exist( [ pwd filesep 'image.tif' ]) ,0);
            delete( [ pwd filesep 'image.tif'] );
        end
        
        function test_file_exists_after_save( testCase )
            disp('test003: Should add .tif as a suffix if there is no suffix')
            image = rand(100);
            img2tif( image, [pwd filesep 'image.tif'] );
            testCase.verifyNotEqual( exist([ pwd filesep 'image.tif' ]),0 );
            delete( [ pwd filesep 'image.tif'] );
        end
    end
end

