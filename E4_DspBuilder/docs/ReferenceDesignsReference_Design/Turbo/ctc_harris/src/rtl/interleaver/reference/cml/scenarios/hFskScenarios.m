% File FskScenarios
%
% This is a set of scenarios for the Coded Modulation Library.
%
% The simulations specified in this file are for uncoded modulation.
%
% Last updated on July 4, 2006

% determine where your root directory is
load( 'CmlHome.mat' );

% determine where to store your files
base_name = 'fsk';
if ispc
    data_directory = strcat( cml_home, '\output\', base_name, '\' );
else
    data_directory = strcat( cml_home, '/output/', base_name, '/' );
end
if ~exist( data_directory, 'dir' )
    mkdir(data_directory);
end

num_errors = 60;
BER = 6e-5;

% BICM-ID: Turbo coded 8FSK modulation in AWGN w/ BICM-ID: mv mapping
record = 1;
sim_param(record).comment = 'reverse-dt mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:4 4.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'm-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_mv_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in AWGN w/ BICM-ID: dt mapping
record = 2;
sim_param(record).comment = 'dt mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:4 4.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'b-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_dt_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in AWGN w/ BICM-ID: natural mapping
record = 3;
sim_param(record).comment = 'natural mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:4 4.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'r-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_natural_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in AWGN w/ BICM-ID: reverse gray mapping
record = 4;
sim_param(record).comment = 'reverse-gray mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:4 4.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'g-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_reversegray_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in AWGN w/ BICM-ID: gray mapping 
record = 5;
sim_param(record).comment = 'gray mapped 8 CPFSK bicm-id';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:4 4.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_gray_bicmid_corrected.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Turbo coded 8FSK modulation in AWGN: mv mapping
record = 6;
sim_param(record).comment = 'mv mapped 8 CPFSK bicm';
sim_param(record).legend = 'reverse-dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:8 8.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_mv_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Turbo coded 8FSK modulation in AWGN: dt mapping
record = 7;
sim_param(record).comment = 'dt mapped 8 CPFSK bicm';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:8 8.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_dt_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Turbo coded 8FSK modulation in AWGN: natural mapping
record = 8;
sim_param(record).comment = 'natural mapped 8 CPFSK bicm';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:6 6.5:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_natural_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in AWGN: reverse gray mapping
record = 9;
sim_param(record).comment = 'reverse gray mapped 8 CPFSK bicm';
sim_param(record).legend = 'reverse-gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'g:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_reversegray_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in AWGN: gray mapping and bicm
record = 10;
sim_param(record).comment = 'gray mapped 8 CPFSK bicm';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.1:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'k:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_AWGN_gray_bicm_corrected.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Convolutionally coded 8FSK modulation in AWGN: mv mapping
record = 11;
sim_param(record).comment = 'reverse-dt mapping, r=1/2 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'reverse-dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_mv_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in AWGN: dt mapping
record = 12;
sim_param(record).comment = 'dt mapping, r=1/2 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_dt_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in AWGN: natural mapping
record = 13;
sim_param(record).comment = 'natural mapping, r=1/2 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.25:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_natural_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in AWGN: reverse gray mapping
record = 14;
sim_param(record).comment = 'reverse-gray mapping, r=1/2 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'reverse-gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.25:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_reversegray_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;  
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in AWGN: gray mapping
record = 15;
sim_param(record).comment = 'gray mapping, r=1/2 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.25:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_gray_bicmid_corrected.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in AWGN: mv mapping, rate 8/15
record = 16;
sim_param(record).comment = 'reverse-dt mapping, r=8/15 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'reverse-dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_mv_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in AWGN: dt mapping
record = 17;
sim_param(record).comment = 'dt mapping, r=8/15 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_dt_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in AWGN: natural mapping
record = 18;
sim_param(record).comment = 'natural mapping, r=8/15 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_natural_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in AWGN: reverse gray mapping
record = 19;
sim_param(record).comment = 'reverse-gray mapping, r=8/15 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'reverse-gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_reversegray_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;  
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in AWGN: gray mapping
record = 20;
sim_param(record).comment = 'gray mapping, r=8/15 CC, K = 7, q=8, h=0.32, AWGN';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_gray_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K = 4) 8FSK modulation in AWGN: mv mapping
record = 21;
sim_param(record).comment = 'reverse-dt mapping, r=8/15 CC, K = 4, q=8, h=0.32, AWGN';
sim_param(record).legend = 'reverse-dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_mv_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in AWGN: dt mapping
record = 22;
sim_param(record).comment = 'dt mapping, r=8/15 CC, K = 4, q=8, h=0.32, AWGN';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_dt_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in AWGN: natural mapping
record = 23;
sim_param(record).comment = 'natural mapping, r=8/15 CC, K = 4, q=8, h=0.32, AWGN';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_natural_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in AWGN: reverse gray mapping
record = 24;
sim_param(record).comment = 'reverse-gray mapping, r=8/15 CC, K = 4, q=8, h=0.32, AWGN';
sim_param(record).legend = 'reverse-gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_reversegray_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;  
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in AWGN: gray mapping
record = 25;
sim_param(record).comment = 'gray mapping, r=8/15 CC, K = 4, q=8, h=0.32, AWGN';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_AWGN_gray_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM-ID: Turbo coded 8FSK modulation in Fading w/ BICM-ID: mv mapping
record = 26;
sim_param(record).comment = 'reverse-dt mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.1:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'm-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_mv_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in Fading w/ BICM-ID: dt mapping
record = 27;
sim_param(record).comment = 'dt mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.1:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'b-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_dt_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in Fading w/ BICM-ID: natural mapping
record = 28;
sim_param(record).comment = 'natural mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.1:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'r-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_natural_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in Fading w/ BICM-ID: reverse gray mapping
record = 29;
sim_param(record).comment = 'reverse-gray mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.1:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'g-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayeleigh_reversegray_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in Fading w/ BICM-ID: gray mapping 
record = 30;
sim_param(record).comment = 'gray mapped 8 CPFSK bicm-id';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.1:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_gray_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Turbo coded 8FSK modulation in Fading: mv mapping
record = 31;
sim_param(record).comment = 'mv mapped 8 CPFSK bicm';
sim_param(record).legend = 'reverse-dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:8 8.1:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_mv_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Turbo coded 8FSK modulation in Fading: dt mapping
record = 32;
sim_param(record).comment = 'dt mapped 8 CPFSK bicm';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:8 8.1:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_dt_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Turbo coded 8FSK modulation in Fading: natural mapping
record = 33;
sim_param(record).comment = 'natural mapped 8 CPFSK bicm';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:6 6.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_natural_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in Fading: reverse gray mapping
record = 34;
sim_param(record).comment = 'reverse gray mapped 8 CPFSK bicm';
sim_param(record).legend = 'reverse-gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'g:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_reversegray_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM-ID: Turbo coded 8FSK modulation in Fading: gray mapping and bicm
record = 35;
sim_param(record).comment = 'gray mapped 8 CPFSK bicm';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:5 5.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 3840;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % log-MAP
sim_param(record).linetype = 'k:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).g2 = sim_param(record).g1;
sim_param(record).nsc_flag1 = 0;
sim_param(record).nsc_flag2 = 0;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).plot_iterations = sim_param(record).max_iterations;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_r2048by3840_Rayleigh_gray_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER; 
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;

% BICM: Convolutionally coded 8FSK modulation in Fading: mv mapping
record = 36;
sim_param(record).comment = 'reverse-dt mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.5:0.5:6 6.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_mv_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in Fading: dt mapping
record = 37;
sim_param(record).comment = 'dt mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.5:0.5:6 6.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_dt_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in Fading: natural mapping
record = 38;
sim_param(record).comment = 'natural mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.5:0.5:6 6.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_natural_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in Fading: reverse gray mapping
record = 39;
sim_param(record).comment = 'reverse-gray mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.5:0.5:6 6.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_reversegray_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;  
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in Fading: gray mapping
record = 40;
sim_param(record).comment = 'gray mapping';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.5:0.5:6 6.5:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_gray_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 8FSK modulation in Fading: mv mapping, rate 8/15
record = 41;
sim_param(record).comment = 'reverse-dt mapping, r=8/15 CC, K = 7, q=8, h=0.32, Fading';
sim_param(record).legend = 'reverse-dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_mv_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in Fading: dt mapping
record = 42;
sim_param(record).comment = 'dt mapping, r=8/15 CC, K = 7, q=8, h=0.32, Fading';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_dt_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in Fading: natural mapping
record = 43;
sim_param(record).comment = 'natural mapping, r=8/15 CC, K = 7, q=8, h=0.32, Fading';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_natural_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in Fading: reverse gray mapping
record = 44;
sim_param(record).comment = 'reverse-gray mapping, r=8/15 CC, K = 7, q=8, h=0.32, Fading';
sim_param(record).legend = 'reverse-gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_reversegray_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;  
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15) 8FSK modulation in Fading: gray mapping
record = 45;
sim_param(record).comment = 'gray mapping, r=8/15 CC, K = 7, q=8, h=0.32, Fading';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_gray_bicmid_8r15.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K = 4) 8FSK modulation in Fading: mv mapping
record = 46;
sim_param(record).comment = 'reverse-dt mapping, r=8/15 CC, K = 4, q=8, h=0.32, Fading';
sim_param(record).legend = 'reverse-dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_mv_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in Fading: dt mapping
record = 47;
sim_param(record).comment = 'dt mapping, r=8/15 CC, K = 4, q=8, h=0.32, Fading';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_dt_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in Fading: natural mapping
record = 48;
sim_param(record).comment = 'natural mapping, r=8/15 CC, K = 4, q=8, h=0.32, Fading';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_natural_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in Fading: reverse gray mapping
record = 49;
sim_param(record).comment = 'reverse-gray mapping, r=8/15 CC, K = 4, q=8, h=0.32, Fading';
sim_param(record).legend = 'reverse-gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5];
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_reversegray_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;  
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded (r=8/15, K=4) 8FSK modulation in Fading: gray mapping
record = 50;
sim_param(record).comment = 'gray mapping, r=8/15 CC, K = 4, q=8, h=0.32, Fading';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:4 4.2:0.1:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 8;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k--';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK8_h032_convolutional_Rayleigh_gray_bicmid_8r15_K4.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 8];

% Old 16-FSK results ... still need to determine optimal h and R
% BICM: Convolutionally coded 16FSK modulation in AWGN: reverse gray mapping
record = 51;
sim_param(record).comment = 'reverse gray mapped 16 CPFSK convolutional';
sim_param(record).legend = 'alternate mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.4:6.8 6.9:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = [0 1 3 2 7 6 4 5 15 14 12 13 8 9 11 10];
sim_param(record).mod_order = 16;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK16_h032_convolutional_AWGN_reversegray_bicmid_corrected.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 50;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 16FSK modulation in AWGN: natural mapping
record = 52;
sim_param(record).comment = 'natural mapped 16 CPFSK convolutional';
sim_param(record).legend = 'natural mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.4:4.4 4.5:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'natural';
sim_param(record).mod_order = 16;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK16_h032_convolutional_AWGN_natural_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 50;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 16FSK modulation in AWGN: dt mapping
record = 53;
sim_param(record).comment = 'dt mapped 16 CPFSK convolutional';
sim_param(record).legend = 'dt mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.4:6.8 6.9:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'dt';
sim_param(record).mod_order = 16;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK16_h032_convolutional_AWGN_dt_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = 45*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 50;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 16FSK modulation in AWGN: gray mapping
record = 54;
sim_param(record).comment = 'gray mapped 16 CPFSK convolutional';
sim_param(record).legend = 'gray mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.4:6.8 6.9:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK16_h032_convolutional_AWGN_gray_bicmid_corrected.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 50;
sim_param(record).plot_iterations = [1 8];

% BICM: Convolutionally coded 16FSK modulation in AWGN: mv mapping
record = 55;
sim_param(record).comment = 'mv mapping';
sim_param(record).legend = 'mv mapping';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.4:3 3.2:0.1:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'FSK';
sim_param(record).h = 0.32;
sim_param(record).mapping = 'mv';
sim_param(record).mod_order = 16;
sim_param(record).csi_flag = 1; % noncoherent w/ CSI
sim_param(record).channel = 'AWGN';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm-';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1;
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 8;
sim_param(record).filename = strcat( data_directory, 'CPFSK16_h032_convolutional_AWGN_mv_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = 50*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 50;
sim_param(record).plot_iterations = [1 8];
