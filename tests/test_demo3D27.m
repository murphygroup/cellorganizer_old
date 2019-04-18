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

classdef test_demo3D27 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            testCase.verifyTrue( demo3D27() );
            testCase.verifyEqual(exist('./c2n','dir'),7);
            testCase.verifyEqual(exist('./img','dir'),7);
            testCase.verifyEqual(exist('./n2c','dir'),7);
            
            for i=1:1:175
                file=[pwd filesep 'c2n' filesep 'k_' num2str(i) '.mat'];
                testCase.verifyEqual(exist(file, 'file'),2);
            end
            testCase.verifyEqual(exist('./c2n/all_dat.mat', 'file'),2);
            
            for i=1:1:175
                file=[pwd filesep 'n2c' filesep 'k_' num2str(i) '.mat'];
                testCase.verifyEqual(exist(file, 'file'),2);
            end
            testCase.verifyEqual(exist('./n2c/all_dat.mat', 'file'),2);

            for i=1:1:4
                file=[pwd filesep 'img' filesep 'output0' num2str(i) '.png'];
                testCase.verifyEqual(exist(file, 'file'),2);
            end
            
            for i=1:1:175
                file=[pwd filesep 'c2n' filesep 'k_' num2str(i) '.mat'];
                if exist(file, 'file')
                    delete(file);
                end
            end
            if exist('./c2n/all_dat.mat','file')
                delete('./c2n/all_dat.mat');
            end
            if exist('./c2n','dir')
                rmdir('./c2n','s');
            end
            
            for i=1:1:4
                file=[pwd filesep 'img' filesep 'output0' num2str(i) '.png'];
                if exist(file, 'file')
                    delete(file);
                end
            end
            if exist('./img','dir')
                rmdir('./img','s');
            end
            
            for i=1:1:175
                file=[pwd filesep 'n2c' filesep 'k_' num2str(i) '.mat'];
                if exist(file, 'file')
                    delete(file);
                end
            end
            if exist('./n2c/all_dat.mat','file')
                delete('./n2c/all_dat.mat');
            end
            
            if exist('./n2c','dir')
                rmdir('./n2c','s');
            end
        end
    end
end
