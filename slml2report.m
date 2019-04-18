function answer = slml2report( model1_filename, model2_filename )
% SLML2REPORT Generate a report comparing two generative models
%
% List Of Input Arguments  Descriptions
% -----------------------  ------------
% model1                   A generative model filename
% model2                   A generative model filename
%
% Example
% > filename1 = '/path/to/model/model1.mat';
% > filename2 = '/path/to/model/model2.mat';
% answer = slml2report( filename1, filename2 );

% Author: Robert F. Murphy
%
% Copyright (C) 2013-2019 Murphy Lab
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
% For additional information visit http://www.cellorganizer.org or
% send email to cellorganizer@compbio.cmu.edu

answer = false;

if nargin ~= 2
    warning( ['Wrong number of input arguments. If slml2report' ...
    ' is not deployed, then the number of input arguments must be 2.'] );
    return
end

try
    load( model1_filename ); model1 = model; clear model;
    load( model2_filename ); model2 = model; clear model;
catch err
    warning('Unable to open or read model files')
    getReport(err)
    return;
end

try
    nuc_class_same = strcmp(model1.nuclearShapeModel.class, model2.nuclearShapeModel.class);
    if ~nuc_class_same
        warning('Nuclear shape model class is not the same.');
	return
    end
catch err
    getReport(err)
    return
end

try
    cell_class_same = strcmp(model1.cellShapeModel.class, model2.cellShapeModel.class);
    if ~cell_class_same
        warning('Cell shape model class is not the same.');
	return
    end
catch err
    getReport(err)
    return
end

try
    prot_class_same = strcmp(model1.proteinModel.class, model2.proteinModel.class);
    if ~prot_class_same
        warning('Protein model class is not the same.');
	return
    end
catch err
    getReport(err)
    return
end

try
    nuc_type_same = strcmp(model1.nuclearShapeModel.type, model2.nuclearShapeModel.type);
    if ~nuc_type_same
        warning('Nuclear shape model type is not the same.');
	return
    end
catch err
    getReport(err)
    return
end

try
    cell_type_same = strcmp(model1.cellShapeModel.type, model2.cellShapeModel.type);
    if ~cell_type_same
        warning('Cell Shape model type is not the same.');
	return
    end
catch err
    getReport(err)
    return
end

try
    prot_type_same = strcmp(model1.proteinModel.type, model2.proteinModel.type);
    if ~prot_type_same
        warning('Protein model type is not the same.');
	return
    end
catch err
    getReport(err)
    return
end

% param = struct([]);
% param = ml_initparam(param, struct('verbose', true, 'includenuclear', true, ...
%     'includecell', true, 'includeprot', true));
param = struct('verbose', true, 'includenuclear', true, 'includecell', true, ...
    'includeprot', true);

models{1} = model1;
models{2} = model2;
classlabels = [];
for i=1:2
    try
        classlabels = strcat(classlabels, [models{i}.proteinModel.class int2str(i) ';']);
    catch
        classlabels = strcat(classlabels, [models{i}.proteinModel.type int2str(i) ';']);
    end
    classlabels = classlabels(1:end);
end

if exist('./report', 'dir')
    rmdir('./report', 's')
end
mkdir('./report');

if isdeployed()
    fileID = fopen('./index.md', 'w');
    fprintf(fileID, '# slml2report output\n');

    fprintf( fileID,'## Filenames\n' );
    fprintf( fileID,'```\n' );
    fprintf( fileID, ['model1_filename = ' model1_filename '\n'] );
    fprintf( fileID, ['model2_filename = ' model2_filename '\n'] );
    fprintf( fileID,'```\n' );
else
    fileID = fopen('./index.m', 'w');
    fprintf(fileID, '%%%% slml2report output\n');
    fprintf(fileID, '%%%%%% Filenames\n');
    fprintf(fileID, 'model1_filename = ''%s'';\n', model1_filename);
    fprintf(fileID, 'model2_filename = ''%s'';\n', model1_filename);
    fprintf(fileID, '\n');
end

%%%%%%%%%%%%%%%%%%%%%%% SWITCH STATEMENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isdeployed()
    f = @models2report_running_when_deployed;
else
    f = @models2report_running_on_matlab_engine;
end

switch model1.proteinModel.class
    case 'vesicle'
        switch model1.proteinModel.type
            case 'gmm'
                f(models, param, classlabels, fileID);
            otherwise
                fprintf('Case for proteinModel.type: ''%s'' ot yet implemented', ...
                    model1.proteinModel.type);
                return
        end
    otherwise
        fprintf('Case for proteinModel.class: ''%s'' not yet implemented', ...
            model1.proteinModel.class);
        return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fileID);

if isdeployed()
    system(['pandoc ' pwd filesep 'index.md -o index.html']);
    if exist([pwd filesep 'index.html'], 'file')
        movefile([pwd filesep 'index.html'], [pwd filesep 'report']);
    end
else
    publish('./index.m');
    movefile('./html/index.html', './report');
    rmdir('./html', 's');
end

image_info = dir('*.png');
image_names = {image_info.name};
for i = 1:length(image_names)
    movefile(image_names{i}, ['report' filesep image_names{i}]);
end

if exist('./index.m', 'file')
    delete('./index.m')
end
if exist('./index.md', 'file')
    delete('./index.md')
end

close all
answer = true;
end
