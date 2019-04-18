function answer = isMexFile( file )
%ISMEXFILE True iff file exists and is an mex-file, false otherwise.

% Author: Ivan E. Cao-Berg (icaoberg@cmu.edu)
% Created: May 8, 2007
% Last Update: March 19, 2008
%
% Copyright (C) 2008 Center for Bioimage Informatics/Murphy Lab
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

if( nargin == 1 )
    if isaFile( file ) && strcmpi( getFileExtension( file ), 'mex' )
        answer = true;
    else
        answer = false;
    end
else
    error( 'CellOrganizer: Wrong number of input arguments' );
end
end%isMexFile