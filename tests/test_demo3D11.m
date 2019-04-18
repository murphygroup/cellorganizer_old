% Ivan E. Cao-Berg
% Ulani Qi
%
% Copyright (C) 2017-2018 Murphy Lab
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

classdef test_demo3D11 < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run( testCase )
            directory = pwd;
            
            testCase.verifyTrue( demo3D11() );
            testCase.verifyEqual( exist( './3D_HeLa_framework.mat' ), 2 );
            testCase.verifyEqual( exist( './param' ), 7 );
            
            if exist( './param' )
                rmdir( './param', 's' );
            end
            
            if exist( './log' )
                rmdir( './log', 's' );
            end
            
            if exist( './3D_HeLa_framework.mat' )
                delete( './3D_HeLa_framework.mat' );
            end
            
            cd( directory );
        end
        
        function test_train_flag_set_to_nuclear( testCase )
            directory = pwd;
            
            options.train.flag = 'nuclear';
            testCase.verifyTrue( demo3D11( options ) );
            
            testCase.verifyEqual( exist( './3D_HeLa_framework.mat' ), 2 );
            testCase.verifyEqual( exist( './param' ), 7 );
            
            if exist( './param' )
                rmdir( './param', 's' );
            end
            
            if exist( './log' )
                rmdir( './log', 's' );
            end
            
            if exist( './3D_HeLa_framework.mat' )
                delete( './3D_HeLa_framework.mat' );
            end
            
            cd( directory );
        end
        
        function test_train_flag_set_to_cell( testCase )
            directory = pwd;
            
            options.train.flag = 'cell';
            testCase.verifyFalse( demo3D11( options ) );
            
            cd( directory );
        end
        
        function test_train_flag_set_to_framework( testCase )
            directory = pwd;
            
            options.train.flag = 'framework';
            testCase.verifyTrue( demo3D11( options ) );
            
            testCase.verifyEqual( exist( './3D_HeLa_framework.mat' ), 2 );
            testCase.verifyEqual( exist( './param' ), 7 );
            
            if exist( './param' )
                rmdir( './param', 's' );
            end
            
            if exist( './log' )
                rmdir( './log', 's' );
            end
            
            if exist( './3D_HeLa_framework.mat' )
                delete( './3D_HeLa_framework.mat' );
            end
            
            cd( directory );
        end
        
        function test_train_flag_set_to_protein( testCase )
            directory = pwd;
            
            options.train.flag = 'protein';
            testCase.verifyFalse( demo3D11( options ) );
                       
            if exist( './param' )
                rmdir( './param', 's' );
            end
            
            if exist( './log' )
                rmdir( './log', 's' );
            end
            
            if exist( './3D_HeLa_framework.mat' )
                delete( './3D_HeLa_framework.mat' );
            end
            
            cd( directory );
        end
    end
end
