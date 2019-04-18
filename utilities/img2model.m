function model = img2model( dna_images, cell_images, prot_images, options)
%IMG2MODEL Trains a generative model of protein subcellular location from a
%collection of microscope images.
%
% See also IMG2SLML

% Ivan E. Cao-Berg
%
% Copyright (C) 2007-2018 Murphy Lab
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
% For additional information visit http://murphylab.web.cmu.edu/ or
% send email to murphy@cmu.edu

% ?? ??, 2011 I. Cao-Berg Added 3D model training functionality
% March 23, 2012 I. Cao-Berg Added the creation/deletion of temporary folder
% March 28, 2012 I. Cao-Berg Added a control structure under which if one or more of the
%                image folders are nonexistent or they do not contain images,
%                the method exits
% March 28, 2012 I. Cao-Berg Added verification of input arguments when training a 2D
%                            generative model
% March 28, 2012 I. Cao-Berg Added verification of input arguments when training a 3D
%                            generative model
% April 10, 2012 I. Cao-Berg Added debug flag to the method. If flag is true, temporary
%                            files will not be deleted
%
% April 11, 2012 I. Cao-Berg Added verbose flag to the method
% April 17, 2012 I. Cao-Berg Returns an empty model when model cannot be trained
% July 5, 2012 I. Cao-Berg Added training flags to method so that users can train whatever component they wish
% July 26, 2012 Y.Yu Fixed a bug of the order of input argument for ml_traingenmodel2D method
% August 29, 2012 G. Johnson Modified method call to include parameter structure
% May 7, 2013 I. Cao-Berg Included support of masks when training a model
% only for the 2D case
% May 8, 2013 I. Cao-Berg Removed check for the existence of image folder since the check will happen later in the code
% May 15, 2013 I. Cao-Berg Updated method to support wildcards
% June 7-13 2013 D. Sullivan Major refactoring to support parallel/per-cell
%                            parameter calcultaions for 3D
%
% Jul 22, 2013 G. Johnson    Added parameter to skip preprocessing entirely
%                            and use only currently existing preprocessing
%                            results
% Aug 2, 2013 G. Johnson     Fixed logic so that prot_image_files are not
%                            overwritten by an empty cell array if they exist
% Aug 2, 2013 G. Johnson     Implemented chunk_start parallelization on
%                            per-cell parameterization
% Aug 30, 2013 G. Johnson    Changed they way files are input into the
%                            diffeomorphic model function
% March 14, 2014 I. Cao-Berg Changed method so that if param.masks is empty
%                            or nonvalid it displays a warning
% December 16, 2015 I. Cao-Berg Removed check so that you can pass a list
% of files as well
%
% March 12, 2017 R.F. Murphy Avoid errors if cell array of filenames is
%                            missing for cell, dna or protein (affected
%                            nuclear hole finding); Ignore cells that
%                            can't be parameterized

model = [];

%icaoberg march 28, 2012
%check the existence of the image directory
if ~exist('options', 'var')
    options = [];
end

options = ml_initparam( options, struct( 'display', false ,...
    'debug', false, ...
    'verbose', false, ...
    'paramdir', [pwd filesep 'param'], ...
    'tempparent', [pwd filesep 'temp']));

check_required_options(options, {'dimensionality'})
check_required_options(options.model, {'resolution'})

[dna_images, cell_images, prot_images, options] = setup_data(dna_images, ...
    cell_images, prot_images, options);

options = setup_model_options(dna_images, cell_images, prot_images, options);

paramfiles = cell(size(dna_images));
isdone = false(size(dna_images));

% xruan 08/21/2016
% set the interface that reduce the crossing with other models. And
% ultimately we can convert to CellOrganizer version 3.x
if strcmp(options.protein.type, 'standardized_map_half-ellipsoid')
    t_cell_info = options.t_cell_info;
    [t_cell_info, options] = tcell_imgs2params(t_cell_info, options);
    
    [t_cell_info, options] = tcell_build_models(t_cell_info, options);
    
    [t_cell_info, options] = tcell_adapt_models(t_cell_info, options);
    
    model = t_cell_info;
    return;
end

for i = 1:max([length(dna_images),length(cell_images),length(prot_images)])
    paramfiles{i} = [options.paramdir filesep 'param' num2str(i) '.mat'];
    
    tmpfile = [paramfiles{i} '.tmp'];
    if exist(tmpfile, 'file')
        continue
    elseif exist(paramfiles{i}, 'file')
        isdone(i) = true;
        continue
    end
    
    system(['touch "' tmpfile '"']);
    
    [imdna,options.dna_image_path] = readfileifnonblank(dna_images,i);
    [imcell,options.cell_image_path] = readfileifnonblank(cell_images,i);
    [improt,options.protein_image_path] = readfileifnonblank(prot_images,i);
    [immask,options.crop_image_path] = readfileifnonblank(options.masks,i);
    
    if ~isa(imdna, 'uint8' )
        imdna = uint8(imdna);
    end
    
    if ~isa(imcell, 'uint8' )
        imcell = uint8(imcell);
    end
    
    if ~isa(improt, 'uint8' )
        improt = uint8(improt);
    end
    
    if ~isa(immask, 'uint8' )
        immask = uint8(immask);
    end
    
    %    options.dna_image_path = copypathifnonblank(dna_images,i);
    %    options.cell_image_path = copypathifnonblank(cell_images,i);
    %    options.protein_image_path = copypathifnonblank(prot_images,i);
    %    options.crop_image_path = copypathifnonblank(options.masks,i);
    
    savedir = [options.paramdir filesep 'param' num2str(i)];
    
    try
        [cell_params] = img2param(imdna, imcell, improt, immask, savedir, options);
        if ~isempty(cell_params)
            save(paramfiles{i}, '-struct', 'cell_params')
            isdone(i) = true;
            
            delete(tmpfile);
        end
    catch the_error
        warning(['Unable to extract parameters for cell ' num2str(i) ...
            ': it will be ignored.']);
        getReport( the_error )
        disp( 'Check the images exist or that you are using the correct options.' );
    end
end
goodparamfiles = paramfiles(isdone);

%%%%%%%%%%%%%%%%%% MAKE MODEL FROM GOOD PARAMETERIZATIONS %%%%%%%%%%%%%%%%%
model  = param2model(goodparamfiles, options);
end

function check_required_options(options, required_fields)
ismissing = false(size(required_fields));
for i = 1:length(required_fields)
    if ~isfield(options, required_fields{i})
        ismissing(i) = true;
    end
end
if any(ismissing)
    error(['Missing options fields: ' strjoin(required_fields(ismissing), ', ')])
end
end


function [dna_images, cell_images, prot_images, options] = setup_data(dna_images, cell_images, prot_images, options)

options = ml_initparam(options, struct('masks', []));

if ~exist(options.paramdir, 'dir')
    mkdir(options.paramdir);
end

%if a single string is passed in, it may be a wildcard, so get all files
%associated with that
if ischar(dna_images)
    dna_images = ml_ls(dna_images);
end

if ischar(cell_images)
    cell_images = ml_ls(cell_images);
end
if isempty(cell_images)
    cell_images = cell(size(dna_images));
end

if ischar(prot_images)
    prot_images = ml_ls(prot_images);
end
if isempty(prot_images)
    prot_images = cell(size(dna_images));
end


if ischar(options.masks)
    options.masks = ml_ls(options.masks);
end
if isempty(options.masks)
    options.masks = cell(size(dna_images));
end

if isempty(cell_images) && ~isempty(options.protein.type) && strcmp(options.protein.type, 'standardized_map_half-ellipsoid')
    [cell_images, options] = tcell_setup_options(options);
end
end

function options = setup_model_options(dna_images, cell_images, prot_images, options)
%this function sets the default model options for cellorganizer
component_struct = struct('type', '', ...
    'name', '', ...
    'id', '');

% add the model file location

options = ml_initparam(options, struct('nucleus', []));
% xruan 01/05/2016 change ml_initparam(options, component_struct); to ml_initparam(options.nucleus, component_struct);
options.nucleus = ml_initparam(options.nucleus, component_struct);
options.documentation.numimgs = numel(dna_images);

if strcmpi(options.dimensionality, '2D')
    if isempty(options.nucleus.type)
        options.nucleus.type = 'medial axis';
    end
    
    if ~all(cellfun(@isempty, cell_images)) && isempty(options.cell.type)
        options.cell.type = 'ratio';
    end
    
    if ~all(cellfun(@isempty, prot_images)) && isempty(options.protein.type)
        options.protein.type = 'vesicle';
    end
    
elseif strcmpi(options.dimensionality, '3D')
    if isempty(options.nucleus.type)
        options.nucleus.type = 'cylindrical_surface';
    end
    
    if ~all(cellfun(@isempty, cell_images)) && isempty(options.cell.type)
        options.cell.type = 'ratio';
    end
    
    if ~all(cellfun(@isempty, prot_images)) && isempty(options.protein.type)
        options.protein.type = 'vesicle';
    end
else
    error('Unsupported dimensionality. Exiting method.')
end
end

function [img,filename] = readfileifnonblank(files,i)
if ~isempty(files)
    filename = files{i};
    
    if ~isempty( filename )
        if ~strcmpi(class(filename), 'function_handle')
            disp(['Reading file ' filename] );
        end
    end
    img = ml_readimage(filename);
else
    filename = [];
    img = [];
end
end

function filename = copypathifnonblank(files,i)
if ~isempty(files)
    filename = files{i};
else
    filename = [];
end
end
