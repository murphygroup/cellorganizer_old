function [ result ] = instance2SBML( CSGdata, Meshdata, savepath, SBMLfile,resolution )
%INSTANCE2SBML Writes data struct to a SBML-Spatial file. If an existing file is provided
%this method will append to the end of the file.
%
%Inputs:
% CSGdata = struct created using createSBMLstruct.m in slml2img.m
% Meshdata = cell array containing image arrays for mesh type objects to be saved
% savepath = output filename
% SBMLfile = optional path to existing file to append to.
%
%Outputs:
% result = boolean flag indicating success
% saves .xml file in SBML-Spatial format.


%9/17/13
%Authors: Rohan Arepally and Devin Sullivan
%Edited:
%9/18/13 D. Sullivan - formatting and support for parametric objects
%9/24/13 D. Sullivan - edited for VCell compatability.
% Copyright (C) 2012 Murphy Lab
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

if nargin==0
    warning('No input arguments given to instance2SBML. Nothing to do.');
    return
elseif nargin==1
    warning('No savepath given to instance2SBML. Defaulting to "./model.xml"');
    savepath = './model.xml';
    SBMLfile = 1;
end

if nargin<4
    SBMLfile = 1;
end
if nargin<5
    resolution = 1;
end

if isempty(SBMLfile)
    SBMLfile = 1;
end

%Alias s to 'spatial:'. this will be used to denote spatial specific
%attributes and nodes.
s = 'spatial:';
listedCompartments = 0;

if(SBMLfile == 1)
    %Create initial Node Object
    docNode = com.mathworks.xml.XMLUtils.createDocument('sbml');
    %Create Root node and define the namespace for SBML-Spatial
    docRootNode = docNode.getDocumentElement;
    docRootNode.setAttribute('xmlns','http://www.sbml.org/sbml/level3/version1/core');
    docRootNode.setAttribute('level', '3');%('level', '3');
    docRootNode.setAttribute('version', '1');
    
    %Added the 'req' namespace
    docRootNode.setAttribute('xmlns:req','http://www.sbml.org/sbml/level3/version1/requiredElements/version1');
    docRootNode.setAttribute(['req:','required'],'true');
    
    % D. Sullivan 9/18/13
    %probably should have an actual metaID, optional so ignoring for now
    % docRootNode.setAttribute('metaid','_000000');
    docRootNode.setAttribute('xmlns:spatial','http://www.sbml.org/sbml/level3/version1/spatial/version1');
    docRootNode.setAttribute([s,'required'],'true');
    
    %Create model node to wrap everything in
    wrapperNode = docNode.createElement('model');
elseif(ischar(SBMLfile))
    docNode = xmlread(SBMLfile);
    docRootNode = docNode.getDocumentElement;
    allListitems = docNode.getElementsByTagName('model');
    wrapperNode = allListitems.item(0);
    allListitems = wrapperNode.getElementsByTagName('compartment');
    ListOfCompartments = allListitems.item(0);
    %If we've already defined the compartment list in the SBML file, no
    %need to re-do it.
    if length(ListOfCompartments~=0)
        listedCompartments = 1;
    end
    %     wrapperNode = docNode.createElement('model');
    %     wrapperNode = docRootNode.getAttribute('model');
end

%Create initial Node Object
%     docNode = com.mathworks.xml.XMLUtils.createDocument('sbml');
%Create Root node and define the namespace for SBML-Spatial
%     docRootNode = docNode.getDocumentElement;
docRootNode.setAttribute('xmlns','http://www.sbml.org/sbml/level3/version1/core');
docRootNode.setAttribute('level', '2');%('level', '3');
docRootNode.setAttribute('version', '1');

%Added the 'req' namespace
docRootNode.setAttribute('xmlns:req','http://www.sbml.org/sbml/level3/version1/requiredElements/version1');
docRootNode.setAttribute(['req:','required'],'true');

% D. Sullivan 9/18/13
%probably should have an actual metaID, optional so ignoring for now
% docRootNode.setAttribute('metaid','_000000');
docRootNode.setAttribute('xmlns:spatial','http://www.sbml.org/sbml/level3/version1/spatial/version1');
docRootNode.setAttribute([s,'required'],'true');

% wrapperNode.setAttribute('id','CellOrganizer2_0');
% wrapperNode.setAttribute('name',['CellOrganizer2_0',CSGdata.name]);

%Define units
%list
ListOfUnitDefinitions = docNode.createElement('listOfUnitDefinitions');
%substance
UnitDefinition = docNode.createElement('unitDefinition');
UnitDefinition.setAttribute('id','substance');
ListOfUnits = docNode.createElement('listOfUnits');
unit = docNode.createElement('unit');
unit.setAttribute('kind','mole');
unit.setAttribute('exponent','1');
unit.setAttribute('scale','0');
unit.setAttribute('multiplier','1e-09');
ListOfUnits.appendChild(unit);
UnitDefinition.appendChild(ListOfUnits);
ListOfUnitDefinitions.appendChild(UnitDefinition);
%volume
UnitDefinition = docNode.createElement('unitDefinition');
UnitDefinition.setAttribute('id','volume');
ListOfUnits = docNode.createElement('listOfUnits');
unit = docNode.createElement('unit');
unit.setAttribute('kind','micrometer');
unit.setAttribute('exponent','3');
unit.setAttribute('scale','0');
unit.setAttribute('multiplier','0.1');
ListOfUnits.appendChild(unit);
UnitDefinition.appendChild(ListOfUnits);
ListOfUnitDefinitions.appendChild(UnitDefinition);
%area
UnitDefinition = docNode.createElement('unitDefinition');
UnitDefinition.setAttribute('id','area');
ListOfUnits = docNode.createElement('listOfUnits');
unit = docNode.createElement('unit');
unit.setAttribute('kind','micrometer');
unit.setAttribute('exponent','2');
unit.setAttribute('scale','0');
unit.setAttribute('multiplier','1');
ListOfUnits.appendChild(unit);
UnitDefinition.appendChild(ListOfUnits);
ListOfUnitDefinitions.appendChild(UnitDefinition);
%length
UnitDefinition = docNode.createElement('unitDefinition');
UnitDefinition.setAttribute('id','length');
ListOfUnits = docNode.createElement('listOfUnits');
unit = docNode.createElement('unit');
unit.setAttribute('kind','metre');
unit.setAttribute('exponent','1');
unit.setAttribute('scale','0');
unit.setAttribute('multiplier','1');
ListOfUnits.appendChild(unit);
UnitDefinition.appendChild(ListOfUnits);
ListOfUnitDefinitions.appendChild(UnitDefinition);
%time
UnitDefinition = docNode.createElement('unitDefinition');
UnitDefinition.setAttribute('id','time');
ListOfUnits = docNode.createElement('listOfUnits');
unit = docNode.createElement('unit');
unit.setAttribute('kind','second');
unit.setAttribute('exponent','1');
unit.setAttribute('scale','0');
unit.setAttribute('multiplier','60');
ListOfUnits.appendChild(unit);
UnitDefinition.appendChild(ListOfUnits);
ListOfUnitDefinitions.appendChild(UnitDefinition);
%nmol
UnitDefinition = docNode.createElement('unitDefinition');
UnitDefinition.setAttribute('id','nmol');
ListOfUnits = docNode.createElement('listOfUnits');
unit = docNode.createElement('unit');
unit.setAttribute('kind','mole');
unit.setAttribute('exponent','1');
unit.setAttribute('scale','0');
unit.setAttribute('multiplier','1e-09');
ListOfUnits.appendChild(unit);
UnitDefinition.appendChild(ListOfUnits);
ListOfUnitDefinitions.appendChild(UnitDefinition);
% docRootNode.appendChild(ListOfUnitDefinitions);
wrapperNode.appendChild(ListOfUnitDefinitions);
%%%

if ~isempty(CSGdata)
    %Define the domain
    DomainID = CSGdata.class;%'subdomain0';
    
    %Define compartments
    %list
    if listedCompartments==0
        ListOfCompartments = docNode.createElement('listOfCompartments');
        %actual compartment
        compartment = docNode.createElement('compartment');
        dicomWrapper = num2str(dicomuid());
        dicomWrapper = strrep(dicomWrapper, '.', '');
        compartment.setAttribute('metaid',dicomWrapper);
        compartment.setAttribute('id',CSGdata.class);
        compartment.setAttribute('name',CSGdata.class);
        compartment.setAttribute('spatialDimensions','3');
        compartment.setAttribute('size','50000');
        compartment.setAttribute('units','m');
        compartment.setAttribute('constant','true');
        %compartment mapping
        mapping = docNode.createElement([s,'compartment']);
        mapping.setAttribute([s,'spatialId'],[DomainID,CSGdata.class]);
        mapping.setAttribute([s,'compartment'],[CSGdata.class]);
        mapping.setAttribute([s,'domainType'],DomainID);
        mapping.setAttribute([s,'unitSize'],'1');
        %add children node
        compartment.appendChild(mapping);
        ListOfCompartments.appendChild(compartment);
    end
    %add compartments to model
    % docRootNode.appendChild(ListOfCompartments);
    wrapperNode.appendChild(ListOfCompartments);
    
    %set up parameters
    ListOfParameters = docNode.createElement('listOfParameters');
    %actual parameters
    dimensionNames = ['x','y','z'];
    
    for i = 1:length(dimensionNames)
        parameter = docNode.createElement('parameter');
        parameter.setAttribute('id',dimensionNames(i));
        parameter.setAttribute('value','0');
        parameter.setAttribute('req:mathOverridden','spatial');
        parameter.setAttribute('req:coreHaseAlternateMath','false');
        %create spatial:spatialSymbolReference node
        symbolref = docNode.createElement([s,'spatialSymbolReference']);
        symbolref.setAttribute([s,'spatialId'],dimensionNames(i));
        symbolref.setAttribute([s,'type'],'coordinateComponent');
        %add spatial:spatialSymbolReference node to x parameter node
        parameter.appendChild(symbolref);
        %add parameter to list
        ListOfParameters.appendChild(parameter);
    end
    % docRootNode.appendChild(ListOfParameters);
    wrapperNode.appendChild(ListOfParameters);
    
    %%%Set up the Geometry node
    GeowrapperNode = docNode.createElement('spatial:geometry');
    GeowrapperNode.setAttribute([s,'coordinateSystem'],'Cartesian');
    %Create a globally unique ID
    % dicomWrapper = num2str(dicomuid());
    % dicomWrapper = strrep(dicomWrapper, '.', '');
    % GeowrapperNode.setAttribute('id', ['co',dicomWrapper]);
    % GeowrapperNode.setAttribute('geometryType', 'primitive');
    %%%
    
    %%%Set up the ListOfCoordinateComponent node
    ListOfCoordCompNode = docNode.createElement([s,'listOfCoordinateComponents']);
    %for each dimension
    for i = 1:length(dimensionNames)
        CoordCompNode = docNode.createElement([s,'coordinateComponent']);
        CoordCompNode.setAttribute([s,'spatialId'],dimensionNames(i));
        CoordCompNode.setAttribute([s,'componentType'],['cartesian',upper(dimensionNames(i))]);
        CoordCompNode.setAttribute([s,'sbmlUnit'],'m');
        CoordCompNode.setAttribute([s,'index'],num2str(i-1));
        
        %define dimensions
        minNode = docNode.createElement([s,'boundaryMin']);
        minNode.setAttribute([s,'spatialId'],[upper(dimensionNames(i)),'min']);
        minNode.setAttribute([s,'value'],'-10');
        CoordCompNode.appendChild(minNode);
        maxNode = docNode.createElement([s,'boundaryMax']);
        maxNode.setAttribute([s,'spatialId'],[upper(dimensionNames(i)),'max']);
        maxNode.setAttribute([s,'value'],'10');
        CoordCompNode.appendChild(maxNode);
        
        %add component to the list
        ListOfCoordCompNode.appendChild(CoordCompNode);
    end
    GeowrapperNode.appendChild(ListOfCoordCompNode);
    %%%
    
    %%%Set up the ListOfDomainTypes node
    ListOfDomainTypesNode = docNode.createElement([s,'listOfDomainTypes']);
    DomainTypeNode = docNode.createElement([s,'domainType']);
    DomainTypeNode.setAttribute([s,'spatialId'],DomainID);
    DomainTypeNode.setAttribute([s,'spatialDimensions'],'3');
    ListOfDomainTypesNode.appendChild(DomainTypeNode);
    GeowrapperNode.appendChild(ListOfDomainTypesNode);
    %%%
    
    %%%Set up ListOfDomains
    ListOfDomains = docNode.createElement([s,'listOfDomains']);
    DomainNode = docNode.createElement([s,'domain']);
    DomainNode.setAttribute([s,'spatialId'],[DomainID,'0']);
    DomainNode.setAttribute([s,'domainType'],DomainID);
    ListOfInteriorPoints = docNode.createElement([s,'listOfInteriorPoints']);
    InteriorPoint = docNode.createElement([s,'interiorPoint']);
    InteriorPoint.setAttribute([s,'coord1'],'0');
    InteriorPoint.setAttribute([s,'coord2'],'0');
    InteriorPoint.setAttribute([s,'coord3'],'0');
    ListOfInteriorPoints.appendChild(InteriorPoint);
    DomainNode.appendChild(ListOfInteriorPoints);
    ListOfDomains.appendChild(DomainNode);
    GeowrapperNode.appendChild(ListOfDomains);
    %%%
    
    %%%Define the Geometry
    geometryDefNode = docNode.createElement([s,'listOfGeometryDefinitions']);
    % dicom = num2str(dicomuid());
    % dicom = strrep(dicom, '.', '');
    % geometryDefNode.setAttribute('spatialId', ['co',dicom]);
    %%%
    
    
    
    %%%Define all the CSG (Primitive) type geometries
    CSGeometryNode = docNode.createElement([s,'csGeometry']);
    CSGeometryNode.setAttribute([s,'spatialId'], 'CSG_Geometry1');
    % geometryDefNode.appendChild(CSGeometryNode);
    
    ListOfCSGObjectsNode = docNode.createElement([s,'listOfCSGObjects']);
    % ListOfCSGObjectsNode.setAttribute('nameId', CSGdata.name);
%     ind = length(CSGdata.list)+1;
%     CSGdata.list(ind).name = ['EC'];
%     %calculate size required
%     imgsize =size(Meshdata.list(1).img);
%     imgsize = [imgsize(2),imgsize(1),imgsize(3)];
%     ECsize = imgsize.*resolution+[1,1,1];
%     %calculate position
%     CSGdata.list(ind).position = [0,0,0]+imgsize./2.*resolution;
%     CSGdata.list(ind).rotation = [0,0,0];
%     CSGdata.list(ind).scale = ECsize;
%     CSGdata.list(ind).ordinal = 0;
%     CSGdata.list(ind).type = 'cube';
    disp('making primitives')
    %add each CSGObject
    for j=1:length(CSGdata.list)
        %     if (j~=67&&j~=length(CSGdata.list))
        %         continue
        %     end
        object = CSGdata.list(j);
        name = object.name;
        type = object.type;
        
        
        CSGObjectNode = docNode.createElement([s,'csgObject']);
        %     CSGObjectNode.setAttribute([s,'spatialID'],['Sp_', name]);
        CSGObjectNode.setAttribute([s,'spatialId'],name);
        CSGObjectNode.setAttribute([s,'domainType'],name);
        
        if isfield(object, 'ordinal')
            ordinal = num2str(object.ordinal);
            CSGObjectNode.setAttribute([s,'ordinal'], ordinal);
            % CSGObjectNode.setAttribute([s,'ordinal'], '0');
        end
        
        %     CSGTransformationNode = docNode.createElement([s,'csgTransformation']);
        
        if isfield(object, 'position')
            position = object.position;
            CSGTranslationNode = docNode.createElement([s,'csgTranslation']);
            CSGTranslationNode.setAttribute([s,'spatialId'],'translation');
            CSGTranslationNode.setAttribute([s,'translateX'], num2str(position(1)));
            CSGTranslationNode.setAttribute([s,'translateY'], num2str(position(2)));
            CSGTranslationNode.setAttribute([s,'translateZ'], num2str(position(3)));
        else
            error('No position specified. Unable to create SBML Spatial file.');
        end
        
        if isfield(object, 'rotation')
            rotation = object.rotation;
            CSGRotationNode = docNode.createElement([s,'csgRotation']);
            CSGRotationNode.setAttribute([s,'spatialId'], 'rotation');
            %         CSGRotationNode.setAttribute([s,'rotateAxisX'], num2str(rotation(1)));
            %         CSGRotationNode.setAttribute([s,'rotateAxisY'], num2str(rotation(2)));
            %         CSGRotationNode.setAttribute([s,'rotateAxisZ'], num2str(rotation(3)));
            CSGRotationNode.setAttribute([s,'rotateAxisX'], num2str(deg2rad(rotation(1))));
            CSGRotationNode.setAttribute([s,'rotateAxisY'], num2str(deg2rad(rotation(2))));
            CSGRotationNode.setAttribute([s,'rotateAxisZ'], num2str(deg2rad(rotation(3))));
        else
            error('No rotation specified. Unable to create SBML Spatial file.');
        end
        
        if isfield(object, 'scale')
            objsize = object.scale;%.*resolution;
            CSGScaleNode = docNode.createElement([s,'csgScale']);
            CSGScaleNode.setAttribute([s,'spatialId'], 'scale');
            CSGScaleNode.setAttribute([s,'scaleX'], num2str(objsize(1)));
            CSGScaleNode.setAttribute([s,'scaleY'], num2str(objsize(2)));
            CSGScaleNode.setAttribute([s,'scaleZ'], num2str(objsize(3)));
        else
            error('No scale specified. Unable to create SBML Spatial file.');
        end
        
        CSGPrimitiveNode = docNode.createElement([s,'csgPrimitive']);
        CSGPrimitiveNode.setAttribute([s,'spatialId'],type);
        % CSGPrimitiveNode.setAttribute([s,'spatialId'],'cube');
        if strcmpi('sphere',type)
            CSGPrimitiveNode.setAttribute([s,'primitiveType'],'SOLID_SPHERE');
        elseif strcmpi('cube',type)
            CSGPrimitiveNode.setAttribute([s,'primitiveType'],'SOLID_CUBE');
        else
            warning('unrecognized primitive type specified, defaulting to SOLID_CUBE');
            CSGPrimitiveNode.setAttribute([s,'primitiveType'],'SOLID_CUBE');
        end
        
        %     CSGScaleNode.appendChild(CSGPrimitiveNode);
        CSGRotationNode.appendChild(CSGPrimitiveNode);
        CSGScaleNode.appendChild(CSGRotationNode);
        CSGTranslationNode.appendChild(CSGScaleNode);
        %     CSGNodeNode.appendChild(CSGTransformationNode);
        %     CSGNodeNode.appendChild(CSGPrimitiveNode);
        CSGObjectNode.appendChild(CSGTranslationNode);
        %     CSGObjectNode.appendChild(CSGNodeNode);
        ListOfCSGObjectsNode.appendChild(CSGObjectNode);
        
    end
    disp('primitives made')
    CSGeometryNode.appendChild(ListOfCSGObjectsNode);
    geometryDefNode.appendChild(CSGeometryNode);
    GeowrapperNode.appendChild(geometryDefNode);
    %%%
end

if ~isfield(CSGdata,'primitiveOnly')||CSGdata.primitiveOnly==0
    %%Define all the Mesh objects
    % Parametric Geometry
    ParaGeometryNode = docNode.createElement('spatial:ParametricGeometry');
    % geometryDefNode.appendChild(ParaGeometryNode);
    
    %List of Parametric Objects
    ListOfParaObjectsNode = docNode.createElement('spatial:ListOfParametricObjects');
    ListOfParaObjectsNode.setAttribute('SpatialId', Meshdata.name);%(name e.g. 'cell'/'nuc')
    ListOfParaObjectsNode.setAttribute('polygonType', 'triangle');
    % ListOfParaObjectsNode.setAttribute('domain', DomainID);
    
    zslices = zeros(size(Meshdata.list(1).img,3),1);
    for i = 1:length(Meshdata.list)
        object = Meshdata.list(i);
        name = object.name;
        type = object.type;
        
        %assume the cell comes first
        zslicesold = zslices;
        zslices = sum(sum(object.img(1),1),2);
        
        ParaObjectNode = docNode.createElement('spatial:ParaObject');
        ParaObjectNode.setAttribute('spatialID',[name]);%['Sp_', name]);
        %for now we will assume we are only dealing with triangulated meshes
        ParaObjectNode.setAttribute('polygonType','triangle');
        %D.Sullivan 4/15/14 - fixed naming bug.
        %ParaObjectNode.setAttribute('domain',DomainID);
        ParaObjectNode.setAttribute('domain',name);
        
        %This is actually not in the specification for parametric objects,
        %but I think it is important to match with CSGObjects. D. Sullivan
        if isfield(object,'ordinal')
            ParaObjectNode.setAttribute('ordinal', num2str(object.ordinal));
        end
        
        %Get mesh points
        %remove the top and bottom slice of the nucleus fluorescence to ensure
        %that the nucleus lies within the cell.
        if strcmpi(object.name,'NU')
            slices = find(max(max(object.img))>0);
            botslice = min(slices);
            topslice = max(slices);
            object.img(:,:,1) = object.img(:,:,botslice).*0;
            object.img(:,:,end) = object.img(:,:,topslice).*0;
            
        end
	disp('trying to make mesh now')
	tempsavepath = [savepath(1:end-4),'FVtemp',num2str(i),'.mat'];
	if exist(tempsavepath)
		disp('temp results found, loading them...')
		load(tempsavepath)
		rmfield(object,'img');
	else
        	FV = getMeshPoints(object.img,[savepath(1:end-4),num2str(i)]);
		save(tempsavepath,'FV')
		rmfield(object,'img')
	end
% 	resolution
% 	size(FV.vertices)
        FV.vertices = FV.vertices.*repmat(resolution,size(FV.vertices,1),1);
        
            save([savepath(1:end-4),'FV',object.name,'_diffeo.mat'],'FV');
            %        load('./FVCP1.mat','FV');
            %        FV.vertices = FV.vertices-repmat([3,3,3],size(FV.vertices,1),1);
            %         FV.vertices = FV.vertices.*repmat([1,1,2],size(FV.vertices,1),1);%.*1.1-repmat([0.1,0.1,0.1],size(FV.vertices,1),1);
            %         FV.faces = FV.faces*1.1;
    
            %         FV = getMeshPoints(object.img);
          
            %         load('./FVNU1.mat','FV');
            %         FV.vertices = FV.vertices-repmat([3,3,3],size(FV.vertices,1),1);
            %         FV.vertices = FV.vertices;%*0.9+repmat([0.1,0.1,0.1],size(FV.vertices,1),1);
            %         FV.faces = FV.faces*0.9;

        PolyObjectNode = docNode.createElement('spatial:PolygonObject');
        PolyObjectNode.setAttribute('pointIndex', mat2str(FV.vertices) );
        % Rohan Arepally (added faces as an attribute of PolyObjectNode)
        PolyObjectNode.setAttribute('faces', mat2str(FV.faces) );
        ParaObjectNode.appendChild(PolyObjectNode);
        ListOfParaObjectsNode.appendChild(ParaObjectNode);
        
        compartment = docNode.createElement('compartment');
        dicomWrapper = num2str(dicomuid());
        dicomWrapper = strrep(dicomWrapper, '.', '');
        compartment.setAttribute('metaid',dicomWrapper);
        compartment.setAttribute('id',Meshdata.list(i).name);
        compartment.setAttribute('name',Meshdata.list(i).name);
        compartment.setAttribute('spatialDimensions','3');
        compartment.setAttribute('size','50000');
        compartment.setAttribute('units','m');
        compartment.setAttribute('constant','true');
        %compartment mapping
        mapping = docNode.createElement([s,'compartment']);
        DomainID = Meshdata.list(i).name;%'subdomain0';
        mapping.setAttribute([s,'spatialId'],[DomainID,Meshdata.list(i).name]);
        mapping.setAttribute([s,'compartment'],[Meshdata.list(i).name]);
        mapping.setAttribute([s,'domainType'],DomainID);
        mapping.setAttribute([s,'unitSize'],'1');
        %add children node
        compartment.appendChild(mapping);
        ListOfCompartments.appendChild(compartment);
    end
    ParaGeometryNode.appendChild(ListOfParaObjectsNode);
    GeowrapperNode.appendChild(ParaGeometryNode);
end

%%%


%%%Append all the children nodes and save the file

% geometryDefNode.appendChild(CSGeometryNode);
% GeowrapperNode.appendChild(geometryDefNode);

wrapperNode.appendChild(GeowrapperNode);
% docRootNode.appendChild(GeowrapperNode);
docRootNode.appendChild(wrapperNode);
clearvars -except savepath docNode
xmlwrite(savepath, docNode);

result = 1;
end

