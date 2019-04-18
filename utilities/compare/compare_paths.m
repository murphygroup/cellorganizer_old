function [answer] = compare_paths( path1, path2 )
% compare_paths
%
% This function compares two paths' file path and finds their difference. Its output is similar to diff tool.
%
% Input
% -----
% * Two paths
%
% Output
% ------
% * Comparing result
%
% Author: Xin Lu (xlu2@andrew.cmu.edu)
%
% Copyright (C) 2017 Murphy Lab
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get all file paths
[status1,r1_]= system(['find ' path1 ' -type f']);
[status2,r2_]= system(['find ' path2 ' -type f']);
r1=strsplit(r1_,'\n');
r2=strsplit(r2_,'\n');

r1(end)=[]; %%remove last empty one
r2(end)=[]; %%remove last empty one

%remove the prefix to the full paths
r1 = strrep(r1,path1,'.');
r2 = strrep(r2,path2,'.');

if isequal(r2,r1)
    answer=1;
    disp('They are the same');
    return
end

answer=0;

%find intersection set
% r1
% r2
ins=intersect(r1,r2);

% ins

%output
if ~isempty(ins)
    r1=deleteValues(r1,ins);
    r2=deleteValues(r2,ins);
    if ~isempty(r1)
        for i=1:numel(r1)
            disp(['> ',r1{i}]);
        end
    end
    if ~isempty(r2)
        for i=1:numel(r2)
            disp(['< ',r2{i}]);
        end
    end
else
    if ~isempty(r1)
        for i=1:numel(r1)
            disp(['> ',r1{i}]);
        end
    end
    if ~isempty(r2)
        for i=1:numel(r2)
            disp(['< ',r2{i}]);
        end
    end
end
end

function result=deleteValues(nodes,ins)
if ~isempty(ins)
    result=nodes;
end
for i=1:numel(ins)
    [truefalse, index] = ismember(ins{i},nodes);
    nodes(index)=[];
end
result=nodes;
end