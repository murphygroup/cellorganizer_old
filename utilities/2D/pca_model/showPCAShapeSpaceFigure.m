function [param] = showPCAShapeSpaceFigure(model, labels, param)
% SHOWPCASHAPESPACEFIGURE 

% Xiongtao Ruan
%
% Copyright (C) 2015-2016 Murphy Lab
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

% 03/23/2018 copied from showPCAShapeSpaceFigure.m



if ~exist('param', 'var')
    param = [];
end

nimgs = model.cellShapeModel.numimgs;

if size(model.cellShapeModel.train_score,2) >= 3
    [~, synthorder] = sort(model.cellShapeModel.train_score(:,3), 'Ascend');
else
    synthorder = 1:nimgs;
end

param = ml_initparam(param, struct( ...
    'skipmissing', true, ...
    'rebuild_pos', false, ...
    'plot_dims', [1,2], ...
    'cm', @jet, ...
    'traces', [], ...
    'embedfctn', @cmdscale, ...
    'subsize', 400, ...
    'synthorder', synthorder, ...
    'rotate', 0 ...
    ));
cellnums = 1:nimgs;

if ~exist('labels', 'var') || isempty(labels)
    labels = 1:nimgs;
end

skipmissing = param.skipmissing;
cm = param.cm;
plot_dims = param.plot_dims;
rebuild_pos = param.rebuild_pos;

ndims = 2;

keepinds = ~any(isnan(model.cellShapeModel.train_score),2);
%     labels = labels(keepinds);
cellnums = cellnums(keepinds);
%     embed_pos = model.cellShapeModel.positions(keepinds,:);

[ulabels, ~, labelinds ] = unique(labels);

labels = labelinds;

if strcmpi(class(cm), 'function_handle')
    colors = cm(length(ulabels))*0.8;
else
    colors = cm;
end

param.colors = colors;


set(gcf, 'color', 'w')
hold on

% set up images from contour
if any(strcmp(model.cellShapeModel.components, 'cell'))
    cell_params = model.cellShapeModel.cell_params;
else 
    cell_params = cell(nimgs, 1);
end
if any(strcmp(model.cellShapeModel.components, 'nuc'))
    nuc_params = model.cellShapeModel.nuc_params;
else
    nuc_params = cell(nimgs, 1);
end

imfunc = @(x) convert_contour_to_image(cell_params{x}, nuc_params{x});
param = ml_initparam(param, struct( ...
    'imfunc', @(x) imrotate(img2flat(imfunc(x), colors(labels(x),:)), param.rotate) ...
    ));

if (param.traces)
    for cellind = 1:length(cellnums)-1
        if labels(cellind)==labels(cellind+1)
            xpos(1) = model.cellShapeModel.positions(cellind,param.plot_dims(1));
            ypos(1) = model.cellShapeModel.positions(cellind,param.plot_dims(2));
            xpos(2) = model.cellShapeModel.positions(cellind+1,param.plot_dims(1));
            ypos(2) = model.cellShapeModel.positions(cellind+1,param.plot_dims(2));
            plot(xpos,ypos,'k-');
        end
    end
end

normalize_coords = model.cellShapeModel.train_score;

% @icaoberg solved the issue with repmat
normalize_coords = normalize_coords ./ ...
    repmat(max(abs(normalize_coords)), size(normalize_coords,1),1) * 10;

param.synthorder = param.synthorder(ismember(param.synthorder, cellnums));
for imnum = 1:length(param.synthorder)
    
    cellind = param.synthorder(imnum);
    try
        cellimg = param.imfunc(cellind);
        
        if isempty(cellimg) %|| any(cellimg(:) .* cellbounds(:))
            continue;
        end
        
        %center the image on the point where it belongs
        place_image(cellimg, normalize_coords(cellind,param.plot_dims), param);
        hold on
    catch err
        disp(['Unable to plot image: ' num2str(imnum)] );
        getReport( err )
    end
end

axis equal
axis tight

param.axis = axis;
hold off
disp(['Number of objects: ' num2str(length(param.synthorder))]);
%
% embed_final = nan(nimgs, size(embed_pos,2));
% embed_final(cellnums,:) = embed_pos;
%
% locs_final = nan(nimgs, 2);
% locs_final(cellnums,:) = locs;
%
% param.cellnums = cellnums;

end

