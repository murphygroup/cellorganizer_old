function answer = vesicle_comparison(model1, model2, output)
% vesical model comparsion, currently only support two model comparison
% 
% This method shows the use of slml2report for creating comparisons between
% parameters of CellOrganizer models.
%
% What you need:
% -------------
% * (Required) Two CellOrganizer vesicle models
%   - same dimensionality
%   - both are not diffeomorphic
%   - both have proteinModel class = vesicle and type = gmm
% * (Optional) A path to the directory where you want the output to be
%
% Output
% ------
% * An .html report comparing the two vesicle models, in the specified 
%   output directory. If input models were invalid, the report contains
%   a corresponding error message.
%   If no directory specified, outputs report in current directory.

% Created: Xiongtao Ruan
% Tested: Ulani Qi
% 
% Copyright (C) 2013-2016 Murphy Lab
% Lane Center for Computational Biology
% School of Computer Science
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
% For additional information visit http://murphylab.web.cmu.edu or send
% email to murphy@cmu.edu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT MODIFY THIS BLOCK
answer = false;
current_path = which(mfilename);
[current_path, filename, extension] = fileparts( current_path );
cd(current_path);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEEL FREE TO MODIFY THE VARIABLES IN THIS BLOCK

if nargin < 2
    close all;
    main_html = strcat('<!DOCTYPE html><html><body>');
    main_html =  strcat(main_html,'<p>Not enough arguments provided.</p>');
    main_html = strcat(main_html,'</body></html>');
    output=current_path;
    fid = fopen(strcat(output,'/index.html'),'w');
    fprintf(fid,'%s',main_html);
    fclose(fid);
    answer = false;
    return
elseif nargin < 3
    if(~(exist(model1,'file')==2) || ~(exist(model2,'file')==2))
        if (exist(model1)==7)
            output = model1;
        elseif(exist(model2)==7)
            output = model2;
        end
        close all;
        main_html = strcat('<!DOCTYPE html><html><body>');
        main_html =  strcat(main_html,'<p>Not enough model files provided.</p>');
        main_html = strcat(main_html,'</body></html>');
        fid = fopen(strcat(output,'/index.html'),'w');
        fprintf(fid,'%s',main_html);
        fclose(fid);
        answer = false;
        return
    else
        instances = { model1, model2 };  
        output = current_path;
    end
elseif nargin == 3
    instances = { model1, model2 };  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m1 = load(model1);
m2 = load(model2);
disp( 'Generating report for all parameters' );
if strcmp(m1.model.cellShapeModel.type,'diffeomorphic')==1 || strcmp(m1.model.cellShapeModel.type,'diffeomorphic')==1
   close all;
    main_html = strcat('<!DOCTYPE html><html><body>');
    main_html =  strcat(main_html,'<p>Cannot compare diffeomorphic models.</p>');
    main_html = strcat(main_html,'</body></html>');

    fid = fopen(strcat(output,'/index.html'),'w');
    fprintf(fid,'%s',main_html);
    fclose(fid);
    answer = false;
    return
end
if strcmp(m1.model.proteinModel.type,'gmm')==0 || strcmp(m1.model.proteinModel.class,'vesicle')==0 ...
   || strcmp(m2.model.proteinModel.type,'gmm')==0 || strcmp(m2.model.proteinModel.class,'vesicle')==0 ...
   || isfield(m1.model, 'proteinModel')==0 || isfield(m2.model,'proteinModel')==0
	close all;
    main_html = strcat('<!DOCTYPE html><html><body>');
    main_html =  strcat(main_html,'<p>Cannot compare two models with invalid proteinModel type and class.</p>');
    main_html = strcat(main_html,'</body></html>');

    fid = fopen(strcat(output,'/index.html'),'w');
    fprintf(fid,'%s',main_html);
    fclose(fid);
    answer = false;
elseif strcmp(m1.model.dimensionality,m2.model.dimensionality)==0
        close all;
        main_html = strcat('<!DOCTYPE html><html><body>');
        main_html =  strcat(main_html,'<p>Cannot compare two models with different dimensionality.</p>');
        main_html = strcat(main_html,'</body></html>');

        fid = fopen(strcat(output,'/index.html'),'w');
        fprintf(fid,'%s',main_html);
        fclose(fid);
        answer = false;
else
    close all;
    if strcmp(m1.model.dimensionality,'3D')==1 && strcmp(m1.model.proteinModel.class,'vesicle')==1 ...
        && strcmp(m1.model.proteinModel.type,'gmm')==1
        param = ml_initparam([],struct('verbose',true,'includenuclear',true,'includecell',true,'includeprot',false));
    else
        param = ml_initparam([],struct('verbose',true,'includenuclear',true,'includecell',true,'includeprot',true));
    end
    
    slml2report(instances,param);
    figHandles = get(0,'Children');

    figure_num = numel(figHandles);
    figure_names = {};

    for i = 1 : figure_num
        figure_names{i} = sprintf('%s/figure_%d.png', output, i);
        saveas(figHandles(i), figure_names{i});
    end

    % output as html file

    main_html = strcat('<!DOCTYPE html><html><body>');

    % figure 1
    main_html =  strcat(main_html, '<h2>Number of Objects</h2>');
    main_html =  strcat(main_html,'<p>Comparison of the distribution of the number of objects for the two trained models. Values are in logarithmic scale.</p>');
    main_html =  strcat(main_html,'<img src="figure_1.png" style="width:600px;height:600px;">');

    % figure 2
    main_html =  strcat(main_html, '<h2>Object spatial distributions</h2>');
    main_html =  strcat(main_html,'<p>Comparison of the spatial distribution of vesicular objects by the fractional distances between nuclear and plasma membranes.</p>');
    main_html =  strcat(main_html,'<img src="figure_2.png" style="width:600px;height:600px;">');

    % figure 3
    main_html =  strcat(main_html, '<h2>Parameters ordered by extent of variation</h2>');
    main_html =  strcat(main_html,'<p>Plot of parameters ordered by extend of variation. The left axis points are values for the first model and the right for the second model.</p>');
    main_html =  strcat(main_html,'<img src="figure_3.png" style="width:600px;height:600px;">');

    % figure 4
    main_html =  strcat(main_html, '<h2>Comparison of different factors</h2>');
    main_html =  strcat(main_html,'<p>Plots of various properties of the trained models. In each plot, the left axis points are values for the first model and the right for the second model. Here we show surface area, eccentricity, major axis length, volume of cells.</p>');
    main_html =  strcat(main_html,'<img src="figure_4.png" style="width:600px;height:600px;">');

    % figure 5
    main_html =  strcat(main_html, '<h2>Detailed comparison of parameters</h2>');
    main_html =  strcat(main_html,'<p>The figure shows the comparison of all main parameters of the models. In each plot, the left axis points are values for the first model and the right for the second model.</p>');
    main_html =  strcat(main_html,'<img src="figure_5.png" style="width:600px;height:600px;">');


    % <h2>Spectacular Mountain</h2>
    % <img src="pic_mountain.jpg" alt="Mountain View" style="width:304px;height:228px;">

    main_html = strcat(main_html,'</body></html>');

    fid = fopen(strcat(output,'/index.html'),'w');
    fprintf(fid,'%s',main_html);
    fclose(fid);
    answer = true;
end
end
