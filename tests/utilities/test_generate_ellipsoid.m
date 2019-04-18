% Ivan E. Cao-Berg
%
% Copyright (C) 2016 Murphy Lab
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

classdef Test_generate_ellipsoid < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_method_with_no_input_parameters( testCase )
            testCase.verifyEmpty( generate_ellipsoid() );
        end
        
        function test_method_with_wrong_input_parameters( testCase )
            a = -5; b = 1; c = 1;
            testCase.verifyEmpty( generate_ellipsoid(a,b,c) );
            
            a = 5; b = -1; c = 1;
            testCase.verifyEmpty( generate_ellipsoid(a,b,c) );
            
            a = 5; b = 1; c = -1;
            testCase.verifyEmpty( generate_ellipsoid(a,b,c) );
        end
        
        function test_method_with_input_parameters( testCase )
            a = 50; b = 50; c = 50;
            options.image_size = 100;
            img = generate_ellipsoid(a,b,c, options);
            testCase.verifyNotEmpty( img );
            
            a = 50; b = 50; c = 50;
            options.image_size = 100;
            options.x0 = 10;
            options.y0 = 10;
            options.z0 = 10;
            img = generate_ellipsoid(a,b,c, options);
            testCase.verifyNotEmpty( img );
        end
    end
end

