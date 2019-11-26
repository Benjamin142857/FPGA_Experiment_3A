function setup_dsp_builder

% DSPB configuration script for MATLAB
dsp_builder_dir = getenv('DSP_BUILDER_ROOT');

if strcmp(mexext, 'mexa64')
	bin_dir = fullfile(dsp_builder_dir, 'bin64');
elseif strcmp(mexext, 'mexw64')
	bin_dir = fullfile(dsp_builder_dir, 'bin64');
else
	bin_dir = fullfile(dsp_builder_dir, 'bin');
end

if exist(bin_dir, 'dir') ~= 0
    if ~ispc
        % validate that LD_LIBRARY_PATH points to quartus/dsp_builder/bin
        library_path = textscan(getenv('LD_LIBRARY_PATH'), '%s', 'delimiter', ':');
        valid = ismember(bin_dir, library_path{1});
        if ~valid
            fprintf('Cannot set up DSP Builder. LD_LIBRARY_PATH must point to ''%s''\n', bin_dir);
        end
    else
        valid = true;
    end
    
    if valid
        addpath(bin_dir);
        addpath(fullfile(bin_dir, 'matlab'));
        addpath(fullfile(bin_dir, 'mdllibrary'));

        javaaddpath(fullfile(bin_dir, 'dspb_sblocks.jar'));
    else
    end
else
    fprintf('Cannot set up DSP Builder. DSP_BUILDER_ROOT/bin points to ''%s'', which doesn''t exist', bin_dir);
end
