function param = get_cellorganizer_default_parameters( option, param )
%GET_CELLORGANIZER_DEFAULT_PARAMETERS This helper function helps set up the
%default parameters for CellOrganizer

% Ivan E. Cao-Berg
%
% Copyright (C) 2015-2018 Murphy Lab
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

%these are the default baby parameters for cellorganizer
param = ml_initparam( param, struct( ...
    'debug', false, ...
    'display', false , ...
    'verbose', true ));

param = ml_initparam( param, struct( ...
    'slml', struct( 'level', '1' )));

param = ml_initparam( param, struct( ...
    'slml', struct( 'version', '1.1' )));

param = ml_initparam( param, struct( ...
    'randomwalk', false ));

if strcmpi( option, 'synthesis' )
    param = synthesis( param );
end

if isfield( param, 'model' ) && ...
        ( ~isfield( param.model, 'id' ) || ...
        ( isfield( param.model, 'id' ) && isempty( param.model.id ) ) )
    param.model.id = uuidgen();
end

if strcmpi( option, 'training' )
    param = training( param );
end

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
    
    if param.numberOfSynthesizedImages <= 0
        warning( ['Number of synthesized images is ' ...
            param.numberOfSynthesizedImages '. Setting default value to 1.'] );
        param.numberOfSynthesizedImages = 1;
    end
    
    if isempty(param.prefix)
        warning('Prefix cannot be empty. Setting default value to ''demo''');
        param.prefix = 'demo';
    end
    
    % output.tifimages           (optional) Boolean flag specifying whether to write out tif images. Default is true.
    % output.indexedimage        (optional) Boolean flag specifying whether to write out indexed image. Default is false.
    % output.blenderfile         (optional) Boolean flag specifying whether to write out (.obj) files for use in blender. Default is false;
    % output.SBML                (optional) boolean flag specifying whether to write out (.xml) files with SBML-Spatial 2 representations of geometries. Default is false;
    % output.SBMLSpatial         (optional) boolean flag specifying whether to write out (.xml) file with SBML-Spatial 3 representations of geometries. Default is false.
    % output.VCML                (optional) boolean flag specifying whether to write out VCML files for use with Virtual Cell. Default is false.
    % output.OMETIFF
    if ~isfield( param, 'output' )
        param.output.tifimages = true;
        param.output.indexedimage = false;
        param.output.blenderfiles = false;
        param.output.SBML = false;
        param.output.SBMLSpatial = false;
        param.output.VCML = false;
        param.output.OMETIFF = false;
    else
        param.output = ml_initparam( param.output, struct( ...
            'tifimages', true, ...
            'indexedimage', false, ...
            'blenderfiles', false, ...
            'SBML', false, ...
            'SBMLSpatial', false, ...
            'VCML', false ));
    end
    
    if isfield( param, 'model')
        %T-Cell model options
        if isfield( param.model, 'tcell' )
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
        
        %PCA model optionss
        if isfield( param.model, 'pca' )
            if isfield( param.model.pca, 'pca_synthesis_method' )
                param.pca_synthesis_method = param.model.pca.pca_synthesis_method;
            end
            
            param.model = rmfield( param.model, 'pca' );
        end
        
        %SPHARM model options
        if isfield(param.model, 'spharm_rpdm')
            if isfield(param.model.spharm_rpdm, 'synthesis_method')
                param.spharm_rpdm.synthesis_method = param.model.spharm_rpdm.synthesis_method;
            end
            if isfield(param.model.spharm_rpdm, 'imageSize')
                param.imageSize = param.model.spharm_rpdm.imageSize;
            end
            param.model = rmfield( param.model, 'spharm_rpdm' );
        end
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
            'time_to_pause', 0.001 ));

        param = ml_initparam(param, ...
            struct('saveIntermediateResults', true ) );

        param.model = ml_initparam(param.model, ...
            struct('filename', 'model.xml' ) );

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
    end
end%training
