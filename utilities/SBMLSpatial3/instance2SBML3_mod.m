function [ result ] = instance2SBML3_mod( CSGdata, meshData, models, imgs, savepath, SBMLfile,mesh_resolution, options )
%INSTANCE2SBML Writes data struct to a SBML-Spatial file. If an existing file is provided
%this method will append to the end of the file.
%
% Inputs
% ------
% CSGdata = struct created using createSBMLstruct.m in slml2img.m
% Meshdata = cell array containing image arrays for mesh type objects to be saved
% savepath = output filename
% SBMLfile = optional path to existing file to append to.
%
% Outputs
% -------
% result = boolean flag indicating success
% saves .xml file in SBML-Spatial format.

% Authors: Rohan Arepally and Devin Sullivan
%
% Copyright (C) 2012-2017 Murphy Lab
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

%9/18/13 D. Sullivan - formatting and support for parametric objects
%9/24/13 D. Sullivan - edited for VCell compatability.

%D. Sullivan 9/10/14 - This is a flag to determine if we will create
%compartments in the xml file. If false, no compartments are created - this
%is not recommended for cases when using the model for simulation. If there
%is an SBML file already being appended to it will have the appropriate
%compartments.
addCompartments = 0;

%D. Sullivan 9/10/14 - how many dimensions do you have?
ndim = 3;

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

if nargin<7
    mesh_resolution = [1,1,1];
end

if isempty(SBMLfile)
    SBMLfile = 1;
end

%Alias s to 'spatial:'. this will be used to denote spatial specific
%attributes and nodes.
% s = 'spatial:';
% listedCompartments = 0;
param.prefix = 'spatial:';
param.ndim = 3;

if ~isempty(CSGdata) && ~isempty(meshData)
    param.mixed = 1;
end

if ~isempty(meshData)
    meshData.resolution = mesh_resolution;
end

s = 'spatial:';
[docNode,docRootNode,wrapperNode,GeowrapperNode] = setupSBML3(CSGdata,meshData,models,imgs, SBMLfile,param,options);

%%%Define the Geometry
if ~isempty(CSGdata) && ~isempty(meshData)
    if options.output.SBMLSpatialImage
        geometryDefNodeParent = docNode.createElement([param.prefix,'listOfGeometryDefinitions']);
        %{
        geometryDefNodeSampledFieldGeometry = docNode.createElement([param.prefix, 'sampledFieldGeometry']);
        geometryDefNodeSampledFieldGeometry.setAttribute([s,'id'],['id' sprintf('%03d',num2str(randi([0 10000000]),1))]);
        geometryDefNodeSampledFieldGeometry.setAttribute('id',geometryDefNodeSampledFieldGeometry.getAttribute([s,'id']));
        geometryDefNodeSampledFieldGeometry.setAttribute([s,'isActive'],'true');
        geometryDefNode = docNode.createElement([param.prefix, 'listOfSampledVolumes']);
        %}
    else
        %this is a "mixed" case
        geometryDefNodeParent = docNode.createElement([param.prefix,'listOfGeometryDefinitions']);
        geometryDefNodeMixed = docNode.createElement([param.prefix, 'mixedGeometry']);
        geometryDefNodeMixed.setAttribute([s,'id'],['id' sprintf('%03d',num2str(randi([0 10000000]),1))]);
        % Does not pass SBML validator
        if options.output.SBMLSpatialVCellCompatible
            geometryDefNodeMixed.setAttribute('id',geometryDefNodeMixed.getAttribute([s,'id']))
        end;
        geometryDefNodeMixed.setAttribute([s,'isActive'],'true');
        geometryDefNode = docNode.createElement([param.prefix, 'listOfGeometryDefinitions']);
    end
else
    geometryDefNode = docNode.createElement([param.prefix,'listOfGeometryDefinitions']);
end

ordinals = [];
domainlist = {};
objs = {};

%%%Set up the ListOfDomainTypes node
ListOfDomainTypesNode = docNode.createElement([s,'listOfDomainTypes']);
GeowrapperNode.appendChild(ListOfDomainTypesNode);
ListOfDomains = docNode.createElement([s,'listOfDomains']);
GeowrapperNode.appendChild(ListOfDomains);

if ~isempty(CSGdata) && ~options.output.SBMLSpatialImage
    [docNode,GeowrapperNode,geometryDefNode,wrapperNode] = addCSGObjects3(CSGdata,docNode,geometryDefNode,GeowrapperNode,wrapperNode,options);
    %Add surface area and volume for the class of the same "name" aka domainType
    
    %grab the ordinals
    domainlist = fieldnames(CSGdata);
    domainlist2 = {};
    for i = 1:length(domainlist)
        if ~strcmp(domainlist{i}, 'primitiveOnly')
            domainlist2{end+1} = domainlist{i};
        end
    end
    domainlist = domainlist2;
    for i = 1:length(domainlist)
        ordinals(i) = CSGdata.(domainlist{i}).ordinal;
        objs{i} = CSGdata.(domainlist{i}).list;
        %[docNode,wrapperNode] = addVol_SurfArea(docNode,wrapperNode,...
        %domainlist{i},CSGdata.(domainlist{i}).totvol,CSGdata.(domainlist{i}).totsa);
    end
end

%D. Sullivan 9/10/14  - added "primitiveOnly" for fast computations here
if (~isfield(CSGdata,'primitiveOnly') || CSGdata.primitiveOnly==0) && ...
        ~isempty(meshData)
    if options.output.SBMLSpatialImage
        % Write image data (for import into Virtual Cell):
        % [docNode,GeowrapperNode,geometryDefNode,wrapperNode] = ...
            % addImageObjects3(meshData,docNode,models,imgs,geometryDefNode, ...
            % GeowrapperNode,wrapperNode, options);
        [docNode,GeowrapperNode,geometryDefNodeParent,wrapperNode] = ...
            addImageObjects3(CSGdata,meshData,docNode,models,imgs,geometryDefNodeParent, ...
            GeowrapperNode,wrapperNode, options);
    else
        % Write mesh data (doesn't work when imported into Virtual Cell):
        [docNode,GeowrapperNode,geometryDefNode,wrapperNode] = ...
            addMeshObjects3(meshData,docNode,geometryDefNode, ...
            GeowrapperNode,wrapperNode, options);
    end
    
    for i = 1:length(meshData.list)
        domainlist{end+1} = meshData.list(i).name;
        ordinals(end+1) = meshData.list(i).ordinal;
        objs{end+1} = meshData.list(i);
    end
end
%%%

%%%List of adjacent domains
%     ordinals = extractfield(CSGdata.(domainlist).list,'ordinal');
[ordinal_list,order] = sort(unique(ordinals));
ListOfAdjacentDomains = docNode.createElement([s,'listOfAdjacentDomains']);
for j=1:length(ordinal_list)-1
    startobjs = {objs{find(ordinals==ordinal_list(j))}};
    linkobjs = {objs{find(ordinals==ordinal_list(j+1))}};
    %ugh, this is going to be really slow, but I can't think of a
    %better way of coding it right now.
    for k = 1:length(startobjs)
        %This is for when we have more than one object in a domain for
        %example. It is very slow and messy, but I don't have time to
        %restructure everything right now.
        for kk = 1:length(startobjs{k})
            %         start_object = CSGdata.list(startobjs(k));
            start_name = [startobjs{k}(kk).name,num2str(kk)];
            %         start_type = startobjs(1).type;
            
            for i = 1:length(linkobjs)
                %See above note for why this is necessary. Sorry it's so slow
                %and shitty.
                for ii = 1:length(linkobjs{i})
                    %             link_object = CSGdata.list(linkobjs(i));
                    link_name = [linkobjs{i}(ii).name,num2str(ii)];
                    %             link_type = link_object(i).type;
                    AdjacentDomainNode = docNode.createElement([s,'adjacentDomains']);
                    AdjacentDomainNode.setAttribute([s,'id'],[start_name,'_',link_name]);
                    % Does not pass SBML validator
                    if options.output.SBMLSpatialVCellCompatible
                        AdjacentDomainNode.setAttribute('id',AdjacentDomainNode.getAttribute([s,'id']))
                    end;
                    AdjacentDomainNode.setAttribute([s,'domain1'],start_name);
                    AdjacentDomainNode.setAttribute([s,'domain2'],link_name);
                    ListOfAdjacentDomains.appendChild(AdjacentDomainNode);
                end
            end
        end
    end
    
end
if ListOfAdjacentDomains.getChildNodes().getLength() > 0
    GeowrapperNode.appendChild(ListOfAdjacentDomains);
end

%%%
%%%Append all the children nodes and save the file

% geometryDefNode.appendChild(CSGeometryNode);
% GeowrapperNode.appendChild(geometryDefNode);
if ~isempty(CSGdata) && ~isempty(meshData)
    %this is a "mixed" case
    if options.output.SBMLSpatialImage
        %{
        geometryDefNodeSampledFieldGeometry.appendChild(geometryDefNode);
        geometryDefNodeParent.appendChild(geometryDefNodeSampledFieldGeometry);
        %}
        
        %{
        %do ordinal mapping:
        ListOfOrdinalMapping = docNode.createElement([param.prefix,'listOfOrdinalMappings']);
        OrdinalMapping = docNode.createElement([param.prefix,'ordinalMappings']);
        %}
        
        GeowrapperNode.appendChild(geometryDefNodeParent);
    else
        geometryDefNodeMixed.appendChild(geometryDefNode);
        geometryDefNodeParent.appendChild(geometryDefNodeMixed);
        %do ordinal mapping:
        ListOfOrdinalMapping = docNode.createElement([param.prefix,'listOfOrdinalMappings']);
        OrdinalMapping = docNode.createElement([param.prefix,'ordinalMappings']);
        
        GeowrapperNode.appendChild(geometryDefNodeParent);
    end
else
    GeowrapperNode.appendChild(geometryDefNode);
end

wrapperNode.appendChild(GeowrapperNode);

% Rearrange spatial:geometry children
elements_to_rearrange = {};
elements_to_rearrange{end+1} = 'listOfAdjacentDomains';
elements_to_rearrange{end+1} = 'listOfCoordinateComponents';
elements_to_rearrange{end+1} = 'listOfDomains';
elements_to_rearrange{end+1} = 'listOfDomainTypes';
elements_to_rearrange{end+1} = 'listOfGeometryDefinitions';
elements_to_rearrange{end+1} = 'listOfSampledFields';
for i = 1:length(elements_to_rearrange)
    element_name = [s, elements_to_rearrange{i}];
    element = GeowrapperNode.getElementsByTagName(element_name);
    if element.getLength() > 0
        element = element.item(0);
        GeowrapperNode.appendChild(GeowrapperNode.removeChild(element));
    end
end

% Rearrange model children
elements_to_rearrange = {};
elements_to_rearrange{end+1} = 'listOfUnitDefinitions';
elements_to_rearrange{end+1} = 'listOfCompartments';
elements_to_rearrange{end+1} = 'listOfParameters';
for i = 1:length(elements_to_rearrange)
    element_name = elements_to_rearrange{i};
    element = wrapperNode.getElementsByTagName(element_name);
    if element.getLength() > 0
        element = element.item(0);
        wrapperNode.appendChild(wrapperNode.removeChild(element));
    end
end

% docRootNode.appendChild(GeowrapperNode);
docRootNode.appendChild(wrapperNode);
xmlwrite(savepath, docNode);
zip([savepath, '.zip'], savepath);

result = 1;
end

