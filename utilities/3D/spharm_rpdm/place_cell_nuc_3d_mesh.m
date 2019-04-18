function [ h ] = place_cell_nuc_3d_mesh( fvec, location, param )
%places an image centered at the middle most pixel at the coordinate
%specified by the 1d vector location
%
%by default, all zero pixels are set to tranparent
%
%returns the handle for the placed image

% xruan 04/29/2018 

if ~exist('param', 'var')
    param = [];
end

param = ml_initparam(param, struct( ...
        'subsize', 400, ...
        'alpha', [0,0,0], ...
        'colormap_func', @jet ...
        ));

cell_vertices = [];
nuc_vertices = [];
if isfield(fvec, 'cell_vertices') 
    cell_vertices = fvec.cell_vertices;
    cell_faces = fvec.cell_faces;
end

if isfield(fvec, 'nuc_vertices')
    nuc_vertices = fvec.nuc_vertices;
    nuc_faces = fvec.nuc_faces;
end

% get the center of mesh
if isempty(cell_vertices)
    mesh_center = mean(nuc_vertices);
else
    mesh_center = mean(cell_vertices);
end

if ~isempty(cell_vertices)
    cell_vertices = cell_vertices - mesh_center;
    cell_vertices = cell_vertices + location;
end

if ~isempty(nuc_vertices)
    nuc_vertices = nuc_vertices - mesh_center;
    nuc_vertices = nuc_vertices + location;
end

if ~isempty(cell_vertices) && ~isempty(nuc_vertices)
% h = patch('vertices', vertices, 'faces', faces, 'FaceVertexCData',jet(size(vertices,1)),'FaceColor','interp', 'EdgeColor', 'None');
    h = patch('vertices', cell_vertices, 'faces', cell_faces, 'FaceVertexCData',param.colormap_func(size(cell_vertices,1)),'FaceColor','interp', 'EdgeColor', 'None', 'FaceAlpha', 'flat');
    alpha(0.5);
    hold on
    h = patch('vertices', nuc_vertices, 'faces', nuc_faces, 'FaceVertexCData',winter(size(nuc_vertices,1)),'FaceColor','interp', 'EdgeColor', 'None');
elseif ~isempty(cell_vertices)
    h = patch('vertices', cell_vertices, 'faces', cell_faces, 'FaceVertexCData',param.colormap_func(size(cell_vertices,1)),'FaceColor','interp', 'EdgeColor', 'None');
elseif ~isempty(nuc_vertices)
    h = patch('vertices', nuc_vertices, 'faces', nuc_faces, 'FaceVertexCData',param.colormap_func(size(nuc_vertices,1)),'FaceColor','interp', 'EdgeColor', 'None');
end

view([45, 45]);
    
% alphamap = zeros(size(image));
% for i = 1:length(param.alpha)
%     alphamap(:,:,i) = param.alpha(i);
% end

% set(h, 'AlphaDataMapping', 'none')
% set(h, 'AlphaData', ~all(image == alphamap,3))


end

