function [docNode,GeowrapperNode,geometryDefNode,wrapperNode] = addCSGObjects(CSGdata,docNode,geometryDefNode,GeowrapperNode,wrapperNode)

s = 'spatial:';
% listedCompartments = 0;

%%%Set up the ListOfDomainTypes node
ListOfDomainTypesNode = docNode.createElement([s,'listOfDomainTypes']);
%get list of domain types from CSG data list
%     domainlist = unique(extractfield(CSGdata.list,'name'));
domainlist = fieldnames(CSGdata);
for j = 1:length(domainlist)
    DomainTypeNode = docNode.createElement([s,'domainType']);
    DomainTypeNode.setAttribute([s,'id'],domainlist{j});
    DomainTypeNode.setAttribute([s,'spatialDimensions'],'3');
    ListOfDomainTypesNode.appendChild(DomainTypeNode);
    
    GeowrapperNode.appendChild(ListOfDomainTypesNode);
    %%%Set up ListOfDomains
    ListOfDomains = docNode.createElement([s,'listOfDomains']);
    for i=1:length(CSGdata.(domainlist{j}).list)
        %     if (j~=67&&j~=length(CSGdata.list))
        %         continue
        %     end
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
%     ordinals(j) = CSGdata.(domainlist{j}).list.ordinal;
end
GeowrapperNode.appendChild(ListOfDomains);

%%%Define all the CSG (Primitive) type geometries
CSGeometryNode = docNode.createElement([s,'csGeometry']);
CSGeometryNode.setAttribute([s,'id'], 'CSG_Geometry1');
CSGeometryNode.setAttribute([s,'isActive'],'true');
% geometryDefNode.appendChild(CSGeometryNode);

ListOfCSGObjectsNode = docNode.createElement([s,'listOfCSGObjects']);

%add each CSGObject
for k = 1:length(domainlist)
    for j=1:length(CSGdata.(domainlist{k}).list)
        %     if (j~=67&&j~=length(CSGdata.list))
        %         continue
        %     end
        object = CSGdata.(domainlist{k}).list(j);
        name = object.name;
        type = object.type;
        object.ordinal = CSGdata.(domainlist{k}).ordinal;
        
        CSGObjectNode = docNode.createElement([s,'csgObject']);
        %     CSGObjectNode.setAttribute([s,'spatialID'],['Sp_', name]);
        CSGObjectNode.setAttribute([s,'id'],name);
        CSGObjectNode.setAttribute([s,'domainType'],name);
        
        if isfield(object, 'ordinal')
            ordinal = num2str(object.ordinal);
            CSGObjectNode.setAttribute([s,'ordinal'], ordinal);
          
          %%This is now done in the getBox.m method as it must be consistent with the volume parameters saved  
        end
        
        CSGTransformationNode = docNode.createElement([s,'csgHomogeneousTransformation']);
        
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
        
        if isfield(object, 'rotation')
            rotation = object.rotation;
            CSGRotationNode = docNode.createElement([s,'csgRotation']);
            CSGRotationNode.setAttribute([s,'id'], 'rotation');
            CSGRotationNode.setAttribute([s,'rotateAxisX'], num2str(deg2rad(rotation(1))));
            CSGRotationNode.setAttribute([s,'rotateAxisY'], num2str(deg2rad(rotation(2))));
            CSGRotationNode.setAttribute([s,'rotateAxisZ'], num2str(deg2rad(rotation(3))));
            
            %icaoberg: I have to double check the definition for this
            %attribute
            CSGRotationNode.setAttribute([s,'rotateAngleInRadians'], '0');
        else
            error('No rotation specified. Unable to create SBML Spatial file.');
        end
        
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
        
        CSGPrimitiveNode = docNode.createElement([s,'csgPrimitive']);
        CSGPrimitiveNode.setAttribute([s,'id'],type);
        % CSGPrimitiveNode.setAttribute([s,'spatialId'],'cube');
        if strcmpi('sphere',type)
            CSGPrimitiveNode.setAttribute([s,'primitiveType'],'sphere');
        elseif strcmpi('cube',type)
            CSGPrimitiveNode.setAttribute([s,'primitiveType'],'cube');
        else
            warning('Unrecognized primitive type specified, defaulting to cube');
            CSGPrimitiveNode.setAttribute([s,'primitiveType'],'cube');
        end
        
        CSGTransformationNode.appendChild(CSGRotationNode);
        CSGTransformationNode.appendChild(CSGTranslationNode);
        CSGTransformationNode.appendChild(CSGScaleNode);
        CSGObjectNode.appendChild(CSGTransformationNode);
        CSGObjectNode.appendChild(CSGPrimitiveNode);
        ListOfCSGObjectsNode.appendChild(CSGObjectNode);
        
    end
end

CSGeometryNode.appendChild(ListOfCSGObjectsNode);
geometryDefNode.appendChild(CSGeometryNode);