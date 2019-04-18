% Ivan E. Cao-Berg
%
% Copyright (C) 2017 Murphy Lab
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

classdef test_demos < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_demo2D00( testCase )
            testCase.verifyTrue( demo2D00() );
        end
        
        function test_demo2D01( testCase )
            testCase.verifyTrue( demo2D01() );
        end
        
        function test_demo2D02( testCase )
            testCase.verifyTrue( demo2D02() );
        end
        
        function test_demo2D03( testCase )
            testCase.verifyTrue( demo2D03() );
        end
        
        function test_demo3D00( testCase )
            testCase.verifyTrue( demo3D00() );
        end
        
        function test_demo3D01( testCase )
            testCase.verifyTrue( demo3D01() );
        end
        
        function test_demo3D02( testCase )
            testCase.verifyTrue( demo3D02() );
        end
        
        function test_demo3D03( testCase )
            testCase.verifyTrue( demo3D03() );
        end
        
        function test_demo3D05( testCase )
            if exist( '../demos/3D/demo3D05/img' )
                testCase.verifyFalse( demo3D05() );
            else
                testCase.verifyTrue( demo3D05() );
            end
        end
        
        function test_demo3D07( testCase )
            testCase.verifyTrue( demo3D07() );
        end
        
        function test_demo3D08( testCase )
            testCase.verifyTrue( demo3D08() );
        end
        
        function test_demo3D11( testCase )
            testCase.verifyTrue( demo3D11() );
        end
        
        function test_demo3D12( testCase )
            testCase.verifyTrue( demo3D12() );
        end
    end
end