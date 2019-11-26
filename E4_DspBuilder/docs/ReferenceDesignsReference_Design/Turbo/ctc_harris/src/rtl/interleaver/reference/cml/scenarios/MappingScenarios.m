% File MappingScenarios
%
% This is a set of scenarios for the Coded Modulation Library.
%
% The simulations specified in this file are for uncoded modulation.
%
% Last updated on Nov. 14, 2006

% determine where your root directory is
load( 'CmlHome.mat' );

% determine where to store your files
base_name = 'mapping';
if ispc
    data_directory = strcat( cml_home, '\output\', base_name, '\' );
else
    data_directory = strcat( cml_home, '/output/', base_name, '/' );
end
if ~exist( data_directory, 'dir' )
    mkdir(data_directory);
end

num_errors = 50;
BER = 1e-6;

% mappings
dt16_bin = [0 0 0 0
1 1 0 1
0 1 1 0
1 0 1 1
0 1 1 1
1 0 1 0
0 0 0 1
1 1 0 0
1 0 0 1
0 1 0 0
1 1 1 1
0 0 1 0
1 1 1 0
0 0 1 1
1 0 0 0
0 1 0 1];
dt16_dec = (2.^[3:-1:0])*dt16_bin';

dt64_bin = [0 0 0 0 1 1
1 1 0 1 0 0
0 1 1 0 1 1
1 0 1 1 0 0
0 1 0 0 0 1
1 0 0 1 1 0
0 0 1 0 0 1
1 1 1 1 1 0
0 1 1 1 0 0
1 0 1 0 1 1
0 0 0 1 0 0
1 1 0 0 1 1
0 0 1 1 1 0
1 1 1 0 0 1
0 1 0 1 1 0
1 0 0 0 0 1
1 0 0 1 1 1
0 1 0 0 0 0
1 1 1 1 1 1
0 0 1 0 0 0
1 1 0 1 0 1
0 0 0 0 1 0
1 0 1 1 0 1
0 1 1 0 1 0
1 1 1 0 0 0
0 0 1 1 1 1
1 0 0 0 0 0
0 1 0 1 1 1
1 0 1 0 1 0
0 1 1 1 0 1
1 1 0 0 1 0
0 0 0 1 0 1
0 0 0 1 1 0
1 1 0 0 0 1
0 1 1 1 1 0
1 0 1 0 0 1
0 1 0 1 0 0
1 0 0 0 1 1
0 0 1 1 0 0
1 1 1 0 1 1
0 1 1 0 0 1
1 0 1 1 1 0
0 0 0 0 0 1
1 1 0 1 1 0
0 0 1 0 1 1
1 1 1 1 0 0
0 1 0 0 1 1
1 0 0 1 0 0
1 0 0 0 1 0
0 1 0 1 0 1
1 1 1 0 1 0
0 0 1 1 0 1
1 1 0 0 0 0
1 1 1 0 1 1
1 0 1 0 0 0
0 1 1 1 1 1
1 1 1 1 0 1
0 0 1 0 1 0
1 0 0 1 0 1
0 1 0 0 1 0
1 0 1 1 1 1
0 1 1 0 0 0
1 1 0 1 1 1
0 0 0 0 0 0];
dt64_dec = (2.^[5:-1:0])*dt64_bin';

hr64_dec = [48 60 36 40 19 31 7 11 57 24 45 12 55 22 35 2 33 0 9 46 21 50 59 26 58 34 43 10 49 16 25 1 ...
    5 30 6 15 52 61 37 62 29 39 27 3 56 32 28 38 20 63 18 23 44 41 4 47 53 54 17 51 8 42 13 14];
hr16_dec = [4 1 14 13 8 2 11 7 15 5 12 0 3 6 9 10];

% BICM-ID: Convolutionally coded (K=7) gray mapped 16-QAM in Rayleigh
% fading, r=8/15
record = 1;
sim_param(record).comment = '16-QAM, Gray Mapped, K=7 Conv, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:13];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).pun_pattern1 = [1 1 1 1 1 1 1 0
    1 1 1 1 1 1 1 1 ];
sim_param(record).tail_pattern1 = ones(2,length(sim_param(record).g1)-1);
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_CC_K7_8r15_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];


% BICM-ID: Convolutionally coded (K=7) gray mapped 16-QAM in Rayleigh fading
% r=1/2
record = 2;
sim_param(record).comment = '16-QAM, Gray Mapped, K=7 Conv, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:13];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_CC_K7_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];

% BICM-ID: Convolutionally coded (K=4) gray mapped 16-QAM in Rayleigh fading
% r=1/2
record = 3;
sim_param(record).comment = '16-QAM, Gray Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_CC_K4_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];

% BICM-ID: Turbo coded gray mapped 16-QAM in Rayleigh fading r=1/2
record = 4;
sim_param(record).comment = '16-QAM, Gray Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:4.5 4.75:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 4096; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_UMTS_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = 16;

% BICM: Turbo coded gray mapped 16-QAM in Rayleigh fading r=1/2
record = 5;
sim_param(record).comment = '16-QAM, Gray Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:4.5 4.75:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 4096; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_UMTS_1r2_Rayleigh_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = 16;

% BICM-ID: Convolutionally coded (K=7) dt mapped 16-QAM in Rayleigh fading
% r=1/2
record = 6;
sim_param(record).comment = '16-QAM, DT Mapped, K=7 Conv, Rayleigh fading'; %%
sim_param(record).legend = 'dt mapped'; %%
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:8 8.25:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec; %%
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'c:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_CC_K7_1r2_Rayleigh_bicmid.mat'); %%
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];

% BICM-ID: Convolutionally coded (K=4) dt mapped 16-QAM in Rayleigh fading
% r=1/2
record = 7;
sim_param(record).comment = '16-QAM, DT Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'dt mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:7 7.25:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_CC_K4_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];

% BICM-ID: Turbo coded dt mapped 16-QAM in Rayleigh fading r=1/2
record = 8;
sim_param(record).comment = '16-QAM, DT Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'dt mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:4.5 4.75:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 4096; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_UMTS_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = 16;

% BICM: Turbo coded dt mapped 16-QAM in Rayleigh fading r=1/2
record = 9;
sim_param(record).comment = '16-QAM, DT Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'dt mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:4.5 4.75:0.25:12];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 4096; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_UMTS_1r2_Rayleigh_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = 16;

% BICM-ID: Convolutionally coded (K=3) dt mapped 16-QAM in Rayleigh fading
% r=1/2
record = 10;
sim_param(record).comment = '16-QAM, DT Mapped, K=3 Conv, Rayleigh fading';
sim_param(record).legend = 'dt mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:7 7.25:0.25:12];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k-.';
sim_param(record).g1 = [1 0 1 
    1 1 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_CC_K3_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];

% BICM-ID: Convolutionally coded (K=7) gray mapped 64-QAM in Rayleigh fading
% r=1/2
record = 11;
sim_param(record).comment = '64-QAM, Gray Mapped, K=7 Conv, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:14];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 64;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM64_gray_CC_K7_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];

% BICM-ID: Convolutionally coded (K=4) gray mapped 64-QAM in Rayleigh fading
% r=1/2
record = 12;
sim_param(record).comment = '64-QAM, Gray Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:16];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 64;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM64_gray_CC_K4_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = [1 16];

% BICM-ID: Turbo coded gray mapped 64-QAM in Rayleigh fading r=1/2
record = 13;
sim_param(record).comment = '64-QAM, Gray Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:8.5 8.75:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 4096; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 64;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM64_gray_UMTS_1r2_Rayleigh_bicmid.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = 16;

% BICM: Turbo coded gray mapped 64-QAM in Rayleigh fading r=1/2
record = 14;
sim_param(record).comment = '64-QAM, Gray Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'gray mapped';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:8.5 8.75:0.25:10];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 2048;
sim_param(record).code_bits_per_frame = 4096; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 64;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 16;
sim_param(record).filename = strcat( data_directory, 'QAM64_gray_UMTS_1r2_Rayleigh_bicm.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 100;
sim_param(record).plot_iterations = 16;

% record 15 through 18 placeholder

% BICM-ID: Convolutionally coded (K=7) gray mapped 16-QAM in Rayleigh fading
% r=1/2
record = 19;
sim_param(record).comment = '16-QAM, Gray Mapped, K=7 Conv, Rayleigh fading';
sim_param(record).legend = 'gray CC 7';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_CC_K7_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=4) gray mapped 16-QAM in Rayleigh fading
% r=1/2
record = 20;
sim_param(record).comment = '16-QAM, Gray Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'gray CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:16];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_CC_K4_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Turbo coded gray mapped 16-QAM in Rayleigh fading r=1/2
record = 21;
sim_param(record).comment = '16-QAM, Gray Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'gray TC ID';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).code_bits_per_frame = 200; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_UMTS_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = 10;

% BICM: Turbo coded gray mapped 16-QAM in Rayleigh fading r=1/2
record = 22;
sim_param(record).comment = '16-QAM, Gray Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'gray TC';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).code_bits_per_frame = 200; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'k:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_UMTS_1r2_Rayleigh_bicm_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = 10;

% BICM-ID: Convolutionally coded (K=7) dt mapped 16-QAM in Rayleigh fading
% r=1/2
record = 23;
sim_param(record).comment = '16-QAM, DT Mapped, K=7 Conv, Rayleigh fading'; %%
sim_param(record).legend = 'dt CC 7'; %%
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec; %%
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'c:';
sim_param(record).g1 = [1 0 1 1 0 1 1
   1 1 1 1 0 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_CC_K7_1r2_Rayleigh_bicmid_100.mat'); %%
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=4) dt mapped 16-QAM in Rayleigh fading
% r=1/2
record = 24;
sim_param(record).comment = '16-QAM, DT Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'dt CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:16];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_CC_K4_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Turbo coded dt mapped 16-QAM in Rayleigh fading r=1/2
record = 25;
sim_param(record).comment = '16-QAM, DT Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'dt DT ID';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:15];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).code_bits_per_frame = 200; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g-';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_UMTS_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = 10;

% BICM: Turbo coded dt mapped 16-QAM in Rayleigh fading r=1/2
record = 26;
sim_param(record).comment = '16-QAM, DT Mapped, UMTS Turbo, Rayleigh fading';
sim_param(record).legend = 'dt TC';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 4; % UMTS
sim_param(record).SNR = [0:0.5:16];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).code_bits_per_frame = 200; % rate 1/2
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 1; % BICM
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'g:';
sim_param(record).code_interleaver = ...
    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
sim_param(record).g1 = [1 0 1 1
        1 1 0 1];
sim_param(record).g2 = [1 0 1 1
        1 1 0 1];
sim_param(record).nsc_flag1 = 0; % RSC convolutional code
sim_param(record).nsc_flag2 = 0; % RSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_UMTS_1r2_Rayleigh_bicm_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = 10;

% BICM-ID: Convolutionally coded (K=4) huang-ritcey mapped 16-QAM in Rayleigh fading
% r=1/2
record = 27;
sim_param(record).comment = '16-QAM, HR Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'hr CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:16];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = [4 1 14 13 8 2 11 7 15 5 12 0 3 6 9 10];
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_hr_CC_K4_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=4) shreckenbach mapped 16-QAM in Rayleigh fading
% r=1/2
record = 28;
sim_param(record).comment = '16-QAM, Schreckenbach Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'S CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:16];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = [6 3 13 8 0 10 4 14 15 9 7 1 5 12 2 11];
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'c:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_S_CC_K4_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 1000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=4) gray mapped 16-QAM in Rayleigh fading
% r=1/2
record = 29;
sim_param(record).comment = '16-QAM, Gray Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'gray CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 45;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_CC_K4_1r2_Rayleigh_bicmid_45.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 5000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=4) dt mapped 16-QAM in Rayleigh fading
% r=1/2
record = 30;
sim_param(record).comment = '16-QAM, DT Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'dt CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 45;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_CC_K4_1r2_Rayleigh_bicmid_45.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 5000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=4) huang-ritcey mapped 16-QAM in Rayleigh fading
% r=1/2
record = 31;
sim_param(record).comment = '16-QAM, HR Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'hr CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 45;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = [4 1 14 13 8 2 11 7 15 5 12 0 3 6 9 10];
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_hr_CC_K4_1r2_Rayleigh_bicmid_45.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 5000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=4) shreckenbach mapped 16-QAM in Rayleigh fading
% r=1/2
record = 32;
sim_param(record).comment = '16-QAM, Schreckenbach Mapped, K=4 Conv, Rayleigh fading';
sim_param(record).legend = 'S CC 4';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 45;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = [6 3 13 8 0 10 4 14 15 9 7 1 5 12 2 11];
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'c:';
sim_param(record).g1 = [1 0 1 1
    1 1 0 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_S_CC_K4_1r2_Rayleigh_bicmid_45.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 5000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=3) gray mapped 64-QAM in Rayleigh fading
% r=1/2, K=3, 100 bits
record = 33;
sim_param(record).comment = '64-QAM, Gray Mapped, K=3 Conv, Rayleigh fading';
sim_param(record).legend = 'gray CC 3';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 64;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 
    1 1 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 12;
sim_param(record).filename = strcat( data_directory, 'QAM64_gray_CC_K3_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 5000;
sim_param(record).plot_iterations = [1 12];

% BICM-ID: Convolutionally coded (K=3) dt mapped 64-QAM in Rayleigh fading
% r=1/2, K=3, 100 bits
record = 34;
sim_param(record).comment = '64-QAM, DT Mapped, K=3 Conv, Rayleigh fading';
sim_param(record).legend = 'dt CC 3';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt64_dec;
sim_param(record).mod_order = 64;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).g1 = [1 0 1 
    1 1 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 12;
sim_param(record).filename = strcat( data_directory, 'QAM64_dt_CC_K3_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 5000;
sim_param(record).plot_iterations = [1 12];


% BICM-ID: Convolutionally coded (K=3) hr mapped 64-QAM in Rayleigh fading
% r=1/2, K=3, 100 bits
record = 35;
sim_param(record).comment = '64-QAM, HR Mapped, K=3 Conv, Rayleigh fading';
sim_param(record).legend = 'hr CC 3';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = hr64_dec;
sim_param(record).mod_order = 64;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 
    1 1 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 12;
sim_param(record).filename = strcat( data_directory, 'QAM64_hr_CC_K3_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 5000;
sim_param(record).plot_iterations = [1 12];

% BICM-ID: Convolutionally coded (K=3) gray mapped 16-QAM in Rayleigh fading
% r=1/2, K=3, 100 bits
record = 36;
sim_param(record).comment = '16-QAM, Gray Mapped, K=3 Conv, Rayleigh fading';
sim_param(record).legend = 'gray CC 3';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = 'gray';
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'r:';
sim_param(record).g1 = [1 0 1 
    1 1 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_gray_CC_K3_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 10000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=3) dt mapped 16-QAM in Rayleigh fading
% r=1/2, K=3, 100 bits
record = 37;
sim_param(record).comment = '16-QAM, DT Mapped, K=3 Conv, Rayleigh fading';
sim_param(record).legend = 'dt CC 3';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = dt16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'm:';
sim_param(record).g1 = [1 0 1 
    1 1 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_dt_CC_K3_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 10000;
sim_param(record).plot_iterations = [1 10];

% BICM-ID: Convolutionally coded (K=3) hr mapped 16-QAM in Rayleigh fading
% r=1/2, K=3, 100 bits
record = 38;
sim_param(record).comment = '16-QAM, HR Mapped, K=3 Conv, Rayleigh fading';
sim_param(record).legend = 'hr CC 3';
sim_param(record).sim_type = 'coded';
sim_param(record).code_configuration = 0; % Convolutional
sim_param(record).SNR = [0:0.5:20];
sim_param(record).SNR_type = 'Eb/No in dB';
sim_param(record).framesize = 100;
sim_param(record).modulation = 'QAM';
sim_param(record).mapping = hr16_dec;
sim_param(record).mod_order = 16;
sim_param(record).channel = 'Rayleigh';
sim_param(record).bicm = 2; % BICM-ID
sim_param(record).demod_type = 0; % linear-log-MAP
sim_param(record).linetype = 'b:';
sim_param(record).g1 = [1 0 1 
    1 1 1];
sim_param(record).nsc_flag1 = 1; % NSC convolutional code
sim_param(record).decoder_type =  0;  % linear-log-MAP
sim_param(record).max_iterations = 10;
sim_param(record).filename = strcat( data_directory, 'QAM16_hr_CC_K3_1r2_Rayleigh_bicmid_100.mat');
sim_param(record).reset = 0;
sim_param(record).max_trials = 1e9*ones( size(sim_param(record).SNR) );
sim_param(record).minBER = BER;    
sim_param(record).max_frame_errors = num_errors*ones( size(sim_param(record).SNR) );
sim_param(record).save_rate = 10000;
sim_param(record).plot_iterations = [1 10];
