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

classdef test_demo3D23 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            testCase.verifyTrue( demo3D23() );
            testCase.verifyEqual( exist('./lamp2.mat', 'file'), 2);
            testCase.verifyEqual( exist('./param', 'dir'), 7);
            for i = 1:1:50
                dir=[pwd filesep 'param' filesep 'param' num2str(i)];
                file=[pwd filesep 'param' filesep 'param' num2str(i) '.mat'];
                file1=[pwd filesep 'param' filesep 'param' num2str(i) filesep 'cell.mat'];
                file2=[pwd filesep 'param' filesep 'param' num2str(i) filesep 'compartment.mat'];
                file3=[pwd filesep 'param' filesep 'param' num2str(i) filesep 'nuc.mat'];
                file4=[pwd filesep 'param' filesep 'param' num2str(i) filsep 'prot.mat'];
                file5=[pwd filesep 'param' filesep 'param' num2str(i) filsep 'seg.mat'];
                
                testCase.verifyEqual(exist(dir, 'dir'), 7);
                testCase.verifyEqual(exist(file, 'file'), 2);
                testCase.verifyEqual(exist(file1, 'file'), 2);
                testCase.verifyEqual(exist(file2, 'file'), 2);
                testCase.verifyEqual(exist(file3, 'file'), 2);
                testCase.verifyEqual(exist(file4, 'file'), 2);
                testCase.verifyEqual(exist(file5, 'file'), 2);
            end  
            testCase.verifyEqual( exist('./param/gmm.mat', 'file'), 2);
            
            
            if exist('./param/gmm.mat', 'file')
                delete('./param/gmm.mat');
            end
            if exist('./lamp2.mat','file')
                delete('./lamp2.mat');
            end
            for i = 1:1:50
                dir=[pwd filesep 'param' filesep 'param' num2str(i)];
                file=[pwd filesep 'param' filesep 'param' num2str(i) '.mat'];
                file1=[pwd filesep 'param' filesep 'param' num2str(i) filesep 'cell.mat'];
                file2=[pwd filesep 'param' filesep 'param' num2str(i) filesep 'compartment.mat'];
                file3=[pwd filesep 'param' filesep 'param' num2str(i) filesep 'nuc.mat'];
                file4=[pwd filesep 'param' filesep 'param' num2str(i) filsep 'prot.mat'];
                file5=[pwd filesep 'param' filesep 'param' num2str(i) filsep 'seg.mat'];
                if exist(file, 'file')
                    delete(file);
                end
                if exist(file1, 'file')
                    delete(file1);
                end
                if exist(file2, 'file')
                    delete(file2);
                end
                if exist(file3, 'file')
                    delete(file3);
                end
                if exist(file4, 'file')
                    delete(file4);
                end
                if exist(file5, 'file')
                    delete(file5);
                end
                if exist(dir, 'dir')
                    rmdir(dir, 's');
                end
            end 
            if exist('./param', 'dir')
                rmdir('./param', 's');
            end
            cd( directory );
        end
    end
end
