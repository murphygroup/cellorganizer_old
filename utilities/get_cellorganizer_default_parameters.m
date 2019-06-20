function param = get_cellorganizer_default_parameters( option, param )
%GET_CELLORGANIZER_DEFAULT_PARAMETERS This helper function helps set up the
%default parameters for CellOrganizer

% Ivan E. Cao-Berg
%
% Copyright (C) 2015-2019 Murphy Lab
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

% icaoberg 2018/10/26 Added checks for param.train.flag = 'tcell'
% xruan 05/09/2019 Added synthesis resolution for spharm model

%these are the default baby parameters for cellorganizer
param = ml_initparam( param, struct( ...
    'debug', false, ...
    'display', false , ...
    'verbose', true ));

param = ml_initparam( param, struct( ...
    'slml', struct( 'level', '2' )));

param = ml_initparam( param, struct( ...
    'slml', struct( 'version', '8.0' )));

param = ml_initparam( param, struct( ...
    'randomwalk', false ));

if isfield( param, 'model' ) && ...
        ( ~isfield( param.model, 'id' ) || ...
        ( isfield( param.model, 'id' ) && isempty( param.model.id ) ) )
    param.model.id = uuidgen();
end

if strcmpi( option, 'training' )
    param = training( param );
end

if strcmpi( option, 'synthesis' )
    param = synthesis( param );
end
end%get_cellorganizer_default_parameters

function param = synthesis( param )
    param = ml_initparam( param, struct( ...
        'temporary_results', [ pwd filesep 'temp' ] ));

    %these are optional parameters that are generally hidden from users
    param = ml_initparam( param, struct( ...
        'overwrite_synthetic_instances', true, ...
        'numberOfSynthesizedImages', 1, ...
        'targetDirectory', pwd, ...
        'compression', 'none', ...
        'prefix', 'demo', ...
        'synthesis', 'all' ));

    param = ml_initparam( param, struct( ...
        'overlapsubsize', 0.3, ...
        'overlapthresh', 1, ...
        'rendAtStd', 2 ));

    param = ml_initparam( param, struct( ...
        'oobthresh', 0, ...
        'oobbuffer', 0 ));

    param = ml_initparam( param, struct( ...
        'framework_cropping', true ...
        )); % Debug

    if param.numberOfSynthesizedImages <= 0
        warning( ['Number of synthesized images is ' ...
            param.numberOfSynthesizedImages '. Setting default value to 1.'] );
        param.numberOfSynthesizedImages = 1;
    end

    if isempty(param.prefix)
        warning('Prefix cannot be empty. Setting default value to ''demo''');
        param.prefix = 'demo';
    end

    % reset SBML synthesis options into Output
    if isfield(param,'SBML')
        if isfield(param.SBML,'SBML')
            param.output.SBML = param.SBML.SBML;
        end

        if isfield(param.SBML,'downsampling')
            param.output.SBMLDownsampling = param.SBML.downsampling;
        end

        if isfield(param.SBML,'spatial_image')
            param.output.SBMLSpatialImage = param.SBML.spatial_image;
        end

        if isfield(param.SBML,'spatial_use_compression')
            param.output.SBMLSpatialUseCompression = param.SBML.spatial_use_compression;
        end

        if isfield(param.SBML,'spatial_use_analytic_meshes')
            param.output.SBMLSpatialUseAnalyticMeshes = param.SBML.spatial_use_analytic_meshes;
        end

        if isfield(param.SBML,'spatial_vcell_compatible')
            param.output.SBMLSpatialVCellCompatible = param.SBML.spatial_vcell_compatible;
        end

        if isfield(param.SBML,'flip_x_to_align')
            param.output.SBMLFlipXToAlign = param.SBML.flip_x_to_align;
        end
    end

    if isfield(param, 'VCML')
        if isfield(param.VCML,'downsampling')
            param.output.VCML.downsampling = param.VCML.downsampling;
        end
        if isfield(param.VCML, 'numSimulations')
            param.output.VCML.numSimulations = param.VCML.numSimulations;
        end

        if isfield(param.VCML, 'addTranslocationIntermediates')
            param.output.VCML.addTranslocationIntermediates = param.VCML.addTranslocationIntermediates;
        end

        if isfield(param.VCML, 'endTime')
            param.output.VCML.endTime = param.VCML.endTime;
        end

        if isfield(param.VCML, 'outputTimeStep')
            param.output.VCML.outputTimeStep = param.VCML.outputTimeStep;
        end

        if isfield(param.VCML, 'defaultTimeStep')
            param.output.VCML.defaultTimeStep = param.VCML.defaultTimeStep;
        end

        if isfield(param.VCML, 'minTimeStep')
            param.output.VCML.minTimeStep = param.VCML.minTimeStep;
        end

        if isfield(param.VCML, 'maxTimeStep')
            param.output.VCML.maxTimeStep = param.VCML.maxTimeStep;
        end
        if isfield(param.VCML, 'defaultDiffusionCoefficient')
            param.output.VCML.defaultDiffusionCoefficient = param.VCML.defaultDiffusionCoefficient;
        end
        if isfield(param.VCML, 'translations')
            param.output.VCML.translations = param.VCML.translations;
        end
        param = rmfield(param, 'VCML');
    end
    if isfield(param, 'output') && isfield(param.output, 'writeVCML')
        param.output.VCML.writeVCML = param.output.writeVCML;
    end
    if isfield(param, 'NET')
        if isfield(param.NET, 'translations')
            param.output.NET.translations = param.NET.translations;
        end
        if isfield(param.NET, 'units.length')
            param.output.NET.units.length = param.NET.units.length;
        end
        if isfield(param.NET, 'units.concentration')
            param.output.NET.units.concentration = param.NET.units.concentration;
        end
        if isfield(param.NET, 'units.time')
            param.output.NET.units.time = param.NET.units.time;
        end
        if isfield(param.NET, 'effectiveWidth')
            param.output.NET.effectiveWidth = param.NET.effectiveWidth;
        end
        if isfield(param.NET, 'useImageAdjacency')
            param.output.NET.useImageAdjacency = param.NET.useImageAdjacency;
        end

    end

    %%%% Default Output Options %%%%%
    % output.tifimages                          (optional) Boolean flag specifying whether to write out tif images. Default is true.
    % output.indexedimage                       (optional) Boolean flag specifying whether to write out indexed image. Default is false.
    % output.blenderfile                        (optional) Boolean flag specifying whether to write out (.obj) files for use in blender. Default is false.
    % output.meshes                             (optional) Boolean flag specifying whether to write out (.obj) files of analytic meshes (if available, does not work with every model type). Default is false.
    % output.blender.downsample                 (optional) downsampling fraction for the creation of object files (1 means no downsampling, 1/5 means 1/5 the size).
    % output.SBML                               (optional) boolean flag specifying whether to write out (.xml) files with SBML-Spatial 2 representations of geometries. Default is false.
    % output.SBMLDownsampling                   (optional) downsampling fraction for the creation of SBML Spatial files when output.SBML or output.SBMLSpatial are true (1 means no downsampling, 1/5 means 1/5 the size).
    % output.SBMLSpatial                        (optional) boolean flag specifying whether to write out (.xml) file with SBML-Spatial 3 representations of geometries. Default is false.
    % output.SBMLSpatialImage                   (optional) boolean flag specifying whether SBML-Spatial 3 output represents geometries with image volumes instead of meshes. Meshes are not supported by Virtual Cell. Default is false.
    % output.SBMLSpatialUseCompression          (optional) boolean flag specifying whether to write SBML Spatial output using compression. Default is true.
    % output.SBMLSpatialUseAnalyticMeshes       (optional) boolean flag specifying whether to use analytic meshes instead of isosurfaces of rasterized shapes. Default is false.
    % output.SBMLSpatialVCellCompatible         (optional) boolean flag specifying whether to write SBML Spatial output compatible with Virtual Cell but not the Level 3 Version 1 Release 0.90 draft specifications. Default is false.
    % output.SBMLSpatialImageDownsampling       (optional) downsampling fraction for the creation of SBML Spatial files when output.SBMLSpatialImage is true (1 means no downsampling, 1/5 means 1/5 the size).
    % output.VCML.writeVCML                     (optional) boolean flag specifying whether to write out VCML files for use with Virtual Cell. Default is false.
    % output.VCML.downsampling                  (optional) downsampling fraction for the creation of object files (1 means no downsampling, 1/5 means 1/5 the size). Default is 1.
    % output.VCML.addTranslocationIntermediates (optional) boolean flag specifying whether to create intermediate species and reactions for reactions involving non-adjacent translocations, which are valid in cBNGL but not Virtual Cell. Default is true.
    % output.VCML.numSimulations                (optional) number of simulations in VCML file.
    % output.VCML.translations                  (optional) N x 2 cell array of strings (first column) to be replaced by other strings (second column).
    % output.VCML.defaultDiffusionCoefficient   (optional) double specifying diffusion coefficient in meters squared per second. Default is 1.0958e-11.
    % output.VCML.NET.filename                  (optional) string specifying BioNetGen network file to include in VCML files for use with Virtual Cell. Default is empty string.
    % output.VCML.NET.units.concentration       (optional) string specifying concentration units in NET file. Default is 'uM'.
    % output.VCML.NET.units.length              (optional) string specifying length units in NET file. Default is 'um'.
    % output.VCML.NET.units.time                (optional) string specifying time units in NET file. Default is 's'.
    % output.VCML.NET.effectiveWidth            (optional) double specifying surface thickness in meters. Default is 3.8775e-9.
    % output.VCML.NET.useImageAdjacency         (optional) boolean specifying whether to derive compartment adjacency from the synthetic image. Can break Virtual Cell compatibility due to inclusion of BioNetGen representation of translocation between non-adjacent compartments. Default is true.
    % output.OMETIFF                            (optional) boolean flag specifying whether to write out an (.ome.tif) OME TIFF. Default is false.
    output_defaults = struct();
    output_defaults.tifimages = true;
    output_defaults.indexedimage = false;
    output_defaults.blenderfiles = false;
    output_defaults.SBML = false;
    output_defaults.SBMLDownsampling = 1;
    output_defaults.SBMLSpatial = false;
    output_defaults.SBMLSpatialImage = false;
    output_defaults.SBMLSpatialUseCompression = true;
    output_defaults.SBMLSpatialUseAnalyticMeshes = false;
    output_defaults.SBMLSpatialVCellCompatible = false;
    output_defaults.SBMLFlipXToAlign = true; % Debug
    output_defaults.VCML = struct();
    output_defaults.VCML.writeVCML = false;
    output_defaults.VCML.downsampling = 1;
    output_defaults.VCML.addTranslocationIntermediates = true;
    output_defaults.VCML.numSimulations = 1;
    output_defaults.VCML.translations = cell(0, 2);
    output_defaults.VCML.endTime = 20;
    output_defaults.VCML.defaultTimeStep = 0.05;
    output_defaults.VCML.minTimeStep = 0.0;
    output_defaults.VCML.maxTimeStep = 0.1;
    output_defaults.VCML.outputTimeStep = 0.5;
    % From Luby-Phelps 2000, "Cytoarchitecture and physical properties of cytoplasm: volume, viscosity, diffusion, intracellular surface area," Table I, column "Cytoplasmic D (�m2/sec)," excluding entries containing only upper bounds and taking the average of the bounds of entries containing ranges:
    output_defaults.VCML.defaultDiffusionCoefficient = unit_convert('um2.s-1', 'm2.s-1', (0.9 + 6.9 + 43 + 27 + 5.9 + 1.7 + 6.8 + (7+11)/2 + 13.5 + (6+11)/2 + 6.7 + 1.6) / 12);
    output_defaults.NET.filename = '';
    output_defaults.NET.units = struct();
    output_defaults.NET.units.concentration = 'uM';
    output_defaults.NET.units.length = 'um';
    output_defaults.NET.units.time = 's';
    % From Mitra et al. 2004, "Modulation of the bilayer thickness of exocytic pathway membranes by membrane proteins rather than cholesterol," using values from abstract
    output_defaults.NET.effectiveWidth = unit_convert('angstrom', 'm', (37.5+39.5+35.6+42.5) / 4);
    output_defaults.NET.useImageAdjacency = true;
    output_defaults.OMETIFF = false;

    if ~isfield( param, 'output' )
        param.output = output_defaults;
    else
        param.output = ml_initparam( param.output, output_defaults );
    end

    %T cell model options
    if isfield( param, 'model' ) && isfield( param.model, 'tcell' )
        if isfield( param.model.tcell, 'use_two_point_synapses' )
            param.use_two_point_synapses = param.model.tcell.use_two_point_synapses;
        end
        if isfield( param.model.tcell, 'timepoints_to_include' )
            param.timepoints_to_include = param.model.tcell.timepoints_to_include;
        end
        if isfield( param.model.tcell, 'conditions_to_include' )
            param.conditions_to_include = param.model.tcell.conditions_to_include;
        end
        if isfield( param.model.tcell, 'model_type_to_include' )
            param.model_type_to_include = param.model.tcell.model_type_to_include;
        end
        param.model = rmfield( param.model, 'tcell' );
    end

    %PCA model options
    if isfield( param, 'model' ) && isfield( param.model, 'pca' )
        if isfield( param.model.pca, 'pca_synthesis_method' )
            param.pca_synthesis_method = param.model.pca.pca_synthesis_method;
        end

        % param.model = rmfield( param.model, 'pca' );
    end

    %SPHARM model options
    if isfield( param, 'model' ) && isfield(param.model, 'spharm_rpdm')
        if isfield(param.model.spharm_rpdm, 'synthesis_method')
            param.spharm_rpdm.synthesis_method = param.model.spharm_rpdm.synthesis_method;
        end
        % xruan 05/09/2019
        if isfield(param.model.spharm_rpdm, 'synthesis_resolution')
            param.spharm_rpdm.synthesis_resolution = param.model.spharm_rpdm.synthesis_resolution;
        end
        if isfield(param.model.spharm_rpdm, 'imageSize')
            param.imageSize = param.model.spharm_rpdm.imageSize;
        end
        param.model = rmfield( param.model, 'spharm_rpdm' );
    end
end%synthesis

function param = training( param )
    param = ml_initparam( param, struct( ...
        'temporary_results', [ pwd filesep 'temp' ] ));

    %these are optional parameters that are generally hidden from users
    param = ml_initparam( param, struct( ...
        'targetDirectory', pwd, ...
        'save_helper_figures', false, ...
        'save_helper_movies', false, ...
        'interactive', false, ...
            'time_to_pause', 0.001, ...
            'skip_preprocessing', false));

    param = ml_initparam(param, ...
        struct('saveIntermediateResults', true ) );

    param.model = ml_initparam(param.model, ...
        struct('filename', 'model.xml' ) );

        param = ml_initparam(param, ...
            struct('cytonuclearflag', 'cyto' ) );

param = ml_initparam(param, ...
    struct('save_segmentations', false ) );

    %icaoberg 2018/10/26 setup default values for param.train.flag
    if ~isfield( param, 'train' ) || ~isfield( param.train, 'flag' )
        disp( ['Model training flag not set. Defaulting to ''tcell''.' ]);
        param.train.flag = 'nuclear';
    else
        if ~( strcmpi( param.train.flag, 'nuclear' ) || ...
                strcmpi( param.train.flag, 'framework' ) || ...
                strcmpi( param.train.flag, 'cell' ) || ...
                strcmpi( param.train.flag, 'protein' ) || ...
                strcmpi( param.train.flag, 'tcell' ) || ...
                strcmpi( param.train.flag, 'all' ) )
            disp( ['Unrecognized training: ' param.train.flag '. Defaulting to ''framework''.']);
            param.train.flag = 'all';
        end
    end

    if ismember( param.train.flag, {'protein', 'all'} )
        if ~(isfield( param, 'protein' ) && isfield( param.protein, 'id' ))
            param.protein.id = uuidgen();
        end

        if ~(isfield( param, 'protein' ) && isfield( param.protein, 'name' ))
            param.protein.name = 'unset';
        end
    end

    if ismember( param.train.flag, {'cell', 'framework', 'all'} )
        if ~(isfield( param, 'cell' ) && isfield( param.cell, 'id' ))
            param.cell.id = uuidgen();
        end

        if ~(isfield( param, 'cell' ) && isfield( param.cell, 'name' ))
            param.cell.name = 'unset';
        end
    end

    if ismember( param.train.flag, {'nucleus', 'framework', 'all'} )
        if ~(isfield( param, 'nucleus' ) && isfield( param.nucleus, 'id' ))
            param.nucleus.id = uuidgen();
        end

        if ~(isfield( param, 'nucleus' ) && isfield( param.nucleus, 'name' ))
            param.nucleus.name = 'unset';
        end
    end

    %T-Cell model options
    if isfield( param.model, 'tcell' )
        if isfield( param.model.tcell, 'synapse_location' )
            param.synapse_location = param.model.tcell.synapse_location;
        end
        if isfield( param.model.tcell, 'named_options_set' )
            param.named_options_set = param.model.tcell.named_options_set;
        end
        if isfield( param.model.tcell, 'use_two_point_synapses' )
            param.use_two_point_synapses = param.model.tcell.use_two_point_synapses;
        end
        if isfield( param.model.tcell, 'sensor' )
            param.sensor = param.model.tcell.sensor;
        end
        if isfield( param.model.tcell, 'timepoints_to_include' )
            param.timepoints_to_include = param.model.tcell.timepoints_to_include;
        end
        if isfield( param.model.tcell, 'model_type_to_include' )
            param.model_type_to_include = param.model.tcell.model_type_to_include;
        end
        if isfield( param.model.tcell, 'ometiff' )
            param.tcell.ometiff = param.model.tcell.ometiff;
        end
        if isfield( param.model.tcell, 'adjust_one_point_alignment' )
            param.adjust_one_point_alignment = param.model.tcell.adjust_one_point_alignment;
        end
        if isfield( param.model.tcell, 'infer_synapses' )
            param.infer_synapses = param.model.tcell.infer_synapses;
        end
        param.model = rmfield( param.model, 'tcell' );
    end

    if (isfield( param, 'protein' ) && ...
            isfield( param.protein, 'class' ) && ...
            strcmpi( param.protein.class, 'standardized_voxels' )) && ...
            (isfield( param, 'protein' ) && ...
            isfield( param.protein, 'type' ) && ...
            strcmpi( param.protein.type, 'standardized_map_half-ellipsoid' ))
        if isfield(param, 'tcell') && isfield(param.tcell, 'ometiff') && ...
                (param.tcell.ometiff == true)
            param.synapse_location = {'./temp_for_ometiff/annotations/*.csv'};
        end
    end

    %PCA model options
    if isfield( param.model, 'pca' )
        if isfield( param.model.pca, 'latent_dim' )
            param.latent_dim = param.model.pca.latent_dim;
        end

        if isfield( param.model.pca, 'imageSize' )
            param.imageSize = param.model.pca.imageSize;
        end
    end

    if ismember( param.train.flag, {'protein', 'all'} )
        if ~(isfield( param, 'protein' ) && isfield( param.protein, 'id' ))
            param.protein.id = uuidgen();
        end

        if ~(isfield( param, 'protein' ) && isfield( param.protein, 'name' ))
            param.protein.name = 'unset';
        end
    end

    if ismember( param.train.flag, {'cell', 'framework', 'all'} )
        if ~(isfield( param, 'cell' ) && isfield( param.cell, 'id' ))
            param.cell.id = uuidgen();
        end

        if ~(isfield( param, 'cell' ) && isfield( param.cell, 'name' ))
            param.cell.name = 'unset';
        end
    end

    if ismember( param.train.flag, {'nucleus', 'framework', 'all'} )
        if ~(isfield( param, 'nucleus' ) && isfield( param.nucleus, 'id' ))
            param.nucleus.id = uuidgen();
        end

        if ~(isfield( param, 'nucleus' ) && isfield( param.nucleus, 'name' ))
            param.nucleus.name = 'unset';
        end
    end

    %T-Cell model options
    if isfield( param.model, 'tcell' )
        if isfield( param.model.tcell, 'synapse_location' )
            param.synapse_location = param.model.tcell.synapse_location;
        end
        if isfield( param.model.tcell, 'named_options_set' )
            param.named_options_set = param.model.tcell.named_options_set;
        end
        if isfield( param.model.tcell, 'use_two_point_synapses' )
            param.use_two_point_synapses = param.model.tcell.use_two_point_synapses;
        end
        if isfield( param.model.tcell, 'sensor' )
            param.sensor = param.model.tcell.sensor;
        end
        if isfield( param.model.tcell, 'timepoints_to_include' )
            param.timepoints_to_include = param.model.tcell.timepoints_to_include;
        end
        if isfield( param.model.tcell, 'model_type_to_include' )
            param.model_type_to_include = param.model.tcell.model_type_to_include;
        end
        if isfield( param.model.tcell, 'ometiff' )
            param.tcell.ometiff = param.model.tcell.ometiff;
        end
        if isfield( param.model.tcell, 'adjust_one_point_alignment' )
            param.adjust_one_point_alignment = param.model.tcell.adjust_one_point_alignment;
        end
        if isfield( param.model.tcell, 'infer_synapses' )
            param.infer_synapses = param.model.tcell.infer_synapses;
        end
        param.model = rmfield( param.model, 'tcell' );
    end

    if (isfield( param, 'protein' ) && ...
            isfield( param.protein, 'class' ) && ...
            strcmpi( param.protein.class, 'standardized_voxels' )) && ...
            (isfield( param, 'protein' ) && ...
            isfield( param.protein, 'type' ) && ...
            strcmpi( param.protein.type, 'standardized_map_half-ellipsoid' ))
        if isfield(param, 'tcell') && isfield(param.tcell, 'ometiff') && ...
                (param.tcell.ometiff == true)
            param.synapse_location = {'./temp_for_ometiff/annotations/*.csv'};
        end
    end

    %PCA model options
    if isfield( param.model, 'pca' )
        if isfield( param.model.pca, 'latent_dim' )
            param.latent_dim = param.model.pca.latent_dim;
        end

        if isfield( param.model.pca, 'imageSize' )
            param.imageSize = param.model.pca.imageSize;
        end

        param.model = rmfield( param.model, 'pca' );
    end

    %SPHARM model options
    if isfield(param.model,'spharm_rpdm')
        if isfield(param.model.spharm_rpdm, 'alignment_method')
            param.spharm_rpdm.alignment_method = param.model.spharm_rpdm.alignment_method;
        end
        if isfield(param.model.spharm_rpdm, 'rotation_plane')
            param.spharm_rpdm.rotation_plane = param.model.spharm_rpdm.rotation_plane;
        end
        if isfield(param.model.spharm_rpdm, 'postprocess')
            param.spharm_rpdm.postprocess = param.model.spharm_rpdm.postprocess;
        end
        if isfield(param.model.spharm_rpdm, 'maxDeg')
            param.spharm_rpdm.maxDeg = param.model.spharm_rpdm.maxDeg;
        end
        if isfield(param.model.spharm_rpdm, 'components')
            param.spharm_rpdm.components = param.model.spharm_rpdm.components;
        end
        if isfield(param.model.spharm_rpdm, 'latent_dim')
            param.latent_dim = param.model.spharm_rpdm.latent_dim;
        end
        if isfield(param.model.spharm_rpdm, 'segminnucfraction')
            param.segminnucfraction = param.model.spharm_rpdm.segminnucfraction;
        end
    end
if ~isfield( param, 'labels' )
       param.labels = {};
end
end%training
