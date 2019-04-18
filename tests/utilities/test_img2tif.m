% Rita Chen
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

classdef test_img2tif < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function Basic_test_compression_none( testCase )
            disp('Should return 1 if imput is legal')
            img = rand(3,3,3);
            testCase.verifyTrue( img2tif(img,'temp','none',true) );
            temp = [ pwd filesep 'temp.tif' ];
            if exist( temp )
                delete( temp );
            end
        end
        
        function Basic_test_compression_lzw( testCase )
            disp('Should return 1 if imput is legal')
            img = rand(3,3,3);
            testCase.verifyTrue( img2tif(img,'temp','lzw',false) );
            temp = [ pwd filesep 'temp.tif' ];
            if exist( temp )
                delete( temp );
            end
        end
        
        function filename_empty_str( testCase )
            disp('Should return 0 if imput is illegal')
            img = rand(3,3,3);
            filename = '';
            testCase.verifyFalse( img2tif(img,filename) );
            temp = [ pwd filesep 'temp.tif' ];
            if exist( temp )
                delete( temp );
            end
        end
        
        function empty_input( testCase )
            disp('Should return 0 if imput is empty')
            testCase.verifyFalse( img2tif() );
            temp = [ pwd filesep 'temp.tif' ];
            if exist( temp )
                delete( temp );
            end
        end
        
        function filename_not_str( testCase )
            disp('Should return 0 if imput is illegal')
            img = rand(3,3,3);
            filename = 1;
            testCase.verifyFalse( img2tif(img,filename) );
            filename=[filename '.tif'];
            temp = [ pwd filesep filename ];
            if exist( temp )
                delete( temp );
            end
        end
        
        function zero_image( testCase )
            disp('Should return 0 if imput is illegal')
            img = zeros(3,3,3);
            filename = 1;
            testCase.verifyFalse( img2tif(img,filename) );
            filename=[filename '.tif'];
            temp = [ pwd filesep filename ];
            if exist( temp )
                delete( temp );
            end
        end
        function rand_image_not_3D( testCase )
            disp('Should return 1 if imput is legal')
            img = rand(3,3,2);
            filename = 'tem';
            testCase.verifyTrue( img2tif(img,filename) );
            filename=[filename '.tif'];
            temp = [ pwd filesep filename ];
            if exist( temp )
                delete( temp );
            end
        end
        
        function rand_image_extend_3D( testCase )
            disp('Should return 1 if imput is legal')
            img = rand(3,3,5);
            filename = 'tem';
            testCase.verifyFalse( img2tif(img,filename) );
            filename=[filename '.tif'];
            temp = [ pwd filesep filename ];
            if exist( temp )
                delete( temp );
            end
        end
        function image_empty( testCase )
            disp('Should return 1 if imput is legal')
            img = [];
            filename = 'tem';
            testCase.verifyFalse( img2tif(img,filename) );
            filename=[filename '.tif'];
            temp = [ pwd filesep filename ];
            if exist( temp )
                delete( temp );
            end
        end
    end
end

