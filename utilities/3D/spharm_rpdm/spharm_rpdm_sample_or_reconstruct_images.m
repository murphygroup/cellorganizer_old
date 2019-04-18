function [nucimg, cellimg] = spharm_rpdm_sample_or_reconstruct_images( model, options )
% This is the unified function for reconstruction of trainging images and 
% random sampling of images in the shape space
% For the random sampling, the idea: first randomly pick two point in the 
% shape space, and then randomly sample a point uniformly lay in the line 
% segment. At last reconstruct the landmarmks of this point. 
% 
% copied from pca_random_sample_images.m

% Author: Xiongtao Ruan (xruan@andrew.cmu.edu)
%
% Copyright (C) 2013-2017 Murphy Lab
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
% For additional information visit http://murphylab.web.cmu.edu or
% send email to murphy@cmu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



rpdm_model = model.cellShapeModel;
train_score = rpdm_model.train_score;
train_coeff = rpdm_model.train_coeff;
mu = rpdm_model.mu;

% unified framework
switch options.spharm_rpdm.synthesis_method
    case 'random_sampling'
        % random sampling
        rand_inds = randperm(size(train_score, 1), 2);
        train_point_1 = train_score(rand_inds(1), :);
        train_point_2 = train_score(rand_inds(2), :);
        lambda = rand();
        rand_point = train_point_1 * lambda + train_point_2 * (1 - lambda);
        reconst_spharm_descriptors = rand_point * train_coeff' + mu;
        
        cur_center = rpdm_model.all_centers(:, :, rand_inds(1)) * lambda + rpdm_model.all_centers(:, :, rand_inds(2)) * (1 - lambda);
        cur_scale = rpdm_model.scales(rand_inds(1)) * lambda + rpdm_model.scales(rand_inds(2)) * (1 - lambda);
        
    case 'reconstruction'
        % reconstruction of training images. 
        if ~isfield(options, 'ind')
            cur_ind = 1;
        else
            cur_ind = options.ind;
        end
        train_score = rpdm_model.train_score;
        cur_train_score = train_score(cur_ind, :);
        cur_center = rpdm_model.all_centers(:, :, cur_ind);
        cur_scale = rpdm_model.scales(cur_ind, :);
        reconst_spharm_descriptors = cur_train_score * train_coeff' + mu;
end


cell_spharm_descriptor = [];
nuc_spharm_descriptor = [];
if any(strcmp(rpdm_model.components, 'nuc')) && any(strcmp(rpdm_model.components, 'cell')) 
    reconst_spharm_descriptors = reshape(reconst_spharm_descriptors', [], 3, 2);     
    cell_reconst_descriptors = reconst_spharm_descriptors(:, :, 1);
    nuc_reconst_descriptors = reconst_spharm_descriptors(:, :, 2);
    cell_center = cur_center(1, :);
    nuc_center = cur_center(2, :);
    switch rpdm_model.shape_model_type
        case 1 
            cell_spharm_descriptor = convert_3d_preshape_to_spharm(cell_reconst_descriptors, cur_scale, cell_center);
            nuc_spharm_descriptor = convert_3d_preshape_to_spharm(nuc_reconst_descriptors, cur_scale, nuc_center);
        case 2
            cell_spharm_descriptor = convert_3d_preshape_to_spharm(cell_reconst_descriptors, cur_scale, cell_center);
            cell_spharm_descriptor(1, :) = [];
            cell_spharm_descriptor(1, :) = cell_spharm_descriptor(1, :) + cell_center;
            nuc_spharm_descriptor = convert_3d_preshape_to_spharm(nuc_reconst_descriptors, cur_scale, nuc_center);
            nuc_spharm_descriptor(1, :) = [];
            nuc_spharm_descriptor(1, :) = nuc_spharm_descriptor(1, :) + nuc_center;            
    end
elseif any(strcmp(rpdm_model.components, 'nuc'))
    nuc_reconst_descriptors = reconst_spharm_descriptors;
    nuc_spharm_descriptor = convert_3d_preshape_to_spharm(nuc_reconst_descriptors, cur_scale, cur_center);
elseif any(strcmp(rpdm_model.components, 'cell'))
    cell_reconst_descriptors = reconst_spharm_descriptors;
    cell_spharm_descriptor = convert_3d_preshape_to_spharm(cell_reconst_descriptors, cur_scale, cur_center);    
end

max_deg = rpdm_model.max_deg;
[vs, fs]=SpiralSampleSphere(4002);
% [vs fs] = sphereMesh([0 0 0 1]);
Zs = calculate_SPHARM_basis(vs, max_deg);

imageSize = options.imageSize;
cellimg = [];
nucimg = [];

if ~isempty(cell_spharm_descriptor)
    fvec_cell = cell_spharm_descriptor;
    Zvert_cell = real(Zs * fvec_cell);
    cell_mesh.vertices = Zvert_cell;
    cell_mesh.faces = fs;
    cellimg = surface_mesh_to_volume_image_conversion(cell_mesh, imageSize);
    cellimg = cellimg > 0.5;
end

if ~isempty(nuc_spharm_descriptor)
    fvec_nuc = nuc_spharm_descriptor;
    Zvert_nuc = real(Zs * fvec_nuc);
    nuc_mesh.vertices = Zvert_nuc;
    nuc_mesh.faces = fs;
    nucimg = surface_mesh_to_volume_image_conversion(nuc_mesh, imageSize);
    nucimg = nucimg > 0.5;
end


end



