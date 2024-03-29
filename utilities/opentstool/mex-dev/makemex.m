function makemex(TSTOOLpath)

% compile and copy mex-files to destination directories
% Invoked by : makemex(TSTOOLpath)
% or:          makemex

if nargin==0
   if isempty(which('units.mat'))
	   error('Cant find TSTOOL! Please specify tstool-path by calling makemex(TSTOOLpath).');
   else
      [TSTOOLpath,dummy,dummy,dummy]=fileparts(which('units.mat'));
   end
end


olddir = pwd;

if isunix
	[dummy, system] = unix('/bin/uname');
	switch system(1:end-1)
		case 'IRIX64'
			suffix = '.mexsg64';
		case 'IRIX'
			suffix = '.mexsg';
		case 'SunOS'
			suffix = '.mexsol';
		otherwise
			if exist('mexext')==5
				suffix = ['.' mexext];
			else
				error('Unknown system type.');
			end
	end
else
    system = 'WIN';
    suffix = '.dll';
end

destpath = fullfile(fullfile(TSTOOLpath, 'mex'), mexext);

clear functions;		% prevent locked files

disp('Building mex files for TSTOOL')
disp('')
disp(['System : ' system])
disp(['Suffix : ' suffix])
disp(['Destination : ' destpath])
disp('')
disp('')

try
	cd TernarySearchTree/BoxCounting

	files = {'boxcount'};
	make(files, suffix, '-O -I.. -I../..  ', destpath);

	cd(olddir)

	cd TernarySearchTree/MutualInformation

	files = {'amutual'};
	make(files, suffix, '-O -I.. -I../..  ', destpath);

	cd(olddir)

	cd NN

	files = {'corrsum', 'corrsum2', 'crosscorrsum', 'fnearneigh', ...
	'largelyap', 'predict',  'predict2', 'cao', ...
	'takens_estimator', 'return_time', 'nn_prepare', ...
	'nn_search', 'range_search', 'crossprediction', ...
	'emb_nn_search'};	

	make(files, suffix, ' -O -I. -I.. -DPARTIAL_SEARCH ', destpath);

	cd(olddir)

	cd Polynomauswahl

	files = {'mlist'};
	make(files, suffix, '-I.. -O', destpath);

	cd(olddir)

	cd GeneralizedDimensionEstimation

	files = {'gendimest'};
	make(files, suffix, '-I.. -O', destpath);

	cd(olddir)

	cd Psychoacoustics

	files = {'movav', 'level_adaption'};
	make(files, suffix, '-O', destpath);

	cd(olddir)

	cd Systems/ChaoticSystems

	files = {'chaosys'};
	make(files, suffix, '-O', destpath);

	cd(olddir)

	cd Systems/IteratedMaps/

	files = {'henon', 'baker', 'tentmap'};
	make(files, suffix, '-O', destpath);

	cd(olddir)


	cd Utils
	files = {'loadascii', 'mtrand', 'randref', 'mixembed'};
	make(files, suffix, '-O -I..', destpath);
	
	cd(olddir)
catch
	warning(lasterr)
	cd(olddir)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function flag = newer(filename1, filename2)

% flag = newer(filename, reffile)
% returns true if first file is newer than second file

try
	d = dir(filename1);
	d2 = dir(filename2);

	if isempty(d2)
		flag = 1;
		return
	end
	if isempty(d)
		flag = 0;
		warning(['Source file ' filename1 ' does not exist']);
		return
	end

	% datenum(d.date)
	% datenum(d2.date)

	if (datenum(d.date) > datenum(d2.date))
    	flag = 1;
	else
    	flag = 0;
	end
catch
	flag = 1;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function make(filenames, suffix, mexoptions, destpath)

% make(filenames, suffix, mexoptions, destpath)
%
% filenames is a cell array of filenames

for i=1:length(filenames)
	filename = filenames{i};
	destfile = fullfile(destpath, [filename suffix]);

	if newer([filename '.cpp'], [filename suffix])
		disp(['Making ' filename])

		try
			eval(['mex ' filename '.cpp ' mexoptions ' -v']);
		catch
			warning(lasterr)
		end
	else
		disp([filename ' is up to date'])
	end

	if newer([filename suffix], destfile)
		disp(['Copying ' filename])
		try
			copyfile([filename suffix], destfile);
		catch
			warning(lasterr)
		end
	end
end

