% Ivan E. Cao-Berg
% Ulani Qi
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

classdef test_demo3D28 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            testCase.verifyTrue( demo3D28() );
            testCase.verifyEqual(exist('./img/cell1','dir'), 7);
            testCase.verifyEqual(exist('./img/cell1/cell.tif','file'), 2);
            testCase.verifyEqual(exist('./img/cell1/nucleus.tif','file'), 2);
            testCase.verifyEqual(exist('./img/cell1/vesicle1.tif','file'), 2);
            
            if exist('./img/cell1/cell.tif','file')
                delete('./img/cell1/cell.tif');
            end
            if exist('./img/cell1/nucleus.tif','file')
                delete('./img/cell1/nucleus.tif');
            end
            if exist('./img/cell1/vesicle1.tif','file')
                delete('./img/cell1/vesicle1.tif');
            end
            if exist('./img/cell1','dir')
                rmdir('./img/cell1','s');
            end
            
            cd( directory );
        end
    end
end
