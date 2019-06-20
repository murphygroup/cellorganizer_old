function [docNode,GeowrapperNode,geometryDefNode,wrapperNode] = ...
    addMeshObjects3(meshData,docNode,geometryDefNode,GeowrapperNode,wrapperNode, options)
% ADDMESHOBJECTS3 Helper function that creates a ParametricGeometry
% instance

% Copyright (C) 2016 Murphy Lab
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

% November 29, 2016 @icaoberg Updated method to save number of items in 
%        spatialPoints and parametricGeometry instances


s = 'spatial:';

% Get listOfDomainTypes and listOfDomains:
ListOfDomainTypesNode = GeowrapperNode.getElementsByTagName([s,'listOfDomainTypes']).item(0);
ListOfDomainsNode = GeowrapperNode.getElementsByTagName([s,'listOfDomains']).item(0);

%%Define all the Mesh objects
% Parametric Geometry
ParaGeometryNode = docNode.createElement([s,'parametricGeometry']);
ParaGeometryNode.setAttribute([s,'id'],['id' sprintf('%03d',num2str(randi([0 10000000]),1))]);
% Does not pass SBML validator
if options.output.SBMLSpatialVCellCompatible
    ParaGeometryNode.setAttribute('id',ParaGeometryNode.getAttribute([s,'id']))
end;
ParaGeometryNode.setAttribute([s,'isActive'],'true');

% geometryDefNode.appendChild(ParaGeometryNode);

%List of Parametric Objects
ListOfParaObjectsNode = docNode.createElement([s,'listOfParametricObjects']);
%ListOfParaObjectsNode.setAttribute([s,'id'], meshData.name);
%ListOfParaObjectsNode.setAttribute('id',ListOfParaObjectsNode.getAttribute([s,'id']));
%ListOfParaObjectsNode.setAttribute([s,'polygonType'], 'triangle');
%ListOfParaObjectsNode.setAttribute('domain', DomainID);

zslices = zeros(size(meshData.list(1).img,3),1);
all_vertices = zeros(0, 3);

for i = 1:length(meshData.list)
    object = meshData.list(i);
    name = object.name;
    type = object.type;
    object_mesh = object.mesh;
    object_resolution = object.resolution;
    
    % Add to listOfDomainTypes:
    ListOfDomainTypesNode = GeowrapperNode.getElementsByTagName([s,'listOfDomainTypes']).item(0);
    DomainTypeNode = docNode.createElement([s,'domainType']);
    DomainTypeNode.setAttribute([s,'id'],name);
    % Does not pass SBML validator
    if options.output.SBMLSpatialVCellCompatible
        DomainTypeNode.setAttribute('id',DomainTypeNode.getAttribute([s,'id']))
    end;
    DomainTypeNode.setAttribute([s,'spatialDimensions'],'3');
    ListOfDomainTypesNode.appendChild(DomainTypeNode);

    % Add to listOfDomains:
    DomainNode = docNode.createElement([s,'domain']);
    DomainNode.setAttribute([s,'id'],[name,num2str(1)]);%[name,num2str(i-1)]%[DomainID,num2str(j-1)])%'0']);
    % Does not pass SBML validator
    if options.output.SBMLSpatialVCellCompatible
        DomainNode.setAttribute('id',DomainNode.getAttribute([s,'id']))
    end;
    DomainNode.setAttribute([s,'domainType'],name);
    ListOfInteriorPoints = docNode.createElement([s,'listOfInteriorPoints']);
    InteriorPoint = docNode.createElement([s,'interiorPoint']);
    ListOfDomainsNode.appendChild(DomainNode);
    
    %assume the cell comes first
    zslicesold = zslices;
    zslices = squeeze(sum(sum(object.img,1),2));
    
    ParaObjectNode = docNode.createElement([s,'parametricObject']);
    ParaObjectNode.setAttribute([s,'id'],[name,num2str(1),'_mesh']);%[name]);%['Sp_', name]);
    % Does not pass SBML validator
    if options.output.SBMLSpatialVCellCompatible
        ParaObjectNode.setAttribute('id',ParaObjectNode.getAttribute([s,'id']))
    end;
    %for now we will assume we are only dealing with triangulated meshes
    ParaObjectNode.setAttribute([s,'polygonType'],'triangle');
    %D.Sullivan 4/15/14 - fixed naming bug.
    ParaObjectNode.setAttribute([s,'domainType'],[name]);
    ParaObjectNode.setAttribute([s,'compression'],'uncompressed');
    
    %Get mesh points
    %remove the top and bottom slice of the nucleus fluorescence to ensure
    %that the nucleus lies within the cell.
    if strcmpi(object.name,'NU')
        slices = find(max(max(object.img))>0);
        botslice = min(slices);
        topslice = max(slices);
        %D. Sullivan 12/2/14 - this actually doesn't do anything. need to
        %remove the top and bottom slices of nuc. 
%         object.img(:,:,1) = object.img(:,:,botslice).*0;
        object.img(:,:,botslice) = object.img(:,:,botslice).*0;
%         object.img(:,:,end) = object.img(:,:,topslice).*0;
        object.img(:,:,topslice) = object.img(:,:,topslice).*0;
        
    end
    
    image_to_contour = object.img;
    if options.output.SBMLFlipXToAlign
        % Flip in X to align with image output
        image_to_contour = flipdim(image_to_contour, 2);
    end
    
    use_object_mesh = isstruct(object_mesh) && options.output.SBMLSpatialUseAnalyticMeshes;
    if use_object_mesh
        FV = object_mesh;
        if options.output.SBMLFlipXToAlign
            % Flip in X to align with image output
            % FV.vertices(:, 1) = size(object.img, 2) + 1 - FV.vertices(:, 1);
            max_size_voxels = size(options.cell);
            max_size_voxels_xyz = max_size_voxels([2, 1, 3]);
            max_size = max_size_voxels_xyz .* options.resolution.cubic;
            FV.vertices(:, 1) = max_size_voxels_xyz(1) - (FV.vertices(:, 1) - 1);
            FV.faces(:, 2:3) = FV.faces(:, [3, 2]);
        end
    else
        %D. Sullivan 11/30/14
        %This is being replaced in favor of the iso2mesh software
        %NOTE: This adds a dependency that we may not want - we should discuss
        %FV = getMeshPoints(image_to_contour);
        try 
            % warning('makeIso2mesh temporarily disabled because it is not working by default'); error();
            FV = makeIso2mesh(image_to_contour);
        catch
            warning(['The iso2mesh package was not found.',...
                'We recommend using this package for compact high-quality meshes.',...
                'Proceeding with standard CellOrganizer method for meshing']);
            FV = getMeshPoints(image_to_contour, [], options.output.SBMLDownsampling, options);
        end
        if size(FV.faces,2)>3
            FV.faces = FV.faces(:,1:3);
        end
    end
    
    ParaObjectNode.setAttribute([s,'pointIndexLength'], ...
        num2str(prod(size(FV.faces))));
    
    %D. Sullivan 10/23/14
    %The mesh should be centered to fall in the range of the image.
    %Fore some reason 3.5 is being added to the z dimension.
    %This will cause the mesh to end in the wrong place.
    FV.vertices = FV.vertices.*repmat(meshData.resolution,size(FV.vertices,1),1);
    
    %D. Sullivan 11/10/14 - Adjust the volume and surface area for the
    %compartment
    FV.volume = sum(object.img(:)).*prod(meshData.resolution);
    %         FV.SA = sum(bwperim(object.img(:))).*prod(meshData.resolution);
    FV.SA = meshSurfaceArea(FV.vertices,FV.faces);
    
    [docNode,wrapperNode] = addVol_SurfArea3(docNode,wrapperNode,object.name,FV.volume,FV.SA);
    
    if options.debug
        save([options.temporary_results filesep ...
            'FV' object.name '_meshdata.mat'])
    end
    
    %Parametric Objects == FV.faces
    %faces = docNode.createTextNode( mat2SBMLArrayData(FV.faces) );
    % All meshes share one SpatialPoints, so offset by the number of vertices in previous meshes
    faces = docNode.createTextNode( [sprintf('\n'), ...
        mat2SBMLArrayData(FV.faces-1+size(all_vertices, 1), false), sprintf('\n')] );
    
    %SpatialPoints
    all_vertices = [all_vertices; FV.vertices];
   
    ParaObjectNode.appendChild(faces);
    ListOfParaObjectsNode.appendChild(ParaObjectNode);
end

%SpatialPoints
SpatialPointsNode = docNode.createElement([s,'spatialPoints']);
SpatialPointsNode.setAttribute([s,'compression'], 'uncompressed' );
SpatialPointsNode.setAttribute([s,'arrayDataLength'], ...
    num2str(prod(size(all_vertices))) );
vertices = docNode.createTextNode( [sprintf('\n'), ...
    mat2SBMLArrayData(all_vertices, false), sprintf('\n')] );
SpatialPointsNode.appendChild(vertices);
ParaGeometryNode.appendChild(SpatialPointsNode);

%wrapperNode.appendChild(ListOfCompartments);
ParaGeometryNode.appendChild(ListOfParaObjectsNode);
geometryDefNode.appendChild(ParaGeometryNode);

