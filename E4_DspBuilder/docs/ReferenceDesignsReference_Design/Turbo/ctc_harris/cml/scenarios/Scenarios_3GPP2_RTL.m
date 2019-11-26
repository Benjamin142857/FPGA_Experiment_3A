load( 'CmlHome.mat' );

% determine where to store your files
base_name = '3gpp2_rtl';
if ispc
    	data_directory = strcat( cml_home, '\output\', base_name, '\' );
else
    	data_directory = strcat( cml_home, '/output/', base_name, '/' );
end;
if ~exist( data_directory, 'dir' )
    	mkdir(data_directory);
end;

SNR_table =[0.5 1 20 0.3];
%SNR_table =[20 20 20 20];

index = 1;

block_sizes = [40:5114];

for record = block_sizes
	sim_param(index).comment = sprintf('RTL 3GPP2 test: %d bits, s-maxlogMAP/8it/8bits', record);
	sim_param(index).SNR = SNR_table; %SNR_table(round(rand(1)*3)+1);
	sim_param(index).framesize = record;
	sim_param(index).code_bits_per_frame = sim_param(index).framesize*3+12;
	sim_param(index).channel = 'awgn';
	sim_param(index).decoder_type = 5;
	sim_param(index).num_engines = 2;
	sim_param(index).dump_input = 1;
	sim_param(index).dump_output = 1;
	sim_param(index).dump_iter = 1;
	sim_param(index).rtl_simulation = 0;
	sim_param(index).dump_dir = [cml_home, '/../test'];
	sim_param(index).sldwin_size = 32;
	sim_param(index).fxp_data_width = [8 2 12 2];
	sim_param(index).max_iterations = 8;
	sim_param(index).plot_iterations = sim_param(index).max_iterations;
	sim_param(index).linetype = 'b-';
	sim_param(index).sim_type = 'coded';
	sim_param(index).code_configuration = 5;
	sim_param(index).SNR_type = 'Eb/No in dB';
	sim_param(index).modulation = 'BPSK';
	sim_param(index).mod_order = 2;
	sim_param(index).mapping = 'gray';
	sim_param(index).bicm = 0;
	sim_param(index).demod_type = 0;
	sim_param(index).legend = sim_param(index).comment;
	sim_param(index).code_interleaver = ...
	    strcat( 'Create3GPP2Interleaver(', int2str(sim_param(index).framesize ), ')' );
	sim_param(index).g1 = [1 0 1 1;    1 1 0 1];
	sim_param(index).g2 = sim_param(index).g1;
	sim_param(index).nsc_flag1 = 0;
	sim_param(index).nsc_flag2 = 0;
	sim_param(index).pun_pattern1 = [1 1;    1 1];
	sim_param(index).pun_pattern2= [0 0;    1 1 ];
	sim_param(index).tail_pattern1 = [1 1 1;    1 1 1];
	sim_param(index).tail_pattern2 = sim_param(index).tail_pattern1;
	sim_param(index).filename = strcat( data_directory, ...
	    strcat( 'rtl',int2str(record),  int2str(sim_param(index).framesize ), sim_param(index).channel, sim_param(index).modulation, int2str(sim_param(index).mod_order), int2str(sim_param(index).decoder_type), int2str(sim_param(index).max_iterations), '.mat') );
	sim_param(index).reset = 1;
	sim_param(index).max_trials = [4 4 4 4]; %1;
	sim_param(index).minBER = 1e-9;
	sim_param(index).max_frame_errors = 40*ones( 1, length(sim_param(index).SNR) );
	sim_param(index).save_rate = ceil(614400/sim_param(index).framesize);
    index = index + 1;
end
