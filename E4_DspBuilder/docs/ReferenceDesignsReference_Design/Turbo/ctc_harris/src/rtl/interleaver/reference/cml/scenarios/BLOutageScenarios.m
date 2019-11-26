% File UncodedScenarios
%
% This is a set of scenarios for the Coded Modulation Library.
%
% The simulations specified in this file are for uncoded modulation.
%
% Last updated on July 4, 2006

% determine where your root directory is
load( 'CmlHome.mat' );

% determine where to store your files
base_name = 'bloutage';
if ispc
    data_directory = strcat( cml_home, '\output\', base_name, '\' );
else
    data_directory = strcat( cml_home, '/output/', base_name, '/' );
end
if ~exist( data_directory, 'dir' )
    mkdir(data_directory);
end

% uncoded modulation in AWGN
record = 1;
sim_param(record).comment = 'Outage Probability to 150 bit TC';
sim_param(record).sim_type = 'bloutage';
sim_param(record).SNR = [-2:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 150;
sim_param(record).rate = 150/462;
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).linetype = 'b:';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'BPSK_AWGN_462_r1by3.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minFER = 1e-5; 
sim_param(record).max_frame_errors = 300*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 3000;

record = 2;
sim_param(record).comment = 'Outage Probility for 360 bit TC';
sim_param(record).sim_type = 'bloutage';
sim_param(record).SNR = [-2:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 360;
sim_param(record).rate = 360/1092;
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).linetype = 'r:';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'BPSK_AWGN_1092_r1by3.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minFER = 1e-5; 
sim_param(record).max_frame_errors = 300*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 3000;

% To add a new record, cut and paste one of the above records.
% Change record number to be one higher than the last used.
% Modify parameters as desired.
%
% Important: Each record must have a unique filename.  It is recommended
% that for each new record you set
% sim_param(record).filename = strcat( data_directory, base_name, int2str(record), '.mat' );
