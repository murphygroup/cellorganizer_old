function [answer] = compare_structures(varargin)
% compare_structures
%
% This function compares two structures and finds their difference. Its output is similar to diff tool.
%
% Input 
% -----
% * Two structures
%
% Output
% ------
% * Comparing result
%
%
% For example:
% A1.b = 1
% A1.c = 2
%
% A2.d = 3
% A2.c = 3
%
% These structures are different because:
% b is present in A1 and not in A2
% d is present in A2 and not in A1
% c has different values in A1 and A2
%
% answer = compare_structures( A1, A2 )
%
% prints
% > b
% < d
% != c
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

	narginchk(2,3);
	if length(varargin) == 2     
	    a=varargin{1};     
	    b=varargin{2};    
	    [answer]=cp1(a,b);
	else    
	    a=varargin{1};   
	    b=varargin{2};
	    options=varargin{3};
	    doc_f=options.ignore_documentation;
	    if isequal(doc_f,'false')
	    	[answer]=cp1(a,b);
	    else
	    	[answer]=cp2(a,b);
	    end
	end
end

function [answer]=cp1(a,b)

	if isequal(a,b)
        answer=1;
		disp('They are the same.');
        return
    end
    answer=0;
    %list all leaves
	a_all_nodes=getAllNodes(a,'a');
	b_all_nodes=getAllNodes(b,'b');

	%remove the front 'a.'
	for i=1:numel(a_all_nodes)
    	a_all_nodes_{i}=a_all_nodes{i}(3:end);
    end
    for i=1:numel(b_all_nodes)
    	b_all_nodes_{i}=b_all_nodes{i}(3:end);
    end

    %find intersection set
    ins=intersect(a_all_nodes_,b_all_nodes_);

    %delete intersection set
    a_all_nodes_d=deleteValues(a_all_nodes_,ins);
    b_all_nodes_d=deleteValues(b_all_nodes_,ins);

    %output
    if ~isempty(a_all_nodes_d)
	    for i=1:numel(a_all_nodes_d)
	    	disp(['> ',a_all_nodes_d{i}]);
	    end
	end
    if ~isempty(b_all_nodes_d)
	    for i=1:numel(b_all_nodes_d)
	    	disp(['< ',b_all_nodes_d{i}]);
	    end
	end

    if ~isempty(ins)
	    for i=1:numel(ins)
	    	if ~isequal(getValue(a,ins{i}),getValue(b,ins{i}))
	    		disp(['!= ',ins{i}]);
	    	end
	    end
	end
end


function [answer]=cp2(a,b)

	%list all leaves
	a_all_nodes=getAllNodes_rm_doc(a,'a');
	b_all_nodes=getAllNodes_rm_doc(b,'b');

	%remove the front 'a.' and 'b.'
	for i=1:numel(a_all_nodes)
    	a_all_nodes_{i}=a_all_nodes{i}(3:end);
    end
    for i=1:numel(b_all_nodes)
    	b_all_nodes_{i}=b_all_nodes{i}(3:end);
    end

    %check equality
	if isequal(a_all_nodes_,b_all_nodes_)
        answer=1;
		disp('They are the same.');
        return
    end
    answer=0;
    
    %find intersection set
    ins=intersect(a_all_nodes_,b_all_nodes_);

    %delete intersection set
    a_all_nodes_d=deleteValues(a_all_nodes_,ins);
    b_all_nodes_d=deleteValues(b_all_nodes_,ins);

    %output
    if ~isempty(a_all_nodes_d)
	    for i=1:numel(a_all_nodes_d)
	    	disp(['> ',a_all_nodes_d{i}]);
	    end
	end
    if ~isempty(b_all_nodes_d)
	    for i=1:numel(b_all_nodes_d)
	    	disp(['< ',b_all_nodes_d{i}]);
	    end
	end

    if ~isempty(ins)
	    for i=1:numel(ins)
	    	if ~isequal(getValue(a,ins{i}),getValue(b,ins{i}))
	    		disp(['!= ',ins{i}]);
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

function result=getValue(stru,s)
	nodes=strsplit(s,'.');
	ss=stru;
	for i=1:numel(nodes)
		result=ss.(nodes{i});
		ss=ss.(nodes{i});
	end

end

function result=getAllNodes(stru,cur_father)
	all_={};
	struf=fieldnames(stru);
	for i=1:numel(struf)
		fieldi=stru.(struf{i});
		if ~isstruct(fieldi)
			all_=[all_,strcat(cur_father,'.',struf{i})];
        else
			all_=[all_,getAllNodes(fieldi,strcat(cur_father,'.',struf{i}))];
		end
    end
	result=all_;
end

function result=getAllNodes_rm_doc(stru,cur_father)
	all_={};
	struf=fieldnames(stru);
	for i=1:numel(struf)
		if struf{i}=='documentation'
			stru=rmfield(stru,'documentation');
		else
			fieldi=stru.(struf{i});
			if ~isstruct(fieldi)
				all_=[all_,strcat(cur_father,'.',struf{i})];
	        else
				all_=[all_,getAllNodes(fieldi,strcat(cur_father,'.',struf{i}))];
			end
		end
    end
	result=all_;
end




