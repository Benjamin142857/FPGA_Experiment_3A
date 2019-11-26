% CmlStartup
%
% Initializes the Coded Modulation Library
%
% Last updated June 29, 2006

% determine the version of matlab version
version_text = version;
if ( str2num( version_text(1) ) > 6)
    save_flag = '-v6';
else
    save_flag = '-mat';
end

% determine the home directory
cml_home = pwd;

if ispc
    % setup the path
    addpath( strcat( cml_home, '\mex'), ...
        strcat( cml_home, '\mat'), ...
        strcat( cml_home, '\mexhelp'), ...
        strcat( cml_home, '\scenarios'), ...
        strcat( cml_home, '\data\bandwidth') );

    % if CML grid is installed
    if exist( '.\cml\mat' )
        addpath( strcat( cml_home, '\grid\mat' ) );
    end

    % save the home directory
    save_directory = strcat( cml_home, '\scenarios\CmlHome.mat' );
else
    % setup the path
    addpath( strcat( cml_home, '/mex'), ...
        strcat( cml_home, '/mat'), ...
        strcat( cml_home, '/mexhelp'), ...
        strcat( cml_home, '/scenarios'), ...
        strcat( cml_home, '/data/bandwidth') );

    % if CML grid is installed
    if exist( './cml/mat' )
        addpath( strcat( cml_home, '/grid/mat' ) );
    end

    % save the home directory
    save_directory = strcat( cml_home, '/scenarios/CmlHome.mat' );
end

save( save_directory, save_flag, 'cml_home' );
savepath;
