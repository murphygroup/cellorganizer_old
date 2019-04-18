function setup( force )
%SETUP Helper method that loads CellOrganizer into workspace if toolbox is
%compatible. If force flag is set to true, then it will load CellOrganizer
%even if system is not compatible.

% Author: Ivan E. Cao-Berg (icaoberg@cmu.edu)
% Created: November 24, 2008
%
% Copyright (C) 2008-2018 Murphy Lab
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

% March 14, 2012 icaoberg Made it sure that .git folder is not added to
%                path just in case they use the git clone
%
% March 19, 2012 murphy Fix addpaths
%
% March 27, 2012 icaoberg Turned script into function
%
% April 11, 2012 murphy Support two digit sub- and sub-subversions
%
% October 2, 2012 icaoberg Ignore licenses folder from working path
%
% May 7, 2013 icaoberg Updated method to include loading of Bio-formats
%
% March 11, 2013 icaoberg Updated method so that removes the paths if
% CellOrganizer is not compatible
%
% February 3, 2015 icaoberg Added force flag that will load
% CellOrganizer even if system is not compatible
%
% February 10, 2015 icaoberg Suppressed naming conflict warning
%
% March 1, 2018 icaoberg Enabled logging for BioFormats

%icaoberg 2/3/2015
if ~exist( 'force', 'var' )
    force = false;
end

addpath( pwd );

%icaoberg 10/2/2015
addpath(genpath( [pwd filesep 'utilities']));
addpath(genpath( [pwd filesep 'models']));
addpath(genpath( [pwd filesep 'demos']));
addpath([pwd filesep 'images']);

%icaoberg 2/3/2015
if ~is_it_compatible_with_cellorganizer()
    if force
        warning( ['CellOrganizer: The current system is not ' ...
            'compatible but allowing to test because force flag ' ...
            'was set to true.'] );
    else
        rmpath(genpath( [pwd filesep 'utilities']));
        rmpath(genpath( [pwd filesep 'models']));
        rmpath(genpath( [pwd filesep 'demos']));
        error( ['CellOrganizer: The current system is not ' ...
            'compatible.'] );
    end
end

version = '2.8.0';
versionURL = 'http://murphylab.web.cmu.edu/software/CellOrganizer/version';

try
    fprintf( 1, '%s', 'Checking for updates. ' );
    latestVersion = urlread( versionURL );
    if latestVersion(end) == 10
        latestVersion = latestVersion(1:end-1);
    end
    
    if upgrade( version, latestVersion )
        disp(['A newer version (CellOrganizer v' latestVersion ') is available online. Please visit www.cellorganizer.org to download the latest stable release.']);
    else
        disp(['CellOrganizer version ' num2str(version) ' is the latest stable release.']);
    end
catch
    disp('Unable to connect to server. Please try again later.');
end

javaaddpath( [ pwd filesep ...
    'utilities' filesep 'bfmatlab' filesep 'bioformats_package.jar'] );

%enable logging
loci.common.DebugTools.enableLogging('INFO');
end%setup

function answer = upgrade( version, latestVersion )
version = sscanf(version, '%d.%d.%d')';
if length(version) < 3
    version(3) = 0;
end

latestVersion = sscanf(latestVersion, '%d.%d.%d')';
if length(latestVersion) < 3
    latestVersion(3) = 0;
end

answer = (sign(version - latestVersion) * [10; .1; .001]) < 0;
end%upgrade
