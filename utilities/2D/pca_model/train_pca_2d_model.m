function [pca_model] = train_pca_2d_model(cell_params_fname, options)
% take in binary mask cell shape, use some smoothing methods
% (interpolation, spline smoothing, kernel smoothing) to smooth the cell
% boundary, and then resample the cell boundary points, evening. After
% that do translation to centering the cell shapes. 

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

% 03/23/2018 xruan minor fix of saving model content

options = ml_initparam(options, struct('latent_dim', 10));
latent_dim = options.latent_dim;

components = options.components;
if numel(components) == 1
    pca_model_type = 'separate';
elseif any(strcmp(components, 'nuc')) && any(strcmp(components, 'cell')) 
    pca_model_type = 'joint';
end

nuc_params = [];
if any(strcmp(components, 'nuc'))
    param_tmp = loadFiles(cell_params_fname, 'nuc');
    param_tmp = param_tmp(~cellfun(@isempty, param_tmp));
    nuc_params = cellfun(@(x) x.nuc, param_tmp, 'UniformOutput', false);
    nuc_landmarks = cat(3, nuc_params{:});
end
cell_params = [];
if any(strcmp(components, 'cell'))
    param_tmp = loadFiles(cell_params_fname, 'cell');
    param_tmp = param_tmp(~cellfun(@isempty, param_tmp));
    cell_params = cellfun(@(x) x.cell, param_tmp, 'UniformOutput', false);
    cell_landmarks = cat(3, cell_params{:});
end

if strcmp(pca_model_type, 'separate')
    if exist(cell_landmarks, 'var')
        all_landmarks = cell_landmarks;
    else
        all_landmarks = nuc_landmarks;
    end
elseif strcmp(pca_model_type, 'joint')
    all_landmarks = cat(1, cell_landmarks, nuc_landmarks); 
end

X = reshape(all_landmarks, [], size(all_landmarks, 3))';

% X = X - mean(X);

[coeff,score,latent,tsquared,explained, mu] = pca(X);

train_score = score(:, 1 : latent_dim);
train_explained = sum(explained(1 : latent_dim));
train_coeff = coeff(:, 1 : latent_dim);


pca_model = struct();
pca_model.X = X;
pca_model.coeff = coeff;
pca_model.score = score;
pca_model.latent = latent;
pca_model.tsquared = tsquared;
pca_model.explained = explained;
pca_model.mu = mu;
pca_model.latent_dim = latent_dim;
pca_model.train_score = train_score;
pca_model.train_explained = train_explained;
pca_model.train_coeff = train_coeff;
pca_model.all_landmarks = all_landmarks;


% other settings
pca_model.options = options;
pca_model.numimgs = numel(cell_params);
pca_model.components = components;
pca_model.cell_params = cell_params;
pca_model.nuc_params = nuc_params;
pca_model.name = 'pca model of the cell';
pca_model.type = 'pca';
pca_model.version = 1.0;

end


