function [docNode,GeowrapperNode,geometryDefNode,wrapperNode] = ...
    addCSGObjects3(CSGdata,docNode,geometryDefNode,GeowrapperNode,wrapperNode)
% ADDCSGOBJECTS3 Helper function that creates a CSGeometry
% instance

s = 'spatial:';

%%%Set up the ListOfDomainTypes node
ListOfDomainTypesNode = docNode.createElement([s,'listOfDomainTypes']);

%get list of domain types from CSG data list
domainlist = fieldnames(CSGdata);

%goes through every domain and creates the domain type nodes, e.g. vesicle
for j = 1:length(domainlist)
    DomainTypeNode = docNode.createElement([s,'domainType']);
    DomainTypeNode.setAttribute([s,'id'],domainlist{j});
    DomainTypeNode.setAttribute([s,'spatialDimensions'],'3');
    ListOfDomainTypesNode.appendChild(DomainTypeNode);
    
    GeowrapperNode.appendChild(ListOfDomainTypesNode);
    
    %%%Set up ListOfDomains
    ListOfDomains = docNode.createElement([s,'listOfDomains']);
    for i=1:length(CSGdata.(domainlist{j}).list)
        object = CSGdata.(domainlist{j}).list(i);
        name = object.name;
        type = object.type;
        DomainNode = docNode.createElement([s,'domain']);
        DomainNode.setAttribute([s,'id'],[name,num2str(i-1)]);%[DomainID,num2str(j-1)])%'0']);
        DomainNode.setAttribute([s,'domainType'],name);
        ListOfInteriorPoints = docNode.createElement([s,'listOfInteriorPoints']);
        InteriorPoint = docNode.createElement([s,'interiorPoint']);
        
        if isfield(object,'position')
            position = object.position;
        else
            position = [0,0,0];
        end
        
        InteriorPoint.setAttribute([s,'coord1'],num2str(position(1)));%'0');
        InteriorPoint.setAttribute([s,'coord2'],num2str(position(2)));%'0');
        InteriorPoint.setAttribute([s,'coord3'],num2str(position(3)));%'0');
        ListOfInteriorPoints.appendChild(InteriorPoint);
        DomainNode.appendChild(ListOfInteriorPoints);
        ListOfDomains.appendChild(DomainNode);
    end
end
GeowrapperNode.appendChild(ListOfDomains);

%%%Define all the CSG (Primitive) type geometries
CSGeometryNode = docNode.createElement([s,'csGeometry']);
CSGeometryNode.setAttribute([s,'id'], ...
    ['csgid' sprintf('%03d',num2str(randi([0 10000000]),1))]);
CSGeometryNode.setAttribute([s,'isActive'], 'true');
% geometryDefNode.appendChild(CSGeometryNode);

ListOfCSGObjectsNode = docNode.createElement([s,'listOfCSGObjects']);

%add each CSGObject
number_of_vesicles = 0;
for k = 1:length(domainlist)
    if strcmpi(domainlist{k},'vesicle')
        %only available for vesicles
        for j=1:length(CSGdata.(domainlist{k}).list)
            %CSGObjectNode = add_one_object_at_a_time(CSGdata,docNode, k, j);
            ListOfCSGNodes = docNode.createElement([s,'listOfCSGNodes']);
            number_of_vesicles = number_of_vesicles + 1;
            object = CSGdata.(domainlist{k}).list(j);
            name = object.name;
            type = object.type;
            object.ordinal = CSGdata.(domainlist{k}).ordinal;
            
            %csgTranslation
            if isfield(object, 'position')
                position = object.position;
                CSGTranslationNode = docNode.createElement([s,'csgTranslation']);
                CSGTranslationNode.setAttribute([s,'id'],'translation');
                CSGTranslationNode.setAttribute([s,'translateX'], num2str(position(1)));
                CSGTranslationNode.setAttribute([s,'translateY'], num2str(position(2)));
                CSGTranslationNode.setAttribute([s,'translateZ'], num2str(position(3)));
            else
                error('No position specified. Unable to create SBML Spatial file.');
            end
            
            %csgRotation
            if isfield(object, 'rotation')
                rotation = object.rotation;
                CSGRotationNode = docNode.createElement([s,'csgRotation']);
                CSGRotationNode.setAttribute([s,'id'], 'rotation');
                CSGRotationNode.setAttribute([s,'rotateX'], num2str(deg2rad(rotation(1))));
                CSGRotationNode.setAttribute([s,'rotateY'], num2str(deg2rad(rotation(2))));
                CSGRotationNode.setAttribute([s,'rotateZ'], num2str(deg2rad(rotation(3))));
                CSGRotationNode.setAttribute([s,'rotateAngleInRadians'], '0');
            else
                error('No rotation specified. Unable to create SBML Spatial file.');
            end
            
            %csgScale
            if isfield(object, 'scale')
                objsize = object.scale;%.*resolution;
                CSGScaleNode = docNode.createElement([s,'csgScale']);
                CSGScaleNode.setAttribute([s,'id'], 'scale');
                CSGScaleNode.setAttribute([s,'scaleX'], num2str(objsize(1)));
                CSGScaleNode.setAttribute([s,'scaleY'], num2str(objsize(2)));
                CSGScaleNode.setAttribute([s,'scaleZ'], num2str(objsize(3)));
            else
                error('No scale specified. Unable to create SBML Spatial file.');
            end
            
            %csgPrimitive
            CSGPrimitiveNode = docNode.createElement([s,'csgPrimitive']);
            CSGPrimitiveNode.setAttribute([s,'id'],type);
            % CSGPrimitiveNode.setAttribute([s,'spatialId'],'cube');
            if strcmpi('sphere',type)
                CSGPrimitiveNode.setAttribute([s,'primitiveType'],'sphere');
            elseif strcmpi('cube',type)
                CSGPrimitiveNode.setAttribute([s,'primitiveType'],'cube');
            else
                warning('unrecognized primitive type specified, defaulting to cube');
                CSGPrimitiveNode.setAttribute([s,'primitiveType'],'cube');
            end
            
            CSGObjectNode = docNode.createElement([s,'csgObject']);
            %     CSGObjectNode.setAttribute([s,'spatialID'],['Sp_', name]);
            CSGObjectNode.setAttribute([s,'id'],[name ...
                num2str(number_of_vesicles)]);
            CSGObjectNode.setAttribute([s,'domainType'],name);
            
            if isfield(object, 'ordinal')
                ordinal = num2str(object.ordinal);
                CSGObjectNode.setAttribute([s,'ordinal'], ordinal);
            end
            
            %CSGTranslationNode <- CSGRotationNode
            CSGTranslationNode.appendChild(CSGRotationNode);
            
            %CSGRotationNode <- CSGScaleNode
            CSGRotationNode.appendChild(CSGScaleNode);
            
            %CSGScaleNode <- CSGPrimitiveNode
            CSGScaleNode.appendChild(CSGPrimitiveNode);
            
            %CSGObjectNode <- CSGTranslationNode
            CSGObjectNode.appendChild(CSGTranslationNode);
            
            %ListOfCSGObjects <-- csgObjectNode
            ListOfCSGObjectsNode.appendChild(CSGObjectNode);
        end
    end
end
CSGeometryNode.appendChild(ListOfCSGObjectsNode);
geometryDefNode.appendChild(CSGeometryNode);
%%%
end

function CSGObjectNode = add_one_object_at_a_time(CSGdata, docNode, k, j)
s = 'spatial:';

domainlist = fieldnames(CSGdata);

ListOfCSGNodes = docNode.createElement([s,'listOfCSGNodes']);
object = CSGdata.(domainlist{k}).list(j);
name = object.name;
type = object.type;
object.ordinal = CSGdata.(domainlist{k}).ordinal;

%csgTranslation
if isfield(object, 'position')
    position = object.position;
    CSGTranslationNode = docNode.createElement([s,'csgTranslation']);
    CSGTranslationNode.setAttribute([s,'id'],'translation');
    CSGTranslationNode.setAttribute([s,'translateX'], num2str(position(1)));
    CSGTranslationNode.setAttribute([s,'translateY'], num2str(position(2)));
    CSGTranslationNode.setAttribute([s,'translateZ'], num2str(position(3)));
else
    error('No position specified. Unable to create SBML Spatial file.');
end

%csgRotation
if isfield(object, 'rotation')
    rotation = object.rotation;
    CSGRotationNode = docNode.createElement([s,'csgRotation']);
    CSGRotationNode.setAttribute([s,'id'], 'rotation');
    CSGRotationNode.setAttribute([s,'rotateAxisX'], num2str(deg2rad(rotation(1))));
    CSGRotationNode.setAttribute([s,'rotateAxisY'], num2str(deg2rad(rotation(2))));
    CSGRotationNode.setAttribute([s,'rotateAxisZ'], num2str(deg2rad(rotation(3))));
    CSGRotationNode.setAttribute([s,'rotateAngleInRadians'], '0');
else
    error('No rotation specified. Unable to create SBML Spatial file.');
end

%csgScale
if isfield(object, 'scale')
    objsize = object.scale;%.*resolution;
    CSGScaleNode = docNode.createElement([s,'csgScale']);
    CSGScaleNode.setAttribute([s,'id'], 'scale');
    CSGScaleNode.setAttribute([s,'scaleX'], num2str(objsize(1)));
    CSGScaleNode.setAttribute([s,'scaleY'], num2str(objsize(2)));
    CSGScaleNode.setAttribute([s,'scaleZ'], num2str(objsize(3)));
else
    error('No scale specified. Unable to create SBML Spatial file.');
end

%csgPrimitive
CSGPrimitiveNode = docNode.createElement([s,'csgPrimitive']);
CSGPrimitiveNode.setAttribute([s,'id'],type);
% CSGPrimitiveNode.setAttribute([s,'spatialId'],'cube');
if strcmpi('sphere',type)
    CSGPrimitiveNode.setAttribute([s,'primitiveType'],'sphere');
elseif strcmpi('cube',type)
    CSGPrimitiveNode.setAttribute([s,'primitiveType'],'cube');
else
    warning('unrecognized primitive type specified, defaulting to cube');
    CSGPrimitiveNode.setAttribute([s,'primitiveType'],'cube');
end

CSGObjectNode = docNode.createElement([s,'csgObject']);
%     CSGObjectNode.setAttribute([s,'spatialID'],['Sp_', name]);
CSGObjectNode.setAttribute([s,'id'],name);
CSGObjectNode.setAttribute([s,'domainType'],name);

if isfield(object, 'ordinal')
    ordinal = num2str(object.ordinal);
    CSGObjectNode.setAttribute([s,'ordinal'], ordinal);
end
end