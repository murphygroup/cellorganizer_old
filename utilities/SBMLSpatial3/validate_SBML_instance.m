function answer = validate_SBML_instance( filename )

% Author: Ivan E. Cao-Berg
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

apikey='d40d197d-dee1-4275-baf8-44d6016915e2';
command = ['curl -F file=@' filename ' -F output=xml -F offcheck=u,r -F apikey=' ...
    apikey ' http://sbml.org/validator/'];
[status,result] = system(command);

disp( result );