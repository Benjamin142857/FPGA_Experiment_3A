%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DSP Builder (Version 11.1)
% Quartus II development tool and MATLAB/Simulink Interface
%
% Copyright ?2007-2009 Altera Corporation. All rights reserved.
%
% Your  use of Altera Corporation's  design tools, logic functions  and other software
% and  tools, and its  AMPP partner logic  functions, and any  output files any of the
% foregoing  (including  device  programming or  simulation files), and any associated
% documentation  or information are  expressly  subject to the terms and conditions of
% the Altera  Program License Subscription Agreement, Altera MegaCore Function License
% Agreement, or  other  applicable  license  agreement, including, without limitation,
% that your use is for the sole  purpose of programming logic  devices manufactured by
% Altera  and sold by  Altera or  its  authorized  distributors. Please  refer to  the
% applicable agreement for further details.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: //acds/rel/13.1/dsp_builder/dsp_builder2/SimulinkBlocks/src/matlab/setupDSPBuilderPath.m#1 $
%
% This will set up the MATLAB path so that the DLLs and MATLAB scripts
% are runnable.
%
% Given no parameters it uses the current directory as the MATLAB directory

function setupDSPBuilderPath(setupType, priv, varargin)

if nargin < 2
	error('The first parameter to setupDSPBuilderPath should be buildmachine, install or development. Second argument should be true or false');
end

assert(islogical(priv) && isscalar(priv), 'Second argument should be true or false');

warning('off','Simulink:ShadowedModelName');
warning('off','Simulink:Engine:MdlFileShadowing')

try

	if nargin == 2 
	    % get dspb dir from dspb matlab script dir
	    % (QUARTUS_ROOTDIR\dsp_builder\bin\matlab)
	    basedir = fileparts(fileparts(fileparts(...
		which('setupDSPBuilderPath'))));
	else
	    basedir = varargin{1};
	end

	if strcmp(mexext, 'mexa64')
		binname = 'bin64';
	elseif strcmp(mexext, 'mexw64')
		binname = 'bin64';
	else
		binname = 'bin';
	end
	bindir = fullfile(basedir, binname);
	pathlist = {bindir ...
		fullfile(bindir, 'matlab') fullfile(bindir, 'mdllibrary')};
	
	fprintf('Install type is %s\n', setupType);
	
	% Get the Matlab release version, and based on that add the correct DLLs to the Matlab path
	
	% bindir should be QUARTUS_ROOTDIR\dsp_builder\bin
	% either this was passed in as an argument from Eclipse install script
	% or it was found by which 'setupDSPBuilderPath' (above) for installer flow
	
	switch setupType
		case 'buildmachine'
			convertFiles = true;
			createLibrary = true;
			createSearch = true;
		case 'install'
			convertFiles = false;
			createLibrary = false;
			createSearch = false;
		case 'development'
			createSearch = true;
			convertFiles = false;
			createLibrary = true;
		otherwise
			error('The first parameter to setupDSPBuilderPath should be buildmachine, install or development. Got %s', ...
				setupType);
	end
	
	currentfcn = 'setupDSPBuilderPath.m';

	for p=pathlist
		dir = char(p);
        if priv
		    fprintf('Adding path : %s\n', dir);
    	    addpath(dir);
        end
	    if convertFiles
	        currentFile = which(currentfcn);
	        fprintf('Converting m-scripts in %s to pcode.\n', dir);
			mFiles = getFilesWithoutCurrentFile(dir, currentFile);
	    	privateDir = fullfile(dir, 'private');
	        if ~isempty(mFiles)
	            if exist(privateDir, 'dir')
	                privateMFiles = getFilesWithoutCurrentFile(privateDir, currentFile);
	                pcode('-inplace', mFiles{:}, privateMFiles{:});
	                delete(mFiles{:}, privateMFiles{:});
	            else
	                pcode('-inplace', mFiles{:});
	                delete(mFiles{:});
	            end
	        end
	    end
	end
	
	if createLibrary
	    fprintf('Creating the main library\n');
		alt_dspbuilder_createLibrary(fullfile(bindir, 'mdllibrary'));
	end
	
	fprintf('Creating board components\n');
	alt_dspbuilder_createComponentLibrary;
	
	fprintf('Creating megacores\n');
	alt_dspbuilder_setup_megacore;

    if ispc
        alt_dspbuilder_internal_createDSPBuilderLauncher;
    end
	
	if createSearch
		fprintf('Creating search files\n');
		DSPBDir = fileparts(bindir);
		create_search(DSPBDir);
	end
	
    if priv
		% clear up old path entries when run in priv mode - this should only affect the windows installer
		remove_old_paths;
        fprintf('\nMATLAB path reset.\n\n');
    end

	% this line tells the running ant script that DSP Builder succeeded
	fprintf('DSPBuilder Library Created\n');
catch err
   fprintf('\nInformation on the last error:\n\n')
   fprintf('Message: %s\n\n', err.message)
   fprintf('Failed at\n')

   for errst=err.stack'
       fprintf('  %s in %s at line %d\n', errst.name, errst.file, errst.line)
   end
end

function files = getFilesWithoutCurrentFile(directory, currentFile)

files = dir(fullfile(directory, '*.m'));
files = {files.name};
files = setdiff(files, {'slblocks.m', 'Contents.m'});
files = cellfun(@(x) fullfile(directory, x), files, 'UniformOutput', false);
files = setdiff(files, currentFile);

function remove_old_paths

plist = pathdef;
if ~iscell(plist)
    p = textscan(plist, '%s', 'Delimiter', ';');
    p = p{1};
else
    p = plist;
end

searchPattern = '(quartus[\\/](dspba|sopc_builder|dsp_builder))';
indices = regexp(p, searchPattern);
if nargin < 2 || isempty(current_root)
    current_indices = cell(size(indices));
else
    if ispc
        % on windows we could have a mix of back and forward slashes so convert them all to the same thing before
        % comparing. (We retain the unaltered forms though because when we remove the paths later we need to exactly
        % match).
        current_indices = strfind(strrep(p, '/', '\'), strrep(current_root, '/', '\'));
    else
        current_indices = strfind(p, current_root);
    end
end

% find all matching paths excluding ones using the current_root if there is one
matches = cellfun(@(x, y) ~isempty(x) && isempty(y), indices, current_indices);

% convert the path into a single string with the paths separated by pathsep
good_paths = p(~matches);
good_paths(:, 2) = {pathsep};
good_paths = good_paths';

% reset the path
path([good_paths{:}]);

pdf = which('pathdef');

% try at least 10 times to make a backup of the pathdef.m file
for n=1:10
	copy_pdf = sprintf('%s.backup.%d', pdf, n);
	if exist(copy_pdf, 'file') == 0
		success = copyfile(pdf, copy_pdf);
		if success
			break
		end
	end
end

savepath

