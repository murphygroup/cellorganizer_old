function [ seg_dna, seg_cell ] = seg_cell_and_nucleus_2D(imdna, imcell, immask, options)

% Gregory Johnson
%
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

options = ml_initparam(options, ...
    struct('display', 0 ...
    ,'threshmeth_dna', 'nih' ...
    ,'threshmeth_prot', 'nih' ...
    ,'ml_objgaussmix', [] ...
    , 'dna_segment_method', 'guassian_smooth_thresh'));

if isempty(immask)
    immask = uint8(ones(size(imdna)));
end

%  xruan 01/06/2016 
% change segmentation method for imdna to make it smoother and better. 
if ~isempty(imdna)
    switch options.dna_segment_method 
        case 'guassian_smooth_thresh'
            procimg = ml_preprocess(double(imdna),immask,'ml','yesbgsub', options.threshmeth_dna);
            gray_img = mat2gray(double(imdna));
            gray_img = imfilter(gray_img, fspecial('gaussian', 13, 2));
            grey_thresh = graythresh(gray_img .* double(immask));
            procimg = (gray_img .* double(immask)) > grey_thresh;
            seg_dna = imfill(procimg>0,'hole');
        otherwise
            procimg = ml_preprocess(double(imdna),immask,'ml','yesbgsub', options.threshmeth_dna);
            seg_dna = imfill(procimg>0,'hole');
    end
end

if ~isempty( imcell )
    if length(unique(imcell(:))) > 2
        imcell = imcell.*immask;
        celledge = ml_imedge(imcell,[],'ce');
        cellbodyimg = imfill(celledge,'hole');
    else
        cellbodyimg = imcell;
    end
        
    seg_cell = ml_findmainobj(cellbodyimg);
    
    %update the mask
    immask = seg_cell.*double(immask>0);
else
    seg_cell = [];
end

seg_dna = ml_findmainobj(seg_dna.*double(immask>0));
end

