function [docNode,docRootNode] = setupVCML(VCMLfile)
%10/02/18 Taraz Buck  - Copied `setupSBML3.m` to `setupVCML.m`.

BioModelNode = [];
ModelNode = [];
SimulationSpecNode = [];

if(ischar(VCMLfile))
    docNode = xmlread(VCMLfile);
    docRootNode = docNode.getDocumentElement;
    error('Modifying existing VCML documents unimplemented.')
elseif VCMLfile == 1
    %Create initial Node Object
    docNode = com.mathworks.xml.XMLUtils.createDocument('vcml');
    %Create Root node and define the namespace for VCML
    docRootNode = docNode.getDocumentElement;
    listedCompartments = 0;
end

docRootNode.setAttribute('xmlns','http://sourceforge.net/projects/vcell/vcml');
docRootNode.setAttribute('Version', 'Rel_Version_7.0.0_build_11');


%Create model node to wrap everything in
if isempty(BioModelNode)
    BioModelNode = docNode.createElement('BioModel');
    docRootNode.appendChild(BioModelNode);
end
if isempty(ModelNode)
    ModelNode = docNode.createElement('Model');
    BioModelNode.appendChild(ModelNode);
    BioModelNode.appendChild(ModelNode);
end
if isempty(SimulationSpecNode)
    SimulationSpecNode = docNode.createElement('SimulationSpec');
    BioModelNode.appendChild(SimulationSpecNode);
    BioModelNode.appendChild(SimulationSpecNode);
end

BioModelNode.setAttribute('Name','BioModel1');
ModelNode.setAttribute('Name','Model1');
SimulationSpecNode.setAttribute('Name','Application1');

% Following based on a VCML file saved using Virtual Cell
ModelUnitSystemNode = docNode.createElement('ModelUnitSystem');
ModelUnitSystemNode.setAttribute('VolumeSubstanceUnit','uM.um3');
ModelUnitSystemNode.setAttribute('MembraneSubstanceUnit','molecules');
ModelUnitSystemNode.setAttribute('LumpedReactionSubstanceUnit','molecules');
ModelUnitSystemNode.setAttribute('VolumeUnit','um3');
ModelUnitSystemNode.setAttribute('AreaUnit','um2');
ModelUnitSystemNode.setAttribute('LengthUnit','um');
ModelUnitSystemNode.setAttribute('TimeUnit','s');
ModelNode.appendChild(ModelUnitSystemNode);

SimulationSpecNode.setAttribute('Stochastic','true');
SimulationSpecNode.setAttribute('UseConcentration','true');
SimulationSpecNode.setAttribute('RuleBased','false');
SimulationSpecNode.setAttribute('InsufficientIterations','false');
SimulationSpecNode.setAttribute('InsufficientMaxMolecules','false');
SimulationSpecNode.setAttribute('CharacteristicSize','0.003875968992248062');

NetworkConstraintsNode = docNode.createElement('NetworkConstraints');
NetworkConstraintsNode.setAttribute('RbmMaxIteration','3');
NetworkConstraintsNode.setAttribute('RbmMaxMoleculesPerSpecies','10');
SimulationSpecNode.appendChild(NetworkConstraintsNode);

GeometryNode = docNode.createElement('Geometry');
GeometryNode.setAttribute('Name','Geometry1');
GeometryNode.setAttribute('Dimension','3');
SimulationSpecNode.appendChild(GeometryNode);

ExtentNode = docNode.createElement('Extent');
ExtentNode.setAttribute('X','1');
ExtentNode.setAttribute('Y','1');
ExtentNode.setAttribute('Z','1');
GeometryNode.appendChild(ExtentNode);

OriginNode = docNode.createElement('Origin');
OriginNode.setAttribute('X','0');
OriginNode.setAttribute('Y','0');
OriginNode.setAttribute('Z','0');
GeometryNode.appendChild(OriginNode);

