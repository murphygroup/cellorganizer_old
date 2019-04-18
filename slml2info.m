function answer = slml2info( varargin )
% SLML2INFO Generate a report from information extracted from a genearative model file
%
% List Of Input Arguments  Descriptions
% -----------------------  ------------
% filenames                List of files
% options                  Options structure
%
% Example
% > filenames = {'/path/to/model/file/model.mat'};
% > answer = slml2info( filenames );

% Author: Ivan E. Cao-Berg, Xin Lu

% Copyright (C) 2019 Murphy Lab
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

answer = false;

if isdeployed()
  if length(varargin) == 1
      text_file = varargin{1};
  else
      error('Deployed function takes only 1 argument. Exiting method.');
      return
  end

  [filepath, name, ext] = fileparts(text_file);

  if ~exist(text_file, 'file')
      warning('Input file does not exist. Exiting method.');
      return
  end

  disp(['Attempting to read input file ' text_file]);
  fid = fopen(text_file, 'r' );

  disp('Evaluating lines from input file');
  while ~feof(fid)
      line = fgets(fid);
      eval(line);
  end
  fclose(fid);
  if ~exist('options', 'var')
	   options = {};
  end
else
    if length(varargin) == 1
        files = varargin{1};
        options = {};
    elseif length(varargin) == 2
        files = varargin{1};
        options = varargin{2};
    else
        warning('Not the right number of input arguments');
        return
    end

end

if ~iscell( files )
    warning('Input argument files must be a cell-array')
    return
end

if length(files) == 1
    filename = files{1};
else
    for i=1:length(files)
        load(files{i});
        if ~is_tcell_model(model)
            warning('SLML2INFO only takes in 1 file for this model!')
            return
        end
    end
end



if ~isdeployed() && nargin == 1
    options.output_directory = pwd;
end

if ~isfield( options, 'output_directory' )
    options.output_directory = pwd;
end

if ~exist( options.output_directory )
    mkdir( options.output_directory )
end

if isdeployed()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% RUNNING DEPLOYED %%%%%%%%%%%%%%%%%%%%%%%%
    disp('Running Deployed Version of SLML2INFO')
    if exist([ options.output_directory filesep 'index.md' ], 'file')
        delete([ options.output_directory filesep 'index.md' ] )
    end

    fileID = fopen( [ options.output_directory filesep 'index.md' ], 'w' );
    fprintf(fileID,'# slml2info output\n');

    if ~exist([pwd filesep 'report'], 'dir')
        mkdir([pwd filesep 'report']);
    else
        rmdir([pwd filesep 'report'], 's' );
        mkdir([pwd filesep 'report']);
    end

    if exist( 'filename', 'var' )
        if exist(filename, 'file')
            load( filename );
            fprintf( fileID,'%%%%%% Filename\n' );
            fprintf( fileID, ['%%' filename '\n'] );
        else
            disp(['Filename ' filename ' does not exist.']);
            answer = false;
            return
        end
        %when filename exists and files == 1
        model.model_filename=filename;
        model2info_running_when_deployed( model, fileID, options );
    else
        % when files > 1 and filename ! exist
        filename=files{1};
        load( filename );
        fprintf( fileID,'%%%%%% Filename\n' );
        fprintf( fileID, ['%%' filename '\n'] );
        model.model_filename=files;
        model2info_running_when_deployed( model, fileID, options );
    end

    fclose(fileID);
    system(['pandoc ' options.output_directory filesep 'index.md -o index.html' ]);

    if exist([pwd filesep 'index.html'], 'file')
        movefile([pwd filesep 'index.html'],[pwd filesep 'report']);
    end

    if exist('./index.md', 'file')
        delete( './index.md' );
    end
    if exist('./html', 'dir')
        rmdir('./html', 's');
    end
    answer = true;
else
    %%%%%%%%%%%%%%%%%%%%%%%%% RUNNING ON MATLAB ENGINE %%%%%%%%%%%%%%%%%%%%
    if exist( [ options.output_directory filesep 'index.m' ] )
        delete([ options.output_directory filesep 'index.m' ] )
    end

    fileID = fopen( [ options.output_directory filesep 'index.m' ], 'w' );
    fprintf(fileID,'%%%% slml2info output\n');

    if exist( 'filename', 'var' )
        if exist( filename )
            load( filename );
            fprintf( fileID,'%%%%%% Filename\n' );
            fprintf( fileID, ['''' filename '''' ';\n\n'] );
        else
            disp(['Filename ' filename ' does not exist.']);
            answer = false;
            return
        end
        %when filename exists and files == 1
        model.model_filename=filename;
        model2info_running_on_matlab_engine( model, fileID, options );
    else
        % when files > 1 and filename ! exist
        filename=files{1};
        load( filename );
        fprintf( fileID,'%%%%%% Filename\n' );
        fprintf( fileID, ['%%' filename '\n'] );
        model.model_filename=files;
        model2info_running_on_matlab_engine( model, fileID, options );
    end

    fclose(fileID);
    publish([ options.output_directory filesep 'index.m' ]);

    if exist( './html' )
        if exist( './report' )
            rmdir( './report', 's' );
        end
        movefile( './html', './report' );
    end

    % if exist( './index.m' )
    %     delete( './index.m' );
    % end
    answer = true;
end
end%slml2info
