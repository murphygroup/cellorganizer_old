function syn2surfaceplot( directory, colors, viewangles, alphaval )
% IMG2PLOT Helper method that displays images generated by CellOrganizer
%
% List Of Input Arguments   Descriptions
% -----------------------   ------------
% directory                 a directory containing images from CellOrganizer
% colors                    a cell array containing a list of valid colors as defined by Matlab
%                           http://www.mathworks.com/help/techdoc/ref/colorspec.html
% viewangles                a vector defining the viewing angle as defined by Matlab
%                           http://www.mathworks.com/help/techdoc/ref/view.html
% alphaval                  a value that determines the transparency of an object
%                           http://www.mathworks.com/help/techdoc/ref/alpha.html

% Ivan E. Cao-Berg
%
% Copyright (C) 2012-2106 Murphy Lab
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

% Author: Ivan E. Cao-Berg (icaoberg@scs.cmu.edu)
% July 21, 2012 R.F. Murphy Added arguments to control colors, viewangles,
% alpha
% August 10, 2012 I. Cao-Berg Updated docs and renamed method

%step 1: check input arguments
if ~isa( directory, 'char' )
    error( 'Input argument directory must be a string' )
end

if ~exist( directory, 'dir' )
    error( 'Input argument directory must exist' )
end

if ~exist( 'colors', 'var')
    colors = {'yellow','blue','green','magenta','cyan','red'};
end

if ~exist( 'viewangles', 'var')
    viewangles = [50,-15];
end

if ~exist( 'alphaval', 'var')
    alphaval = 0.1;
end

files = ml_dir([directory filesep '*.tif']);
if isempty( files )
    warning('No files were found in directory. Exiting method' );
end


try
    clf
    for i=1:1:length(files)
        img = tif2img([directory filesep files{i}]);
        p = patch( isosurface(img) );
        set( p, 'FaceColor', colors{mod(i-1,length(colors))+1}, 'EdgeColor', 'none' );
        view(viewangles(1),viewangles(2));
        hold on
    end
    
    alpha(alphaval);
    daspect([1 1 1]);
    axis off
    hold off
catch
    warning('Unable to display images.')
end
