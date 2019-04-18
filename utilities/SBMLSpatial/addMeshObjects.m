function [docNode,GeowrapperNode,geometryDefNode,wrapperNode] = ...
    addMeshObjects(meshData,docNode,geometryDefNode,GeowrapperNode,wrapperNode)

%%Define all the Mesh objects
s = 'spatial:';
% Parametric Geometry
ParaGeometryNode = docNode.createElement([s,'parametricGeometry']);
ParaGeometryNode.setAttribute([s,'id'],['id' sprintf('%03d',num2str(randi([0 10000000]),1))]);
ParaGeometryNode.setAttribute([s,'isActive'],'true');

% geometryDefNode.appendChild(ParaGeometryNode);

%List of Parametric Objects
ListOfParaObjectsNode = docNode.createElement([s,'listOfParametricObjects']);
%ListOfParaObjectsNode.setAttribute([s,'id'], meshData.name);
%ListOfParaObjectsNode.setAttribute([s,'polygonType'], 'triangle');
% ListOfParaObjectsNode.setAttribute('domain', DomainID);

zslices = zeros(size(meshData.list(1).img,3),1);
for i = 1:length(meshData.list)
    object = meshData.list(i);
    name = object.name;
    type = object.type;
    
    %assume the cell comes first
    zslicesold = zslices;
    zslices = squeeze(sum(sum(object.img,1),2));
    
    ParaObjectNode = docNode.createElement([s,'parametricObject']);
    ParaObjectNode.setAttribute([s,'id'],[name]);%['Sp_', name]);
    %for now we will assume we are only dealing with triangulated meshes
    ParaObjectNode.setAttribute([s,'polygonType'],'triangle');
    %D.Sullivan 4/15/14 - fixed naming bug.
    ParaObjectNode.setAttribute([s,'domainType'],name);
    ParaObjectNode.setAttribute([s,'compression'],'uncompressed');
    ParaObjectNode.setAttribute([s,'pointIndexLength'],'1');
    
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
    %D. Sullivan 11/30/14
    %This is being replaced in favor of the iso2mesh software
    %NOTE: This adds a dependency that we may not want - we should discuss
    %FV = getMeshPoints(object.img);
    try 
        FV = makeIso2mesh(object.img);
    catch
        warning(['The iso2mesh package was not found.',...
            'We recommend using this package for compact high-quality meshes.',...
            'Proceeding with standard CellOrganizer method for meshing']);
        FV = getMeshPoints(object.img);
    end
    if size(FV.faces,2)>3
        FV.faces = FV.faces(:,1:3);
    end
    
    %D. Sullivan 12/2/14 - this creates a slightly larger CP, or whatever
    %your external most layer is to ensure that the internal objects fall
    %within them
    param.adjustsize = 1;
    if object.ordinal==1 && param.adjustsize
        param = ml_initparam(param,struct('adjustscaleCP',1.05));
%         tmpverts = FV.vertices.*1.1;
        tmpverts = FV.vertices.*param.adjustscaleCP;
        object.img = imresize(object.img,param.adjustscaleCP);
        object.img = tp_stretch3d(object.img,floor(size(object.img,3)*param.adjustscaleCP));
        %need to shift the size adjusted vertices to the correct postions. 
        FV.vertices = tmpverts-repmat(max(tmpverts-FV.vertices)/2,size(tmpverts,1),1);
%         FV.vertices = FV.vertices+1;
    elseif object.ordinal==2 && param.adjustsize
        param = ml_initparam(param,struct('adjustscaleNU',0.95));
        tmpverts = FV.vertices.*param.adjustscaleNU;
        object.img = imresize(object.img,param.adjustscaleNU);
        object.img = tp_stretch3d(object.img,floor(size(object.img,3)*param.adjustscaleNU));
        %need to shift the size adjusted vertices to the correct postions. 
        FV.vertices = tmpverts-repmat(max(tmpverts-FV.vertices)/2,size(tmpverts,1),1);
    end
    
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
    
    %[docNode,wrapperNode] = addVol_SurfArea(docNode,wrapperNode,object.name,FV.volume,FV.SA);
    
    param.debug = 1;
    if param.debug
        save(['./FV',object.name,'_meshdata.mat'])
    end
    
    %SpatialPoints == FV.vertices
    
    % Rohan Arepally (added faces as an attribute of PolyObjectNode)
    faces = docNode.createTextNode( mat2str(FV.faces) );
    ParaObjectNode.appendChild(faces);
    ListOfParaObjectsNode.appendChild(ParaObjectNode);
end
%     wrapperNode.appendChild(ListOfCompartments);
ParaGeometryNode.appendChild(ListOfParaObjectsNode);
geometryDefNode.appendChild(ParaGeometryNode);
