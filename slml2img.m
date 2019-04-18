function answer = slml2img( varargin )
% SLML2IMG Synthesizes an image from a list of SLML models.
%
% Instances may be saved in the following forms:
% a) tiff stacks: a 3D tiff image stack for each pattern generated using the input models
% b) indexed images: a single 3D tiff image stack where each pattern is represented by a number 1-n
% c) object mesh: a .obj mesh file for each pattern generated using the input models (blenderfile option)
% d) SBML-Spatial file: a Systems Biology Markup Language (SBML) instance XML file utilizing the Spatial extension in level 3 version 1
%
% List Of Input Arguments  Descriptions
% -----------------------  ------------
% models                   A cell array of filenames
% options                  A structure holding the function options
%
% The shape of options is described
%
% List Of Parameters        Descriptions
% ------------------        ------------
% targetDirectory           (optional) Directory where the images are going to be saved. Default is current directory.
% prefix                    (optional) Filename prefix for the synthesized images. Default is 'demo'
% numberOfSynthesizedImages (optional) Number of synthesized images. Default is 1.
% compression               (optional) Compression of tiff, i.e. 'none', 'lzw' and 'packbits'
% microscope                (optional) Microscope model from which we select a point spread function. Default is 'none'
% synthesis                 (optional) Synthesis parameter that allows to
%                                      synthesize 'nucleus', 'framework' or 'all'. Default is 'all'
% protein.cytonuclearflag   (optional) Defines the allowable region for protein placement.
%                                      The default is the cytonuclearflag included in the model.
% sampling.method           (optional) Can be 'disc', 'sampled' or 'trimmed'. Default is trimmed
% savePDF                   (optional) Saves the probability density function for a given pattern during 2D synthesis. Default is false.
% spherical_cell            (optional) Boolean flag that indicates whether a cell is spherical. Default is false.
% overlapsubsize            (optional) Defines the downsampling fraction to perform during object overlap avoidance. Default is 0.3.
% overlapthresh             (optional) Defines the amount of overlap that is allowed between objects. Default is 1.
% rendAtStd                 (optional) Defines the number of standard deviations to render Gaussian objects at. Default is 2.
% sampling.method.density   (optional) An integer. Default is empty.
% protein.cytonuclearflag   (optional) Can 'cyto', 'nucleus' or 'all'. Default is all.
% resolution.cell           (optional) The resolution of the cell and nucleus that are being passed in
% resolution.objects        (optional) The resolution of the object model being synthesized
% instance.cell             (optional) A binary cell image to be filled with objects. Default is empty.
% instance.nucleus          (optional) A binary nuclear image to be filled with objects. Default is empty.
% image_size                (optional) The image size. Default is [1024 1024] for both 2D and 3D in x and y
% synthesis.diffeomorphic.maximum_iterations (optional) Integer defining the maximum number of iterations during diffeo inference. Default is 100.
%
% Random walk options
% -------------------
% randomwalk                (optional) Boolean flag of whether to perform a shape space walk. Default is False.
% framefolder               (optional) The folder in which to look for completed frames and save finished frames from the diffeomorphic synthesis.
%                                      The default is './frames/'.
% walksteps                 (optional) The integer number of steps to walk during a shape space walk. Default is 1.
% walk_type                 (optional) Type of random walk to perform. Default is 'willmore'.
%
% Helper options
% --------------
%
% debug                     (optional) Keeps temporary results and catches
%                           errors with full reports. Default is false;
% display                   (optional) Will make pretty plots. Turning this
%                           flag on will slow down synthesis. Default is
%                           false.
% verbose                   (optional) Print the intermediate steps to screen. Default is false.
%
% Outputs
% -------
% output.tifimages           (optional) Boolean flag specifying whether to write out tif images. Default is true.
% output.indexedimage        (optional) Boolean flag specifying whether to write out indexed image. Default is false.
% output.blenderfile         (optional) Boolean flag specifying whether to write out (.obj) files for use in blender. Default is false;
% output.blender.downsample  (optional) downsampling fraction for the creation of object files (1 means no downsampling, 1/5 means 1/5 the size).
% output.SBML                (optional) boolean flag specifying whether to write out (.xml) files with SBML-Spatial 2 representations of geometries. Default is false;
% output.SBMLSpatial         (optional) boolean flag specifying whether to write out (.xml) file with SBML-Spatial 3 representations of geometries. Default is false.
% output.VCML                (optional) boolean flag specifying whether to write out VCML files for use with Virtual Cell. Default is false.
% output.OMETIFF             (optional) boolean flag specifying whether to write out an (.ome.tif) OME TIFF. Default is false.
%
% PCA model options
% ------------------
% model.pca.pca_synthesis_method   (mandatory)['reconstruction' or 'random sampling']
% model.pca.imageSize              (mandatory)
%
%3D SPHARM-RPDM model options
% ------------------
%model.spharm_rpdm.synthesis_method        ['reconstruction' or 'random sampling']
%
%
%T cell distribution model options
% ------------------
% model.tcell.results_location            (mandatory)File path for where the results should be saved.
% model.tcell.named_option_set            (mandatory)The running choice for CellOrganizer and one sensor of two-point annotation
% model.tcell.use_two_point_synapses      (optional)Set up the mode of synapse to use, as a default, we use one-point, 
%                                         if needed you can use two-point by set up the option as true
% model.tcell.sensor                      (mandatory)Set up protein name
% model.tcell.timepoints_to_include       (optional)If creation of models for only a subset of the time points is desired,
%                                         edit to specify which time points to include
% model.tcell.model_type_to_include       (mandatory)Set up for model to include


% Example
% -------
% instances = { 'model01.xml', 'model02.mat', 'model03.mat' };
% options.targetDirectory = pwd;
% options.prefix = 'demo'
% options.numberOfSynthesizedImages = 100;
% options.compression = 'lzw';
% options.microscope = 'svi';
% options.verbose = true;
%
% >> slml2img( instances, options );

% Ivan E. Cao-Berg (icaoberg@cmu.edu)
%
% Copyright (C) 2007-2018 Murphy Lab
% Computational Biology Department
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

% March 7, 2012 R.F.Murphy  Don't create directory to hold 3D images if
%                           generating 2D
%
% March 8, 2012 I. Cao-Berg Documented the method
%
% March 9, 2012 I. Cao-Berg Changed disp to fprintf and improved logs
%
% March 9, 2012 I. Cao-Berg Removed print of progress bar from log file
%
% March 21, 2012 I. Cao-Berg Changed protein.location to protein.cytonuclearflag
%
% April 11, 2012 I. Cao-Berg Removed removal of temporary folder
%
% June 5, 2012 M. Mackie    Added option to save as an index image using
%                           options.image.type and options.image.option
%
% June 6, 2012 M. Mackie	Removed parameter image.option (index images
%							may only be saved as 'priority'
%
% July 25, 2012 D. Sullivan Added fields options.blender.file and options.blender.downsample
%                           Created option for saving .obj files for exporting to blender
%
% July 26, 2012 D. Sullivan Changed options.image and options.blender structures
%                           to options.output structure (see header for usage)
%
% July 30, 2012 I. Cao-Berg Modified code that is res files in the temporary folder rather than
%                           the folder itself. This way if a user trains a model and synthesizes
%                           images in the same script, the temp folder remains intact in case it is
%                           run in debug mode
%
% August 20, 2012 I. Cao-Berg Renamed img2blender to im2blender
%
% October 1, 2012 I. Cao-Berg Removed deprecated code from previous versions
%
% October 9, 2012 I. Cao-Berg Added print of the error stack if method
% fails to synthesize an image
%
%January 28, 2012 I. Cao-Berg Updated try/catch statement to print an
% error report when running debug mode
%
% April 29, 2013 D. Sullivan added documentation for options.debug
%
% May 18, 2013 I . Cao-Berg Updated method so if framework fails to
% synthesize it returns an empty framework
%
% June 7, 2013 R. Arepally added the variable shiftvector as a parameter to
% the im2blender function. This fixes the bug of inconsistant shifting of
% different objects when the blender files are created.
%
% July 23, 2013 D. Sullivan added primitives type of output
%
% January 25, 2016 I. Cao-Berg Fixed bug where method was overwritting
% existing frameworks and appending protein patterns
%
% April 4, 2016 I. Cao-Berg Updated method to reflect the refactoring
%
% November 10, 2016 I. Cao-Berg Added support for SBML Spatial 3
%
% November 15, 2016 I. Cao-Berg Added support for OME.TIFF
%
% November 28, 2016 I. Cao-Berg Included new option that allows users to overwrite synthetic images
%
% January 25, 2017 I. Cao-Berg Fixed issue with the code where call to SBML
%                   Spatial fails if output flag is missing
%
% January 13, 2018 I. Cao-Berg Cleaned up method
%
% February 20, 2018 I. Cao-Berg Updated method to save 2D images as OMETIFF

%icaoberg 6/1/2013

answer = false;

if isdeployed
    disp('Running deployed version of slml2img');
    
    if length(varargin) == 1
        text_file = varargin{1};
    else
        error('Deployed function takes only 1 argument. Exiting method.');
        return
    end
    
    [filepath, name, ext] = fileparts(text_file);
    
    if ~exist(text_file, 'file')
        warning('Input file does not exist. Exiting method.');
        return
    end
    
    disp(['Attempting to read input file ' text_file]);
    fid = fopen(text_file, 'r' );
    
    disp('Evaluating lines from input file');
    while ~feof(fid)
        line = fgets(fid);
        eval(line);
    end
    
    fclose(fid);
else
    if length(varargin) >= 1
        filenames = varargin{1};
        options = varargin{2};
    else
        warning('At least one argument must be provided. Exiting method');
        return;
    end
end

options = get_cellorganizer_default_parameters( 'synthesis', options );

%icaoberg 10/9/2012
synthesis = options.synthesis;
disp('Setting synthesis option');
if ~strcmpi( synthesis, 'nucleus' ) && ~strcmpi( synthesis, 'cell' ) && ...
        ~strcmpi( synthesis, 'framework' ) && ~strcmpi( synthesis, 'all' )
    disp('Unknown synthesis option. Setting synthesis option to '' all ''');
    synthesis = 'all';
else
    synthesis = lower( synthesis );
end

% R. Arepally 6/7/13 shiftvector empty array is instantiated
% so that it can be passed to im2blender.
shiftvector = [];

%mmackie June 1st 2012
%see what type of image to return, default is tif
%dsullivan July 26 2012
%edited from try-catch to if statement and changed from
%options.image to options.output
%moved to top of program, no reason to be checking this now
%D. Sullivan 12/4/14 - updated supported outputs
if ~isfield(options,'output')
    options.output.tifimages = true;
elseif ~isfield(options.output,'tifimages') && ...
        ~isfield(options.output,'indexedimage')&& ...
        ~isfield(options.output,'blenderfile') && ...
        ~isfield(options.output,'SBML') && ...
        ~isfield(options.output,'VCML')
    error(['CellOrganizer: Unsupported output specified. Supported ' ...
        'outputs for options.output are tifimages,indexedimage, and SBML.'])
end

%LOGS
try
    if options.verbose
        disp( 'Checking existence of log folder' );
    end
    
    if ~exist( [ pwd filesep 'log'], 'dir' )
        if options.verbose
            disp( ['Making log directory ' pwd filesep 'log' ] );
        end
        mkdir( 'log' );
    end
    
    c = clock;
    logfile = '';
    for i=1:1:length(c)
        logfile = ['',logfile,num2str(c(i))]; %#ok<AGROW>
    end
    logfile = [ pwd filesep 'log' filesep logfile, '.log' ];
    
    fileID = fopen( logfile, 'w' );
catch err
    warning( 'CellOrganizer: Failed to create log file. Exiting program.' ) %#ok<*WNTAG>
    
    %icaoberg 3/5/2015
    getReport( err, 'extended' )
end

if options.verbose
    fprintf( 1, '%s', 'Checking the validity of input files');
end

%icaoberg 7/1/2013
if isempty( filenames )
    disp( 'List of models cannnot be empty. Exiting method.' );
    return
end

if ~isa( filenames, 'cell' )
    disp( 'List of models must be a cell array. Exiting method.' );
    return
end

fprintf( fileID, '%s', 'Checking the validity of input files' );
for i=1:1:length(filenames)
    if ~isaFile( filenames{i} )
        if options.verbose
            fprintf( 1, '\n%s', ['Input argument ' filenames{i} ' is not a file'] );
        end
        
        fprintf( fileID, '\n%s', ['Input argument ' filenames{i} ' is not a file'] );
        fclose( fileID );
        
        %icaoberg 7/1/2013
        disp( ['Input argument ' filenames{i} ' is not a file'] );
        return
    else
        n=length(filenames);
    end
end

% %parse SLML instances into Matlab structures
% icaoberg 7/1/2013
if options.verbose
    fprintf( 1, '\n%s', 'Parsing SLML instances' );
end

fprintf( fileID, '%s', 'Parsing SLML instances' );
try
    for j=1:1:length(filenames)
        %if it is a mat file then load directly into memory
        if( isMatFile(filenames{j}) )
            load(filenames{j});
            models{j} = model;
        else
            models{j} = slml2model( filenames{j} );
        end
        
        n = length(filenames);
    end
catch err
    warning( 'Unable to parse SLML instances. Exiting program.' );
    fprintf( fileID, '%s\n', 'Unable to parse SLML instances. Exiting progam.' );
    
    %icaoberg
    if options.debug
        getReport( err, 'extended' )
    end
    
    if options.verbose
        fprintf( 1, '%s\n', 'Unable to parse SLML instances. Exiting progam.' );
    end
    
    fprintf( fileID, '%s\n', 'Closing log file' );
    fclose( fileID );
    
    if ~isdeployed
        return
    else
        exit
    end
end

if isempty( models )
    warning( 'No model able to be loaded from filenames provided. Exiting method' );
    return;
end

%TEMPORARY FOLDER
disp( 'Checking existence of temporary folder' );

%icaoberg 7/30/2012
if exist(options.temporary_results, 'dir' )
    disp(['Temporary folder found in ' options.temporary_results '. Removing all temporary files.'] );
    
    %removes temp image files and temp results related to microtubules
    clean_synthesis_temp_files();
else
    disp( ['Creating temporary folder in ' options.temporary_results ]);
    mkdir(options.temporary_results);
end

%SETTING ARGUMENTS

%setting target directory
targetDirectory = options.targetDirectory;

if isempty( targetDirectory )
    targetDirectory = pwd;
end

disp( ['Setting target directory to ' targetDirectory ] );

%icaoberg 12/2/2013
if ~exist( targetDirectory )
    disp( 'Target directory does not exist. Making target directory.' );
    mkdir( targetDirectory )
end

%setting prefix
prefix = options.prefix;

fprintf( fileID, '%s\n', ['Setting prefix to: ' prefix ]  );
if options.verbose
    fprintf( 1, '%s\n', ['Setting prefix to: ' prefix ]  );
end

%setting number of synthesized images
numberOfSynthesizedImages =  options.numberOfSynthesizedImages;

disp( ['Setting number of synthesized images to ' num2str(numberOfSynthesizedImages) ]  );

%setting compression
compression = options.compression;
disp( ['Setting compression to ' compression ] );

try  
    dimensionality = models{1}.dimensionality;
catch
    warning('Unable to set model dimensionality');
end

disp('Checking all models have the same dimensionality');

for i=1:1:length(models)
    if ~strcmpi( models{i}.dimensionality, dimensionality )
        disp('Models have different dimensionality. Unable to synthesize image. Exiting method.');
        
        if ~isempty( fileID )
            fprintf( fileID, '%s\n', 'Models have different dimensionality. Unable to synthesize image.' );
        end
        
        return;
    end
end

if strcmpi(dimensionality, '3D')
    maxres = inf(1,3);
elseif strcmpi(dimensionality, '2D')
    maxres = inf(1,2);
else
    error('CellOrganizer: unsupported dimensionality')
end

%setting protein resolution
disp( 'Setting protein model resolution')
for i = 1:length(models)
    if isfield(models{i}, 'proteinModel')
        maxres = min(models{i}.proteinModel.resolution,maxres);
    elseif isfield(models{i},'cellShapeModel')
        maxres = min(models{i}.cellShapeModel.resolution,maxres);
    elseif isfield(models{i},'nuclearShapeModel')
        maxres = min(models{i}.nuclearShapeModel.resolution,maxres);
    end
end

%icaoberg 11/5/2014
if isfield( options, 'resolution' )
    options.resolution = ml_initparam(options.resolution,struct('objects',maxres));
else
    options.resolution.objects = maxres;
end
disp(['Protein model object(s) resolution set to ' options.resolution.objects ]);

options.resolution.cubic = ...
    repmat(min(options.resolution.objects),...
    size(options.resolution.objects,1),size(options.resolution.objects,2));

%synthesize multicolor images and save them to disk
for i=1:1:numberOfSynthesizedImages
    if ~options.overwrite_synthetic_instances
        if exist([options.targetDirectory filesep options.prefix filesep 'cell' num2str(i)])
            continue
        end
    else
        temporary_target_directory = ...
            [options.targetDirectory filesep options.prefix filesep 'cell' num2str(i)];
        if exist( temporary_target_directory )
            rmdir(temporary_target_directory, ...
                's' );
            mkdir(temporary_target_directory);
        end
    end
    
    if options.verbose
        disp( ['Synthesizing image ' num2str(i) '. Please wait, this might take several minutes.' ] );
    end
    
    options.fileID = fileID;
    
    %D. Sullivan 2/24/14
    imgs = model2img( models, options );
    %    imgs = model2img_modular( models, options );
    
    %mmackie June 1st 2012
    %see what method for determining index, default is summation
    %dsullivan July 26 2012
    %changed to options.output boolean flag structure
    if field_exists_and_true(options.output,'indexedimage')
        mapping = 1:length(imgs);
        mapping(1) = 2;
        mapping(2) = 1;
        
        %icaoberg 8/10/2012
        imgs{end+1} = ims2index(imgs,mapping);
        
    end
    
    if isempty( imgs )
        disp( ['Unable to synthesize image ' ...
            num2str(i) ' from the given models. Continuing synthesis.'] );
        continue
    end
    
    if strcmpi( models{1}.dimensionality, '2d' )
        temporary_file = [ options.temporary_results filesep 'image.mat' ];
        
        if options.output.tifimages
            if exist( temporary_file )
                load( temporary_file );
                
                outdir = [ targetDirectory filesep prefix filesep 'cell' num2str(i) ];
                if ~exist( outdir, 'dir' )
                    mkdir ( outdir )
                end
                img2tif( imgs{1},[ outdir filesep 'cell' num2str(i) ...
                    '.tif'], compression );
                clear img
            end
        end
        
        if options.output.OMETIFF
            if exist( temporary_file )
                load( temporary_file );
                
                outdir = [ targetDirectory filesep prefix filesep 'cell' num2str(i) ];
                if ~exist( outdir, 'dir' )
                    mkdir ( outdir )
                end
                
                temporary_file = [options.temporary_results filesep 'image.mat'];
                temporary_image = load( temporary_file );
                temporary_image = temporary_image.imgs{1};
                
                list_of_input_images = {};
                list_of_channel_labels = {};
                for index=1:1:size(temporary_image, 3)
                    list_of_input_images{index} = [options.temporary_results filesep 'channel' num2str(index) '.tif' ];
                    img2tif( temporary_image(:,:,index), list_of_input_images{index}, 'lzw' );
                    list_of_channel_labels{index} = ['channel' num2str(index)];
                end
                
                output_filename = [outdir filesep ...
                    'cell' num2str(i) '.ome.tif'];
                parameters.PhysicalSizeX = options.resolution.objects(1);
                parameters.PhysicalSizeY = options.resolution.objects(2);
                parameters.list_of_channel_labels = list_of_channel_labels;
                
                answer = tif2ometiff( list_of_input_images, output_filename, parameters );
                clear temporary_image list_of_channel_labels;
                delete([options.temporary_results filesep 'channel*.tif' ]);
            end
        end
        
        if exist( temporary_file )
            delete( temporary_file );
        end
    else
        %icaoberg 01/25/2016
        %made changes to prevent overwritten existing cell image folders
        index = length(dir([targetDirectory filesep prefix filesep 'cell*']))+1;
        outdir = [ targetDirectory filesep prefix filesep 'cell' num2str(i) ];
        if ~exist( outdir, 'dir' )
            mkdir ( outdir )
        end
        
        %if indexed image flag is true, save as indexed image
        if field_exists_and_true(options.output,'indexedimage')
            if options.verbose
                disp( 'Saving indexed image' );
            end
            
            fprintf( fileID, '%s\n', 'Saving indexed image' );
            img2tif( imgs{end}, [ outdir filesep 'indexed.tif'], compression, true) ;
        end
        
        %icaoberg 10/9/2012
        if strcmpi( synthesis, 'nucleus' ) || strcmpi( synthesis, ...
                'framework' ) || strcmpi( synthesis, 'all' )
            load( [ options.temporary_results filesep 'image1.mat' ] );
            %added conditional for synthesis option
            if field_exists_and_true(options.output,'tifimages')
                if options.verbose
                    disp( 'Saving nuclear channel tif image' );
                end
                
                fprintf( fileID, '%s\n', 'Saving nuclear channel tif image'  );
                img2tif( img, [ outdir filesep 'nucleus.tif'], compression );
            end
            
            %added conditional for synthesis option
            if field_exists_and_true(options.output,'blenderfile')
                %7/25/12 DPS blender files
                if options.verbose
                    disp( 'Saving nuclear channel object file' );
                end
                fprintf( fileID, '%s\n', 'Saving nuclear channel .obj file'  );
                
                %icaoberg 8/10/2012
                %                 im2blender(img,[ outdir filesep 'nucleus.obj'], ...
                %                     options.output.blender.downsample )
                % Rohan Arepally 6/7/13 added [] and shiftvector to parameters
                % also shiftvector is returned by the function im2blender.
                [shiftvector, ~] = im2blender(img,[ outdir filesep 'nucleus.obj'],options.output.blender.downsample, ...
                    [],shiftvector);
            end
            clear image;
        end
        
        %cell membrane
        if strcmpi( synthesis, 'cell' ) || strcmpi( synthesis, ...
                'framework' ) || strcmpi( synthesis, 'all' )
            load( [ options.temporary_results filesep 'image2.mat' ] );
            if field_exists_and_true(options.output,'tifimages')
                if options.verbose
                    disp( 'Saving cell channel tif image' );
                end
                
                fprintf( fileID, '%s\n', 'Saving cell channel tif image'  );
                
                img2tif( img, [ outdir filesep 'cell.tif'], compression );
            end
            
            %7/25/12 DPS Save output as Wavefront obj. file
            if field_exists_and_true(options.output,'blenderfile')
                if options.verbose
                    disp( 'Saving cell channel as Wavefront .obj file' );
                end
                fprintf( fileID, '%s\n', 'Saving cell channel .obj file'  );
                
                %icaoberg 8/10/2012
                %                 im2blender(img,[ outdir filesep 'cell.obj'],options.output.blender.downsample)
                % Rohan Arepally 6/7/13 added [] and shiftvector to parameters
                % also shiftvector is returned by the function im2blender.
                im2blender(img,[ outdir filesep 'cell.obj'], ...
                    options.output.blender.downsample , [], shiftvector);
            end
            clear image;
        end
        
        %icaoberg 10/9/2012
        %will only perform this tasks if synthesis is set to all
        if strcmpi( synthesis, 'all' )
            %create framework struct for SBML model using the first two
            %images (nuc, cell)
            if (field_exists_and_true(options.output,'SBML',false) || ...
                    field_exists_and_true(options.output,'SBMLSpatial') || ...
                    field_exists_and_true(options.output,'VCML'))
                %D. Sullivan 11/4/14 - adjust resolutions to be cubic since
                %simulating in non-cubic voxels doesn't make sense
                if (field_exists_and_true(options,'cubicOverride'))
                    warning('Exporting non-cubic SBML voxels!')
                else
                    for j = 1:length(imgs)
                        imgs{j} = AdjustResolutions(imgs{j},options.resolution.objects,options.resolution.cubic);
                    end
                end
                % Redundant
                % frameworkSBML = createSBMLFrameworkstruct(imgs(1:2),options);
            end
            
            frameworkSBML = createSBMLFrameworkstruct(imgs(1:2),options);
            
            %D. Sullivan 4/26/14
            %now set up the extracellular matrix.
            if ~isfield(options,'SBML_0Name')
                options.SBML_0Name = 'EC';
            end
            
            %%%I think we should do this for the framework not the primitives%%%
            if (field_exists_and_true(options.output,'SBML',false) || ...
                    field_exists_and_true(options.output,'SBMLSpatial') || ...
                    field_exists_and_true(options.output,'VCML'))
                primitives = getBox(imgs,options.SBML_0Name,options.resolution.cubic,[],options);
            end
            
            for j=1:1:length(models)
                if isfield(models{j}, 'proteinModel')
                    if ~strcmpi( models{j}.proteinModel.class, 'centrosome' )
                        load( [ options.temporary_results filesep 'image' num2str(j+2) '.mat' ] )
                        if field_exists_and_true(options.output,'tifimages')
                            if options.verbose
                                disp( ['Saving protein channel image ' models{j}.proteinModel.class ] );
                            end
                            fprintf( fileID, '%s\n', ['Saving protein channel image ' models{j}.proteinModel.class] );

                            %D. Sullivan 12/4/14 - added model index to create
                            %unique identifier
                            %                         img2tif( img, [ outdir filesep models{j}.proteinModel.class '.tif'], compression );
                            img2tif( img, [ outdir filesep models{j}.proteinModel.class num2str(j) '.tif'], compression );
                        end

                        %7/25/12 DPS blender files
                        if field_exists_and_true(options.output,'blenderfile')
                            warning('This output is deprecated. Use of options.output.SBML is recommended instead')
                            if options.verbose
                                disp( ['Saving protein channel object file ' models{j}.proteinModel.class ] );
                            end
                            % R. Arepally 6/7/13 added [] and shiftvector as
                            % parameters to im2blender.
                            %D. Sullivan 12/4/14 - added model index to create
                            %unique identifier
                            im2blender(img,[ outdir filesep models{j}.proteinModel.class  num2str(j) '.obj'],options.output.blender.downsample ...
                                ,[], shiftvector);
                            %                         im2blender(img,[ outdir filesep models{j}.proteinModel.class '.obj'],options.output.blender.downsample)
                        end

                        %7/25/12 DPS end addition
                        %D. Sullivan 7/23/13 added primitives type of output
                        if (field_exists_and_true(options.output,'SBML',false) || ...
                                field_exists_and_true(options.output,'SBMLSpatial') || ...
                                field_exists_and_true(options.output,'VCML'))
                            if isfield(options,'SBML_PName')
                                %D. Sullivan ***Temporary - this wont work for the HTM***
                                if options.output.SBML
                                    primitives = createSBMLstruct(models{j}.proteinModel,num2str(j),[options.SBML_PName{j},num2str(j)],primitives);
                                end

                                if options.output.SBMLSpatial || options.output.VCML
                                    primitives = createSBMLstruct3(models{j}.proteinModel,num2str(j),[options.SBML_PName{j},num2str(j)],primitives);
                                end
                            else
                                if options.output.SBML
                                    primitives = createSBMLstruct(models{j}.proteinModel,num2str(j),[],primitives);
                                end

                                if options.output.SBMLSpatial || options.output.VCML
                                    primitives = createSBMLstruct3(models{j}.proteinModel,num2str(j),[],primitives);
                                end
                            end

                            if isfield( options.output, 'SBML' ) && ...
                                    isfield(options.output.SBML,'primitives') ...
                                    && options.output.primitives == 1
                                primitives.primitiveOnly = 1;
                            end

                            %D. Sullivan - 4/8/14 check that whether the SBML
                            %flag is pointing to a file path.

                            save([options.temporary_results filesep 'preSBML.mat']);

                            if isfield( options.output, 'SBML' ) && ...
                                    ischar(options.output.SBML)
                                instance2SBML_mod(primitives,frameworkSBML,[outdir,'.xml'],...
                                    options.output.SBML,options.resolution.cubic)
                            elseif field_exists_and_true( options.output, 'SBML' ) && ...
                                    ~ischar(options.output.SBML)
                                instance2SBML_mod(primitives,frameworkSBML,[outdir,'.xml'], [], ...
                                    options.resolution.cubic)
                            end
                        end

                        %support for SBML Spatial Level 3 Version 1.0 Draft 0.90
                        if field_exists_and_true(options.output,'SBMLSpatial')
                            if check_if_SBML_output_is_valid( models )
                                instance2SBML3_mod(primitives,frameworkSBML, ...
                                    [outdir filesep 'cell.xml'], [], ...
                                    options.resolution.cubic, options);
                            else
                                warning('Cannot generate SBML Spatial file');
                            end
                        end
                        
                        % Support for Virtual Cell version 7.0.0_build_11
                        if field_exists_and_true(options.output,'VCML')
                            if check_if_SBML_output_is_valid( models )
                                instance2VCML(models, imgs, ...
                                    [outdir filesep 'cell.vcml'], [], ...
                                    options.resolution.cubic, options);
                            end
                        end
                    end
                end
            end
        end
        
        if field_exists_and_true(options.output,'OMETIFF')
            list_of_input_images = {};
            list_of_channel_labels = {};
            
            files = dir( [options.temporary_results filesep 'image*.mat' ] );
            for index=1:1:length(files)
                file = [ options.temporary_results filesep files(index).name ];
                temp = load( file );
                img2tif( temp.img, [ options.temporary_results filesep ...
                    'image' num2str(index) '.tif' ] );
                list_of_input_images{index} = [ options.temporary_results filesep ...
                    'image' num2str(index) '.tif' ] ;
                list_of_channel_labels{index} = ['channel' num2str(index)];
                clear temp
            end
            clear files file
            
            output_filename = [outdir filesep ...
                'cell' num2str(i) '.ome.tif'];
            parameters.PhysicalSizeX = options.resolution.objects(1);
            parameters.PhysicalSizeY = options.resolution.objects(2);
            parameters.PhysicalSizeZ = options.resolution.objects(3);
            parameters.list_of_channel_labels = list_of_channel_labels;
            
            answer = tif2ometiff( list_of_input_images, output_filename, parameters );
        end
    end
    
    %icaoberg 7/1/2013
    %if we got here at least one image was succesfully synthesized
    answer = true;
    
    if options.display
        disp(['Organizing temporary files from synthetic cell ' num2str(i)]);
    end
    organize_synthesis_temp_files(i, options);
end

if options.debug
    save( [ options.temporary_results filesep 'options.mat' ], 'options' );
end

if ~options.debug
    disp( 'Removing temporary folder' );
    if options.verbose
        disp( 'Removing temporary files' );
        delete( [ options.temporary_results filesep 'image*.mat'] );
    end
    rmdir( options.temporary_results, 's' );
end

disp( 'Closing log file' );
fclose( fileID );

%icaoberg 7/1/2013
disp( 'Finished synthesis' );
end

function answer = check_if_SBML_output_is_valid( models )

answer = true;
for k=1:1:length(models)
    if ~strcmpi(models{1}.proteinModel.class, 'vesicle' ) && ~strcmpi(models{1}.proteinModel.type, 'gmm' )
        answer = false;
    end
end
end%check_if_SBML_output_is_valid

function answer = field_exists_and_true( options, field, alltrue )
% FIELD_EXISTS_AND_TRUE Returns true if field exists and evaluates to true.
%
% List Of Input Arguments  Descriptions
% -----------------------  ------------
% options                  A structure
% field                    A string specifying the field to check
% alltrue                  (optional) Boolean flag that indicates whether a true result requires the field to be all true (alltrue == true, Matlab's default behavior) or any true (alltrue == false). Default is true.

if nargin < 3
    alltrue = true;
end

if alltrue
    answer = isfield(options,field) && options.(field);
else
    answer = isfield(options,field) && any(options.(field));
end

end
