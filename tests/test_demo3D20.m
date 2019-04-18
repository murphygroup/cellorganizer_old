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

classdef test_demo3D20 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            testCase.verifyTrue( demo3D20() );
            testCase.verifyEqual(exist('./model.mat','file'),2);
            testCase.verifyEqual(exist('./temp/diffeomorphic', 'dir'),7);
            testCase.verifyEqual(exist('./param','dir'),7);
            testCase.verifyEqual(exist('./temp/diffeomorphic/distances_sparse.mat','file'),2);
            testCase.verifyEqual(exist('./temp/diffeomorphic/distances_sparse.mat_bak','file'),2);
            testCase.verifyEqual(exist('./temp/diffeomorphic/imfunc_params.mat','file'),2);
            testCase.verifyEqual(exist('./temp/diffeomorphic/distances','dir'),7);
            
            cd( directory );
        end
    end
end
