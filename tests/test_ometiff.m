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

classdef test_ometiff < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            url = 'https://downloads.openmicroscopy.org/images/OME-TIFF/2016-06/bioformats-artificial/single-channel.ome.tiff';
            filename = './single-channel.ome.tiff';
            urlwrite( url, filename );
            
            testCase.verifyEqual( exist( filename ), 2 );
            testCase.verifyFalse( has_rois( filename ));
            testCase.verifyEqual( get_number_of_rois( filename ), 0 );
            testCase.verifyEqual( get_ometiff_dimensions( filename ), [439 167 1 1 1] );
            testCase.verifyEqual( size(get_roi( filename )), [167, 439] );
            testCase.verifyTrue( strcmpi(class(get_roi( filename )), 'int8' ));
            
            if exist( filename )
                delete( filename );
            end
        end
        
        function test_demo3D34( testCase )
            directory = pwd;
            
            filename = '../demos/3D/demo3D34/img/cell1/cell1.ome.tif';
            if ~exist( filename )
                demo3D34();
                cd( directory );
            end
            
            copyfile( filename, '.' );
            filename = './cell1.ome.tif';
            testCase.verifyEqual( exist( filename ), 2 );
            testCase.verifyFalse( has_rois( filename ));
            testCase.verifyEqual( get_number_of_rois( filename ), 0 );
            testCase.verifyEqual( get_ometiff_dimensions( filename ), [452 490 13 3 1] );
            
            if exist( filename )
                delete( filename );
            end
        end
    end
end