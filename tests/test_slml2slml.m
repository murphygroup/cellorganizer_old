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

classdef test_slml2slml < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_basic_run_2D( testCase )
            directory = '../models/2D';
            files = {[directory filesep 'endosome.mat'], ...
                [directory filesep 'lysosome.mat']};
            options.selection = [1,1,0;0,0,1];
            model = slml2slml( files, options );
            testCase.verifyTrue( ~isempty( model ) );
            
            if exist([pwd filesep 'model.mat'])
                delete([pwd filesep 'model.mat'])
            end
        end
        
        function test_basic_run_3D( testCase )
            directory = '../models/3D';
            files = {[directory filesep 'lamp2.mat'], ...
                [directory filesep 'mit.mat']};
            options.selection = [1,1,0;0,0,1];
            model = slml2slml( files, options );
            testCase.verifyTrue( ~isempty( model ) );
            
            if exist([pwd filesep 'model.mat'])
                delete([pwd filesep 'model.mat'])
            end
        end
        
        function test_options_structure( testCase )
            directory = '../models/2D';
            files = {[directory filesep 'endosome.mat'], ...
                [directory filesep 'lysosome.mat']};
            options = struct([]);
            model = slml2slml( files, options );
            testCase.verifyTrue( isempty( model ) );
            
            if exist([pwd filesep 'model.mat'])
                delete([pwd filesep 'model.mat'])
            end
        end
        
        function test_no_option( testCase )
            directory = '../models/2D';
            files = {[directory filesep 'endosome.mat'], ...
                [directory filesep 'lysosome.mat']};
            options = [];
            model = slml2slml( files, options );
            testCase.verifyTrue( isempty( model ) );
            
            if exist([pwd filesep 'model.mat'])
                delete([pwd filesep 'model.mat'])
            end
        end
        
        function test_input_single_file( testCase )
            files = {'../models/2D/endosome.mat'};
            options.selection = [1,1,0;0,0,1];
            model = slml2slml( files, options );
            testCase.verifyTrue( ~isempty( model ) );
            
            if exist([pwd filesep 'model.mat'])
                delete([pwd filesep 'model.mat'])
            end
        end
    end
end
