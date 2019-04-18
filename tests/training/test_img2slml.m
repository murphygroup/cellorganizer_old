% Yanyu Liang and Ivan E. Cao-Berg
%
% Copyright (C) 2013-2018 Murphy Lab
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

classdef test_img2slml < matlab.unittest.TestCase
    properties
    end
    
    methods (Test)
        function test_model_class_type_combination1( testCase )
            pattern = 'LAMP2';
            
            options.nucleus.type = 'cylindrical_surface';
            options.nucleus.class = 'nuclear_membrane';
            
            options.train.flag = 'all';
            
            options.cell.type = 'ratio';
            options.cell.class = 'cell_membrane';
            
            options.protein.type = 'medial_axis';
            options.protein.class = 'vesicle';
            
            if strcmpi( options.protein.class, 'nuc' )
                options.protein.cytonuclearflag = 'nuc';
            else
                options.protein.cytonuclearflag = 'cyto';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            directory = '../../../images/HeLa/3D/processed';
            dna = [directory filesep 'LAM*cell[1-30]*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell[1-30]*ch1*.tif'];
            protein = [directory filesep 'LAM*cell[1-30]*ch2*.tif'];
            options.masks = [directory filesep 'LAM*cell[1-30]*mask*.tif'];
            options.model.resolution=[0.049, 0.049, 0.2000];
            options.model.downsampling = [10 10 1];
            options.model.filename = 'LAMP2.xml';
            dimensionality = '3D';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            answer = img2slml( dimensionality, dna, cell, protein, options );
            testCase.verifyFalse( answer );
        end
        
        function test_model_class_type_combination2( testCase )
            pattern = 'LAMP2';
            
            options.nucleus.type = 'cylindrical_surface';
            options.nucleus.class = 'nuclear_membrane';
            
            options.train.flag = 'all';
            
            options.cell.type = 'ratio';
            options.cell.class = 'cell_membrane';
            
            options.protein.type = 'ratio';
            options.protein.class = 'vesicle';
            
            if strcmpi( options.protein.class, 'nuc' )
                options.protein.cytonuclearflag = 'nuc';
            else
                options.protein.cytonuclearflag = 'cyto';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            directory = '../../../images/HeLa/3D/processed';
            dna = [directory filesep 'LAM*cell[1-30]*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell[1-30]*ch1*.tif'];
            protein = [directory filesep 'LAM*cell[1-30]*ch2*.tif'];
            options.masks = [directory filesep 'LAM*cell[1-30]*mask*.tif'];
            options.model.resolution=[0.049, 0.049, 0.2000];
            options.model.downsampling = [10 10 1];
            options.model.filename = 'LAMP2.xml';
            dimensionality = '3D';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            answer = img2slml( dimensionality, dna, cell, protein, options );
            testCase.verifyFalse( answer );
        end
        
        function test_lack_of_resolution( testCase )
            pattern = 'LAMP2';
            
            options.nucleus.type = 'cylindrical_surface';
            options.nucleus.class = 'nuclear_membrane';
            
            options.cell.type = 'ratio';
            options.cell.class = 'cell_membrane';
            
            options.train.flag = 'all';
            
            options.protein.type = 'gmm';
            options.protein.class = 'vesicle';
            
            if strcmpi( options.protein.class, 'nuc' )
                options.protein.cytonuclearflag = 'nuc';
            else
                options.protein.cytonuclearflag = 'cyto';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            directory = '../../../images/HeLa/3D/processed';
            dna = [directory filesep 'LAM*cell[1-30]*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell[1-30]*ch1*.tif'];
            protein = [directory filesep 'LAM*cell[1-30]*ch2*.tif'];
            options.masks = [directory filesep 'LAM*cell[1-30]*mask*.tif'];
            options.model.downsampling = [10 10 1];
            options.model.filename = 'LAMP2.xml';
            dimensionality = '3D';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            answer = img2slml( dimensionality, dna, cell, protein, options );
            testCase.verifyFalse( answer );
        end
        
        function test_image_folder_does_not_exist( testCase )
            pattern = 'LAMP2';
            
            options.nucleus.type = 'cylindrical_surface';
            options.nucleus.class = 'nuclear_membrane';
            
            options.cell.type = 'ratio';
            options.cell.class = 'cell_membrane';
            
            options.protein.type = 'gmm';
            options.protein.class = 'vesicle';
            
            if strcmpi( options.protein.class, 'nuc' )
                options.protein.cytonuclearflag = 'nuc';
            else
                options.protein.cytonuclearflag = 'cyto';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            directory = pwd;
            dna = [directory filesep 'LAM*cell[1-30]*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell[1-30]*ch1*.tif'];
            protein = [directory filesep 'LAM*cell[1-30]*ch2*.tif'];
            options.masks = [directory filesep 'LAM*cell[1-30]*mask*.tif'];
            options.model.downsampling = [10 10 1];
            options.model.resolution=[0.049, 0.049, 0.2000];
            options.model.filename = 'LAMP2.xml';
            dimensionality = '3D';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            answer = img2slml( dimensionality, dna, cell, protein, options );
            testCase.verifyFalse( answer );
        end
        
        function test_dimensionality1( testCase )
            pattern = 'LAMP2';
            
            options.nucleus.type = 'cylindrical_surface';
            options.nucleus.class = 'nuclear_membrane';
            
            options.cell.type = 'ratio';
            options.cell.class = 'cell_membrane';
            
            options.protein.type = 'gmm';
            options.protein.class = 'vesicle';
            
            if strcmpi( options.protein.class, 'nuc' )
                options.protein.cytonuclearflag = 'nuc';
            else
                options.protein.cytonuclearflag = 'cyto';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            directory = '../../images/HeLa/3D/processed';
            dna = [directory filesep 'LAM*cell[1-30]*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell[1-30]*ch1*.tif'];
            protein = [directory filesep 'LAM*cell[1-30]*ch2*.tif'];
            options.masks = [directory filesep 'LAM*cell[1-30]*mask*.tif'];
            options.model.downsampling = [10 10 1];
            options.model.resolution=[0.049, 0.049, 0.2000];
            options.model.filename = 'LAMP2.xml';
            dimensionality = '4D';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            answer = img2slml( dimensionality, dna, cell, protein, options );
            testCase.verifyFalse( answer );
        end
        
        function test_dimensionality2( testCase )
            pattern = 'LAMP2';
            
            options.nucleus.type = 'cylindrical_surface';
            options.nucleus.class = 'nuclear_membrane';
            
            options.cell.type = 'ratio';
            options.cell.class = 'cell_membrane';
            
            options.protein.type = 'gmm';
            options.protein.class = 'vesicle';
            
            if strcmpi( options.protein.class, 'nuc' )
                options.protein.cytonuclearflag = 'nuc';
            else
                options.protein.cytonuclearflag = 'cyto';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            directory = pwd;
            dna = [directory filesep 'LAM*cell[1-30]*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell[1-30]*ch1*.tif'];
            protein = [directory filesep 'LAM*cell[1-30]*ch2*.tif'];
            options.masks = [directory filesep 'LAM*cell[1-30]*mask*.tif'];
            options.model.downsampling = [10 10 1];
            options.model.resolution=[0.049, 0.049, 0.2000];
            options.model.filename = 'LAMP2.xml';
            dimensionality = '';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            answer = img2slml( dimensionality, dna, cell, protein, options );
            testCase.verifyFalse( answer );
        end
        
        function test_dimensionality3( testCase )
            pattern = 'LAMP2';
            
            options.nucleus.type = 'cylindrical_surface';
            options.nucleus.class = 'nuclear_membrane';
            
            options.cell.type = 'ratio';
            options.cell.class = 'cell_membrane';
            
            options.protein.type = 'gmm';
            options.protein.class = 'vesicle';
            
            if strcmpi( options.protein.class, 'nuc' )
                options.protein.cytonuclearflag = 'nuc';
            else
                options.protein.cytonuclearflag = 'cyto';
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK
            directory = pwd;
            dna = [directory filesep 'LAM*cell[1-30]*ch0*.tif'] ;
            cell = [directory filesep 'LAM*cell[1-30]*ch1*.tif'];
            protein = [directory filesep 'LAM*cell[1-30]*ch2*.tif'];
            options.masks = [directory filesep 'LAM*cell[1-30]*mask*.tif'];
            options.model.downsampling = [10 10 1];
            options.model.resolution=[0.049, 0.049, 0.2000];
            options.model.filename = 'LAMP2.xml';
            dimensionality = 1;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            answer = img2slml( dimensionality, dna, cell, protein, options );
            testCase.verifyFalse( answer );
        end
    end
end

