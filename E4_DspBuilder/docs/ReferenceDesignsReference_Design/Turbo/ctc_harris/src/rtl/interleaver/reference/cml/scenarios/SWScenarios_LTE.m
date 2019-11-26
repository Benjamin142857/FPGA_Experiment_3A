% File LTEScenarios
%
% This is a set of scenarios for the Coded Modulation Library.
%
% The simulations specified in this file are for the turbo code
% used by the LTE standard
%
% Last updated on July 4, 2006

% determine where your root directory is
load( 'CmlHome.mat' );

% determine where to store your files
base_name = 'LTE';
if ispc
    data_directory = strcat( cml_home, '\output\', base_name, '\' );
else
    data_directory = strcat( cml_home, '/output/', base_name, '/' );
end
if ~exist( data_directory, 'dir' )
    mkdir(data_directory);
end

% AWGN
record = 1;
sim_param(record).comment = '544 bits, SW-logMAP, 8/32';
sim_param(record).SNR = 1:0.25:2.0;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).fxp_data_width = [7 2 9 2];
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1;    1 1];
sim_param(record).pun_pattern2= [0 0;    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 2;
sim_param(record).comment = '544 bits, SW-logMAP, 8/32';
sim_param(record).SNR = 1.0:0.25:2.0;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).fxp_data_width = [5 1 8 2];
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1;    1 1];
sim_param(record).pun_pattern2= [0 0;    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 3;
sim_param(record).comment = '544 bits, SW-logMAP, 8/16';
sim_param(record).SNR = 0.0:0.25:2.0;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 16;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1;    1 1];
sim_param(record).pun_pattern2= [0 0;    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 4;
sim_param(record).comment = '544 bits, SW-logMAP, 8/64';
sim_param(record).SNR = 0.0:0.25:2.0;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 64;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1;    1 1];
sim_param(record).pun_pattern2= [0 0;    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 5;
sim_param(record).comment = '544 bits, SW-logMAP, 16/32';
sim_param(record).SNR = 0.0:0.25:2.0;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 16;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1;    1 1];
sim_param(record).pun_pattern2= [0 0;    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 6;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 190 bits, log-MAP';
sim_param(record).SNR = 0:0.25:3.25;
sim_param(record).framesize = 190;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).max_iterations = 9;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'k:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-7; 
sim_param(record).max_frame_errors = 200*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 7;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 544 bits, max-log-MAP';
sim_param(record).SNR = 0:0.2:2.2;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 1;
sim_param(record).max_iterations = 10;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1000001*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 8;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 544 bits, constant-log-MAP';
sim_param(record).SNR = 0:0.2:2.2;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 2;
sim_param(record).max_iterations = 10;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'b:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 9;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 544 bits, log-MAP';
sim_param(record).SNR = 0:0.2:2.2;
sim_param(record).framesize = 544;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).max_iterations = 10;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'k:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 10;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 640 bits, max-log-MAP';
sim_param(record).SNR = 0:0.2:2;
sim_param(record).framesize = 640;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 1;
sim_param(record).max_iterations = 10;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 11;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 640 bits, constant-log-MAP';
sim_param(record).SNR = 0:0.2:2;
sim_param(record).framesize = 640;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 2;
sim_param(record).max_iterations = 10;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'b:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 12;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 640 bits, log-MAP';
sim_param(record).SNR = 0:0.2:4;
sim_param(record).framesize = 640;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).max_iterations = 10;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'm:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-8; 
sim_param(record).max_frame_errors = 50*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 13;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 1060 bits, max-log-MAP';
sim_param(record).SNR = 0:0.15:1.8;
sim_param(record).framesize = 1060;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 1;
sim_param(record).max_iterations = 11;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 14;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 1060 bits, constant-log-MAP';
sim_param(record).SNR = 0:0.15:1.8;
sim_param(record).framesize = 1060;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 2;
sim_param(record).max_iterations = 11;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'b:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 15;
sim_param(record).comment = 'LTE-TC, BPSK, AWGN, 1060 bits, log-MAP';
sim_param(record).SNR = 0:0.15:1.8;
sim_param(record).framesize = 1060;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).max_iterations = 11;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'k:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 16;
sim_param(record).comment = '6144 bits, SW-logMAP, 32/32';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 32;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'b:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 17;
sim_param(record).comment = '6144 bits, SW-logMAP, 16/32';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 16;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'g:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 18;
sim_param(record).comment = '6144 bits, SW-logMAP, 12/32';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 12;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'c:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 19;
sim_param(record).comment = '6144 bits, SW-logMAP, 4/32';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 4;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'm:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 20;
sim_param(record).comment = '6144 bits, SW-logMAP, 8/256';
sim_param(record).SNR = 0.0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 256;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'g:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 21;
sim_param(record).comment = '6144 bits, logMAP, P=8, S=128';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 128;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'c:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 22;
sim_param(record).comment = '6144 bits, SW-logMAP, p=8, S=64';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 64;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'm:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 23;
sim_param(record).comment = '6144 bits, SW-logMAP, 8/16';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 16;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'y:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 24;
sim_param(record).comment =  'LTE, 6144 bits, flp-pSW-logMAP, 8/32';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'm';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp', int2str(record), int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 25;
sim_param(record).comment = '6144 bits, logMAP, P=8, S=32';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'b:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 101;  % For ploting iCoing BER
sim_param(record).comment = 'iCoding, 8.5 iterations';
sim_param(record).SNR = 0:0.2:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'b-';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = 'iCoding_ber_5144_8.mat';
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 102;  % For ploting iCoing BER
sim_param(record).comment = 'TurboConcept, from their claim';
sim_param(record).SNR = 0:0.2:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'r-';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = 'tc_ber_5144_8.mat';
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 110;
sim_param(record).comment = 'Fixed point, PSW-logMap, P=8, S=128';
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 128;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = 8; %sim_param(record).max_iterations;
sim_param(record).linetype = 'b:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 111;
sim_param(record).comment =  strcat(int2str(record), ': 6144 bits, fxp-SW-S-max-logMAP, 8/32, 5-8');
sim_param(record).SNR = 0:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 5;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r:';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 112;
sim_param(record).comment =  strcat(int2str(record), ': 6144 bits, fxp-SW-S-max-logMAP, 8/32,5-9');
sim_param(record).SNR = 0:3.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 5; % Scaling max-logMAP
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).fxp_data_width = [5 2 9 2];
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'r-';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 113;
sim_param(record).comment =  strcat(int2str(record), ': 6144 bits, fxp-SW-S-max-logMAP, 8/32, 6-9');
sim_param(record).SNR = 0.4:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 5; % Scaling max-logMAP
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'c-';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 114;
sim_param(record).comment =  strcat(int2str(record), ': 6144 bits, fxp-SW-logMAP, 8/32, 6-9');
sim_param(record).SNR = 0.4:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 3; % logMAP
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'b-';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 115;
sim_param(record).comment =  strcat(int2str(record), ': 6144 bits, fxp-SW-S-max-logMAP, 8/32, 6-9');
sim_param(record).SNR = 0.4:0.1:1.0;
sim_param(record).framesize = 6144;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 5; % S-max-logMAP
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'b-';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'BPSK';
sim_param(record).mod_order = 2;
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1
    1 1];
sim_param(record).pun_pattern2= [0 0
    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1
    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'fxp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',sprintf('%d',sim_param(record).fxp_data_width(1:end)),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones(size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

record = 303;
sim_param(record).comment = '160 bits, SW-logMAP, 8/32, 16QAM';
sim_param(record).SNR = 4.0:0.5:10;
sim_param(record).framesize = 160;
sim_param(record).channel = 'awgn';
sim_param(record).decoder_type = 2;
sim_param(record).num_subblocks = 8;
sim_param(record).subblock_size = 32;
sim_param(record).max_iterations = 8;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).linetype = 'k-';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 1;
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).modulation = 'QAM';
sim_param(record).mod_order = 16;
sim_param(record).mapping = 'gray';
sim_param(record).bicm = 1;
sim_param(record).demod_type = 0; 
sim_param(record).legend = sim_param(record).comment;
sim_param(record).code_interleaver = ...
    strcat( 'CreateLTEInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).pun_pattern1 = [1 1;    1 1];
sim_param(record).pun_pattern2= [0 0;    1 1 ];
sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
sim_param(record).filename = strcat( data_directory, ...
    strcat( 'flp',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, int2str( sim_param(record).num_subblocks ), int2str( sim_param(record).subblock_size ),'_',int2str(sim_param(record).decoder_type),'.mat') );
sim_param(record).reset = 1;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = 1e-6; 
sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);
