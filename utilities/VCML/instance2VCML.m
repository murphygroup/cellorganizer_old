function [ result ] = instance2VCML( models, imgs, savepath, VCMLfile, resolution, options )
%INSTANCE2VCML Writes data struct to a VCML file.
%
% Inputs
% ------
% models   = cell array of models produced in slml2img.m
% imgs     = cell array containing image arrays for all objects to be saved
% savepath = output filename
% VCMLfile = Must be 1. Enhancement: optional path to existing file to append to.
%
% Outputs
% -------
% result = boolean flag indicating success
% saves .vcml file in VCML format.

% Authors: Taraz Buck, Rohan Arepally, and Devin Sullivan
%
% Copyright (C) 2012-2018 Murphy Lab
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

%10/02/18 Taraz Buck  - Copied `instance2SBML3_mod.m` to `instance2VCML.m`.

% %D. Sullivan 9/10/14 - how many dimensions do you have?
% ndim = 3;

if nargin<2
    warning('Model and image arguments not given to instance2VCML. Nothing to do.');
    return
end

if nargin<3
    warning('No savepath given to instance2VCML. Defaulting to "./model.vcml"');
    savepath = './model.vcml';
    VCMLfile = 1;
end

if nargin<4
    VCMLfile = 1;
end

if nargin<5
    resolution = [1,1,1];
end

if isempty(VCMLfile)
    VCMLfile = 1;
end

% param.prefix = 'spatial:';
% param.ndim = 3;

% [docNode,docRootNode] = setupVCML(VCMLfile,param);
[docNode,docRootNode] = setupVCML(VCMLfile);


ModelNode = docRootNode.getElementsByTagName('BioModel').item(0).getElementsByTagName('Model').item(0);
ModelNodeName = char(ModelNode.getAttribute('Name'));
GeometryNode = docRootNode.getElementsByTagName('BioModel').item(0).getElementsByTagName('SimulationSpec').item(0).getElementsByTagName('Geometry').item(0);
GeometryNodeName = char(GeometryNode.getAttribute('Name'));

ImageNode = docNode.createElement('Image');
GeometryNode.appendChild(ImageNode);
ImageNodeName = 'Image1';
ImageNode.setAttribute('Name',ImageNodeName);
GeometryNode.appendChild(ImageNode);

ExtentNode = GeometryNode.getElementsByTagName('Extent').item(0);
ExtentNode.setAttribute('X',num2str(size(imgs{1},2) * resolution(2)));
ExtentNode.setAttribute('Y',num2str(size(imgs{1},1) * resolution(1)));
ExtentNode.setAttribute('Z',num2str(size(imgs{1},3) * resolution(3)));

SimulationSpecNode = docRootNode.getElementsByTagName('BioModel').item(0).getElementsByTagName('SimulationSpec').item(0);
GeometryContextNode = docNode.createElement('GeometryContext');
SimulationSpecNode.appendChild(GeometryContextNode);

ReactionContextNode = docNode.createElement('ReactionContext');
SimulationSpecNode.appendChild(ReactionContextNode);

SpatialObjectsNode = docNode.createElement('SpatialObjects');
SimulationSpecNode.appendChild(SpatialObjectsNode);

MicroscopeMeasurementNode = docNode.createElement('MicroscopeMeasurement');
MicroscopeMeasurementNode.setAttribute('Name','fluor');
SimulationSpecNode.appendChild(MicroscopeMeasurementNode);
ConvolutionKernelNode = docNode.createElement('ConvolutionKernel');
% ConvolutionKernelNode.setAttribute('Type','ProjectionZKernel');
ConvolutionKernelNode.setAttribute('Type','GaussianConvolutionKernel');
MicroscopeMeasurementNode.appendChild(ConvolutionKernelNode);
SigmaXYNode = docNode.createElement('SigmaXY');
ConvolutionKernelNode.appendChild(SigmaXYNode);
SigmaXYNodeTextNode = docNode.createTextNode(num2str(0));
SigmaXYNode.appendChild(SigmaXYNodeTextNode);
SigmaZNode = docNode.createElement('SigmaZ');
ConvolutionKernelNode.appendChild(SigmaZNode);
SigmaZNodeTextNode = docNode.createTextNode(num2str(0));
SigmaZNode.appendChild(SigmaZNodeTextNode);

relationshipModelNode = docNode.createElement('relationshipModel');
SimulationSpecNode.appendChild(relationshipModelNode);

vcmetadataNode = docNode.createElement('vcmetadata');
SimulationSpecNode.appendChild(vcmetadataNode);


% Create a single image containing all compartments. Assumes no overlapping.

named_imgs = containers.Map('KeyType', 'char', 'ValueType', 'any');
named_img_volumes = containers.Map('KeyType', 'char', 'ValueType', 'double');
if any(strcmpi(options.synthesis, {'all', 'framework', 'nucleus'}))
    named_imgs('nucleus') = imgs{1};
end
if any(strcmpi(options.synthesis, {'all', 'framework'}))
    named_imgs('cell') = imgs{2};
elseif strcmpi(options.synthesis, 'cell')
    named_imgs('cell') = imgs{1};
end
if strcmpi(options.synthesis, 'all')
    for i = 1:length(models)
        model = models{i};
        name = ['model', num2str(i), '_', strrep(model.filename, '.', '_')];
        named_imgs(name) = imgs{i+2};
    end
end
names = named_imgs.keys;
for i = 1:length(names)
    name = names{i};
    img = named_imgs(name);
    named_img_volumes(name) = sum(img(:)) * prod(resolution);
end

% Sort by volume
named_img_volumes_keys = named_img_volumes.keys;
named_img_volumes_values = cell2mat(named_img_volumes.values(named_img_volumes_keys));
[named_img_volumes_values, named_img_volumes_values_sort_order] = sort(named_img_volumes_values);
named_img_volumes_keys_sorted = named_img_volumes_keys(named_img_volumes_values_sort_order);
clear named_img_volumes_keys named_img_volumes_values named_img_volumes_values_sort_order;

all_objects_image = [];
for i = 1:length(named_imgs)
    name = named_img_volumes_keys_sorted{i};
    img = named_imgs(name);
    
    if isempty(all_objects_image)
        all_objects_image = zeros(size(img), 'uint8');
    end
    mask = img > 0;
    % Don't overwrite objects with smaller total volumes
    mask = mask & all_objects_image == 0;
    mask_mean = mean(mask(:));
    % EC will be zero, cell with be 1, etc.
    all_objects_image(mask) = length(named_imgs) - i + 1;
    if mask_mean == 0
        error('mask_mean == 0');
    end
end

all_compartment_names = [{'EC'}, named_img_volumes_keys_sorted];
all_compartment_volumes = zeros(length(all_compartment_names), 1);
for i = 2:length(all_compartment_names)
    all_compartment_volumes(i) = named_img_volumes(all_compartment_names{i});
end
all_compartment_volumes(1) = sum(all_compartment_volumes);

% Data required to generate VCML
all_compartment_VCML_data = struct();
for i = 1:length(all_compartment_names)
    name = all_compartment_names{i};
    volume = all_compartment_volumes(i);
    all_compartment_VCML_data(i).name = name;
    all_compartment_VCML_data(i).volume = volume;
    % all_compartment_VCML_data(i).FeatureName = ['Feature1_', name];
    all_compartment_VCML_data(i).FeatureName = name;
    % all_compartment_VCML_data(i).DiagramName = ['Diagram1_', name];
    all_compartment_VCML_data(i).DiagramName = name;
    all_compartment_VCML_data(i).PixelClassNodeName = ['PixelClass1_', name];
    all_compartment_VCML_data(i).SubVolumeNodeName = ['SubVolume1_', name];
    all_compartment_VCML_data(i).VolumeRegionNodeName = ['VolumeRegion1_', name];
end

% Find adjacent compartments.
adjacent_pairs = {};
directions = [1, 0, 0; 0, 1, 0; 0, 0, 1];
for direction = directions'
    temp = all_objects_image(1:end - direction(1), 1:end - direction(2), 1:end - direction(3));
    temp2 = all_objects_image(1 + direction(1):end, 1 + direction(2):end, 1 + direction(3):end);
    temp = [temp(:), temp2(:)];
    temp = unique(temp, 'rows');
    clear temp2;
    adjacent_pairs{end+1} = temp;
end
adjacent_pairs = cell2mat(adjacent_pairs');
adjacent_pairs = sort(adjacent_pairs, 2);
adjacent_pairs = unique(adjacent_pairs, 'rows');
adjacent_pairs = adjacent_pairs(adjacent_pairs(:, 1) ~= adjacent_pairs(:, 2), :);
% Convert from image values to compartment index
adjacent_pairs = adjacent_pairs + 1;

% Data required to generate VCML
all_membrane_VCML_data = struct();
k = 0;
for ij = adjacent_pairs'
    k = k + 1;
    i = ij(1);
    j = ij(2);
    start_obj = all_compartment_VCML_data(i);
    link_obj = all_compartment_VCML_data(j);
    
    pair_suffix = ['_', start_obj.name, '_', link_obj.name];
    
    % Estimate surface area from gradient
    [membrane_gradient_x, membrane_gradient_y, membrane_gradient_z] = gradient(single(all_objects_image == i));
    area = sqrt(membrane_gradient_x.^2 + membrane_gradient_y.^2 + membrane_gradient_z.^2);
    area = sum(area(:));
    area = area * prod(resolution);
    
    all_membrane_VCML_data(k).i = i;
    all_membrane_VCML_data(k).j = j;
    all_membrane_VCML_data(k).pair_suffix = pair_suffix;
    all_membrane_VCML_data(k).area = area;
    all_membrane_VCML_data(k).MembraneNodeName = ['Membrane1', pair_suffix];
    all_membrane_VCML_data(k).MembraneNodeVoltageName = [all_membrane_VCML_data(end).MembraneNodeName, '_MembraneVoltage'];
    all_membrane_VCML_data(k).DiagramNodeName = ['Diagram1', pair_suffix];
    all_membrane_VCML_data(k).SurfaceClassNodeName = ['SurfaceClass1', pair_suffix];
    all_membrane_VCML_data(k).MembraneRegionNodeName = ['MembraneRegion1', pair_suffix];
end


ImageDataNode = docNode.createElement('ImageData');
ImageDataNode.setAttribute('X',num2str(size(all_objects_image,2)));
ImageDataNode.setAttribute('Y',num2str(size(all_objects_image,1)));
ImageDataNode.setAttribute('Z',num2str(size(all_objects_image,3)));
ImageNode.appendChild(ImageDataNode);

% https://github.com/virtualcell/vcell/blob/master/vcell-core/src/main/java/cbit/vcell/xml/Xmlproducer.java creates a `VCImageCompressed`, which uses InflaterInputStream to decompress pixel data.
SamplesBytes = all_objects_image;
SamplesBytes = permute(all_objects_image, [2, 1, 3]);
SamplesBytes = SamplesBytes(:);
% https://undocumentedmatlab.com/blog/savezip-utility
inputStream = SamplesBytes;
outputStream = java.io.ByteArrayOutputStream();
compressedInputStream = java.util.zip.DeflaterOutputStream(outputStream);
compressedInputStream.write(inputStream, 0, numel(inputStream));
% Turns out to be a uint8 matrix
% inputStream.close();
clear inputStream;
compressedInputStream.finish();
SamplesText = outputStream.toString();
compressedInputStream.close();
outputStream.close();
import javax.xml.bind.DatatypeConverter;
SamplesBytes = SamplesText.getBytes();
SamplesText = DatatypeConverter.printHexBinary(SamplesBytes);
SamplesText = char(SamplesText);
SamplesTextLength = length(SamplesText);
% SamplesText = wrapString(SamplesText);

ImageDataTextNode = docNode.createTextNode(SamplesText);
clear SamplesText;
ImageDataNode.setAttribute('CompressedSize',num2str(SamplesTextLength));
ImageDataNode.appendChild(ImageDataTextNode);


for i = 1:length(all_compartment_VCML_data)
    object = all_compartment_VCML_data(i);
    name = object.name;
    
    FeatureNode = docNode.createElement('Feature');
    FeatureNode.setAttribute('Name',object.FeatureName);
    ModelNode.appendChild(FeatureNode);
    
    DiagramNode = docNode.createElement('Diagram');
    DiagramNode.setAttribute('Name',object.DiagramName);
    DiagramNode.setAttribute('Structure',object.FeatureName);
    ModelNode.appendChild(DiagramNode);
    
    PixelClassNode = docNode.createElement('PixelClass');
    PixelClassNode.setAttribute('Name',object.PixelClassNodeName);
    PixelClassNode.setAttribute('ImagePixelValue',num2str(i-1));
    ImageNode.appendChild(PixelClassNode);
end


for i = 1:length(all_compartment_VCML_data)
    object = all_compartment_VCML_data(i);
    name = object.name;
    SubVolumeNode = docNode.createElement('SubVolume');
    SubVolumeNode.setAttribute('Name',object.SubVolumeNodeName);
    SubVolumeNode.setAttribute('Handle',num2str(i-1));
    SubVolumeNode.setAttribute('Type','Image');
    SubVolumeNode.setAttribute('ImagePixelValue',num2str(i-1));
    GeometryNode.appendChild(SubVolumeNode);
end


SurfaceDescriptionNode = docNode.createElement('SurfaceDescription');
SurfaceDescriptionNode.setAttribute('NumSamplesX',num2str(size(all_objects_image,2)));
SurfaceDescriptionNode.setAttribute('NumSamplesY',num2str(size(all_objects_image,1)));
SurfaceDescriptionNode.setAttribute('NumSamplesZ',num2str(size(all_objects_image,3)));
SurfaceDescriptionNode.setAttribute('CutoffFrequency','0.3');
GeometryNode.appendChild(SurfaceDescriptionNode);


for i = 1:length(all_compartment_VCML_data)
    object = all_compartment_VCML_data(i);
    name = object.name;
    volume = object.volume;
    VolumeRegionNode = docNode.createElement('VolumeRegion');
    VolumeRegionNode.setAttribute('Name',object.VolumeRegionNodeName);
    VolumeRegionNode.setAttribute('RegionID',num2str(i-1));
    VolumeRegionNode.setAttribute('SubVolume',object.SubVolumeNodeName);
    VolumeRegionNode.setAttribute('Size',num2str(volume));
    VolumeRegionNode.setAttribute('Unit','um3');
    SurfaceDescriptionNode.appendChild(VolumeRegionNode);
end


warning('Ignoring CSGdata.primitiveOnly.');
warning('Ordinals not used here, connectivity inferred using adjacency in image.');

for k = 1:length(all_membrane_VCML_data)
    object = all_membrane_VCML_data(k);
    i = object.i;
    j = object.j;
    pair_suffix = object.pair_suffix;
    area = object.area;
    
    start_obj = all_compartment_VCML_data(i);
    link_obj = all_compartment_VCML_data(j);
    
    MembraneNode = docNode.createElement('Membrane');
    MembraneNode.setAttribute('Name',object.MembraneNodeName);
    MembraneNode.setAttribute('MembraneVoltage',object.MembraneNodeVoltageName);
    ModelNode.appendChild(MembraneNode);
    
    DiagramNode = docNode.createElement('Diagram');
    DiagramNode.setAttribute('Name',object.DiagramNodeName);
    DiagramNode.setAttribute('Structure',object.MembraneNodeName);
    ModelNode.appendChild(DiagramNode);
    
    SurfaceClassNode = docNode.createElement('SurfaceClass');
    SurfaceClassNode.setAttribute('Name',object.SurfaceClassNodeName);
    SurfaceClassNode.setAttribute('SubVolume1Ref',start_obj.SubVolumeNodeName);
    SurfaceClassNode.setAttribute('SubVolume2Ref',link_obj.SubVolumeNodeName);
    GeometryNode.appendChild(SurfaceClassNode);
    
    MembraneRegionNode = docNode.createElement('MembraneRegion');
    MembraneRegionNode.setAttribute('Name',object.MembraneRegionNodeName);
    MembraneRegionNode.setAttribute('VolumeRegion1',start_obj.VolumeRegionNodeName);
    MembraneRegionNode.setAttribute('VolumeRegion2',link_obj.VolumeRegionNodeName);
    MembraneRegionNode.setAttribute('Size',num2str(area));
    MembraneRegionNode.setAttribute('Unit','um2');
    SurfaceDescriptionNode.appendChild(MembraneRegionNode);
    
end


for i = 1:length(all_compartment_VCML_data)
    object = all_compartment_VCML_data(i);
    name = object.name;
    volume = object.volume;
    FeatureMappingNode = docNode.createElement('FeatureMapping');
    FeatureMappingNode.setAttribute('Feature',object.FeatureName);
    FeatureMappingNode.setAttribute('GeometryClass',object.SubVolumeNodeName);
    FeatureMappingNode.setAttribute('SubVolume',object.SubVolumeNodeName);
    FeatureMappingNode.setAttribute('Size',num2str(volume));
    FeatureMappingNode.setAttribute('VolumePerUnitVolume',num2str(1));
    GeometryContextNode.appendChild(FeatureMappingNode);
    
    BoundariesTypesNode = docNode.createElement('BoundariesTypes');
    BoundariesTypesNode.setAttribute('Xm','Flux');
    BoundariesTypesNode.setAttribute('Xp','Flux');
    BoundariesTypesNode.setAttribute('Ym','Flux');
    BoundariesTypesNode.setAttribute('Yp','Flux');
    BoundariesTypesNode.setAttribute('Zm','Flux');
    BoundariesTypesNode.setAttribute('Zp','Flux');
    FeatureMappingNode.appendChild(BoundariesTypesNode);
end


for k = 1:length(all_membrane_VCML_data)
    object = all_membrane_VCML_data(k);
    i = object.i;
    j = object.j;
    pair_suffix = object.pair_suffix;
    area = object.area;
    
    start_obj = all_compartment_VCML_data(i);
    link_obj = all_compartment_VCML_data(j);
    
    MembraneMappingNode = docNode.createElement('MembraneMapping');
    MembraneMappingNode.setAttribute('Membrane',object.MembraneNodeName);
    MembraneMappingNode.setAttribute('GeometryClass',object.SurfaceClassNodeName);
    MembraneMappingNode.setAttribute('Size',num2str(area));
    MembraneMappingNode.setAttribute('AreaPerUnitArea',num2str(1));
    MembraneMappingNode.setAttribute('CalculateVoltage','false');
    MembraneMappingNode.setAttribute('SpecificCapacitance',num2str(1));
    MembraneMappingNode.setAttribute('InitialVoltage',num2str(0));
    GeometryContextNode.appendChild(MembraneMappingNode);
end


%%%
%%%Save the file

xmlwrite(savepath, docNode);
zip([savepath, '.zip'], savepath);

result = 1;
end




function wrapped_string = wrapString(string_data, wrap_width, newline_string)

if nargin < 2
    wrap_width = 72;
end
if nargin < 3
    newline_string = sprintf('\n');
end

wrapped_string = string_data;
wrapped_string_num_rows = ceil(length(wrapped_string) / wrap_width);
wrapped_string = [mat2cell(reshape(wrapped_string(1:(wrapped_string_num_rows - 1) * wrap_width), wrap_width, [])', ones(wrapped_string_num_rows - 1, 1)); {wrapped_string((wrapped_string_num_rows - 1) * wrap_width:end)}];
wrapped_string = strcat(wrapped_string, {newline_string});
wrapped_string = [wrapped_string{:}];

end
