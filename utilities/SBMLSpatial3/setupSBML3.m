function [docNode,docRootNode,wrapperNode,GeowrapperNode] = setupSBML3(SBMLfile,param)

%D. Sullivan 9/10/14 - This is a flag to determine if we will create
%compartments in the xml file. If false, no compartments are created - this
%is not recommended for cases when using the model for simulation. If there
%is an SBML file already being appended to it will have the appropriate
%compartments.
addCompartments = 0;

%D. Sullivan 9/10/14 - how many dimensions do you have?
%D. Sullivan 9/11/14 added param structure to make initialization easier
ndim = param.ndim;
s = param.prefix;

if(ischar(SBMLfile))
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
    else 
        listedCompartments = 0;
    end
    %     wrapperNode = docNode.createElement('model');
    %     wrapperNode = docRootNode.getAttribute('model');
else SBMLfile == 1
    %Create initial Node Object
    docNode = com.mathworks.xml.XMLUtils.createDocument('sbml');
    %Create Root node and define the namespace for SBML-Spatial
    docRootNode = docNode.getDocumentElement;
    docRootNode.setAttribute('xmlns','http://www.sbml.org/sbml/level3/version1');
    docRootNode.setAttribute('level', '3');%('level', '3');
    
    % D. Sullivan 9/18/13
    %probably should have an actual metaID, optional so ignoring for now
    % docRootNode.setAttribute('metaid','_000000');
    docRootNode.setAttribute('xmlns:spatial','http://www.sbml.org/sbml/level3/version1/spatial/version1');
    docRootNode.setAttribute([s,'required'],'true');
    
    %Create model node to wrap everything in
    wrapperNode = docNode.createElement('model');
    listedCompartments = 0;
end

%Create initial Node Object
%     docNode = com.mathworks.xml.XMLUtils.createDocument('sbml');
%Create Root node and define the namespace for SBML-Spatial
%     docRootNode = docNode.getDocumentElement;
docRootNode.setAttribute('xmlns','http://www.sbml.org/sbml/level3/version1/core');

docRootNode.setAttribute('level', '3');
docRootNode.setAttribute('version', '1');

%Added the 'req' namespace
%docRootNode.setAttribute('xmlns:req','http://www.sbml.org/sbml/level3/version1/requiredElements/version1');
%docRootNode.setAttribute(['req:','required'],'true');

% D. Sullivan 9/18/13
%probably should have an actual metaID, optional so ignoring for now
% docRootNode.setAttribute('metaid','_000000');
docRootNode.setAttribute('xmlns:spatial','http://www.sbml.org/sbml/level3/version1/spatial/version1');
docRootNode.setAttribute([s,'required'],'true');

% wrapperNode.setAttribute('id','CellOrganizer2_0');
% wrapperNode.setAttribute('name',['CellOrganizer2_0',CSGdata.name]);

%%%Set up the Geometry node
    GeowrapperNode = docNode.createElement('spatial:geometry');
    GeowrapperNode.setAttribute([s,'coordinateSystem'],'cartesian');
    
    %Define compartments
    %list
    if listedCompartments==0 && addCompartments == 1
        ListOfCompartments = docNode.createElement('listOfCompartments');
        compartmentlistCSG = [];
        compartmentlistMesh = [];
        if ~isempty(CSGdata)
            compartmentlistCSG = unique(extractfield(CSGdata.list,'name'));
        end
        if ~isempty(Meshdata)
            compartmentlistMesh = unique(extractfield(Meshdata.list,'name'));
        end
        compartmentlist = unique([compartmentlistCSG,compartmentlistMesh]);
        %extract compartment information
        for j = 1:length(compartmentlist)
            %actual compartment
            compartment = docNode.createElement('compartment');
%             dicomWrapper = num2str(dicomuid());
%             dicomWrapper = strrep(dicomWrapper, '.', '');
            %         compartment.setAttribute('metaid',dicomWrapper);
            compartment.setAttribute('id',compartmentlist{j});%CSGdata.class);
            compartment.setAttribute('name',compartmentlist{j});%CSGdata.class);
            compartment.setAttribute('spatialDimensions','3');
            compartment.setAttribute('size','50000');
            compartment.setAttribute('units','um3');%'m');
            compartment.setAttribute('constant','true');
            %compartment mapping
            mapping = docNode.createElement([s,'compartmentMapping']);
            mapping.setAttribute([s,'id'],[compartmentlist{j},compartmentlist{j}]);%[DomainID,CSGdata.class]);
            mapping.setAttribute([s,'compartment'],compartmentlist{j});%[CSGdata.class]);
            mapping.setAttribute([s,'domainType'],compartmentlist{j});%DomainID);
            mapping.setAttribute([s,'unitSize'],'1');
            %add children node
            compartment.appendChild(mapping);
            %         ListOfCompartments.appendChild(compartment);
            
            %add annotation
            annotation = addAnnotation(docNode);
            compartment.appendChild(annotation);
            ListOfCompartments.appendChild(compartment);
        end
        wrapperNode.appendChild(ListOfCompartments);
        
    end
    
    
    
% if ~isempty(CSGdata)
    %Define the domain
%     DomainID = CSGdata.class;%'subdomain0';
    
    %Define compartments
    %list
%     if listedCompartments==0
%         ListOfCompartments = docNode.createElement('listOfCompartments');
%         %actual compartment
%         compartment = docNode.createElement('compartment');
% %         dicomWrapper = num2str(dicomuid());
% %         dicomWrapper = strrep(dicomWrapper, '.', '');
% %         compartment.setAttribute('metaid',dicomWrapper);
%         compartment.setAttribute('id',CSGdata.class);
%         compartment.setAttribute('name',CSGdata.class);
%         compartment.setAttribute('spatialDimensions','3');
%         compartment.setAttribute('size','50000');
%         compartment.setAttribute('units','um3');%'m');
%         compartment.setAttribute('constant','true');
%         %compartment mapping
%         mapping = docNode.createElement([s,'compartmentMapping']);
%         mapping.setAttribute([s,'spatialId'],[DomainID,CSGdata.class]);
%         mapping.setAttribute([s,'compartment'],[CSGdata.class]);
%         mapping.setAttribute([s,'domainType'],DomainID);
%         mapping.setAttribute([s,'unitSize'],'1');
%         %add children node
%         compartment.appendChild(mapping);
% %         ListOfCompartments.appendChild(compartment);
%         
%         %add annotation
%         annotation = addAnnotation(docNode);
%         compartment.appendChild(annotation);
%         ListOfCompartments.appendChild(compartment);
%         
%     end
    %add compartments to model
    % docRootNode.appendChild(ListOfCompartments);
%     wrapperNode.appendChild(ListOfCompartments);
    
    %add Species field to the files - this doesn't currently add real
    %values, it is only there for demonstration. CellOrganizer doesn't
    %currently support the specification of species
    addspecs = 0;
    if addspecs==1
        listOfSpecies = addSpecies(docNode);
        wrapperNode.appendChild(listOfSpecies);
    end
   
    %Add listOfInitialAssignments
    initAssign = 0;
    if initAssign == 1
       listOfInitialAssignments = addInitAssign(docNode);
       wrapperNode.appendChild(listOfInitialAssignments);
    end
        
    %%%Set up the ListOfCoordinateComponent node
    ListOfCoordCompNode = docNode.createElement([s,'listOfCoordinateComponents']);
    %for each dimension
    dimensionNames = ['x','y','z'];
    for i = 1:ndim
        CoordCompNode = docNode.createElement([s,'coordinateComponent']);
        CoordCompNode.setAttribute([s,'id'],dimensionNames(i));
        CoordCompNode.setAttribute([s,'type'],['cartesian',upper(dimensionNames(i))]);
        CoordCompNode.setAttribute([s,'unit'],'m');
        
        %define dimensions
        minNode = docNode.createElement([s,'boundaryMin']);
        minNode.setAttribute([s,'id'],[upper(dimensionNames(i)),'min']);
        minNode.setAttribute([s,'value'],'-10');
        CoordCompNode.appendChild(minNode);
        maxNode = docNode.createElement([s,'boundaryMax']);
        maxNode.setAttribute([s,'id'],[upper(dimensionNames(i)),'max']);
        maxNode.setAttribute([s,'value'],'10');
        CoordCompNode.appendChild(maxNode);
        
        %add component to the list
        ListOfCoordCompNode.appendChild(CoordCompNode);
    end
    GeowrapperNode.appendChild(ListOfCoordCompNode);
    %%%
