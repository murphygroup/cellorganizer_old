function [combcodes,combclass,combcellidx] = ...
    tz_parsecell2_mcf(imgdir,savedir)
%TZ_PARSECELL2_MCF Parse cells for mcf images.
%   COMBCODES = TZ_PARSECELL2_MCF(IMGDIR,SAVEDIR) returns a cell array of
%   cell codes for images under directory IMGDIR, which has MCF structure.
%   The results will also be saved in SAVEDIR, which is a subdirectory in
%   IMGDIR.
%   
%   [COMBCODES,COMBCLASS,COMBCELLIDX] = TZ_PARSECELL2_MCF(...) also returns
%   the class labels and cell indices.
%   
%   See also TZ_PARSECELL

%   08-Apr-2005 Initial write  T. Zhao
%   Copyright (c) Murphy Lab, Carnegie Mellon University

% Copyright (C) 2007  Murphy Lab
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

if nargin < 2
    error('Exactly 2 arguments are required')
end

combcodes={};
combclass=[];
combcellidx=[];

files=dir(imgdir);
classes={};
for i=1:length(files)
    if isdir([imgdir '/' files(i).name]) & files(i).name(1)~='.'
        classes={classes{:},files(i).name};
    end
end
channels={'prot','dna','cell'};
imgsize=[1024,1024];
for pi=1:length(classes)
    if strcmp(classes{pi},'DNA')
        continue;
    end
    
    patterndir=[imgdir '/' classes{pi}];
    protdir=[patterndir '/' channels{1}];
   
    cellbodydir=[patterndir '/cellbody'];
    nucbodydir=[patterndir '/nucbody'];
    prots=dir([protdir '/*.mat']);
    
    fullsavedir=[patterndir '/' savedir];
    
    if ~exist(fullsavedir,'dir')
        mkdir(patterndir,savedir);
    end
        
    for ci=1:length(prots)
        [pi ci]
        [tmp,dpos]=find(prots(ci).name=='_');
        cellname=prots(ci).name(1:dpos-1);
        savefile=[fullsavedir '/' cellname '.mat'];
        
        if exist(savefile,'file')
            cellcode=load(savefile);
        else
            cellcode={};
        end

        load([cellbodydir '/' cellname '_cell.mat']);
        load([nucbodydir '/' cellname '_dna.mat']);         
            
        cellcode=ml_parsecell(cellcode,cellbody,nucbody,1,imgsize,...
            {'da','nucarea','nuccenter','nucmangle','nuchitpts',...
                'nuccontour','nucellhitpts','nucdist','nucelldist','nucecc',...
                'cellarea','cellcenter','cellmangle','cellcontour',...
                'cellhitpts','celldist','cellecc'},0);
        cellcode.script = ['tz_parsecell2_mcf(''' imgdir ''',''' savedir ...
                ''')'];
        ml_savestruct(savefile,cellcode);
        
        combcodes={combcodes{:},cellcode};
        combclass=[combclass;pi];
        combcellidx=[combcellidx;ci];
    end
end
