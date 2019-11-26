load( 'CmlHome.mat' );

% determine where to store your files
base_name = 'umts_rtl';
if ispc
    	data_directory = strcat( cml_home, '\output\', base_name, '\' );
else
    	data_directory = strcat( cml_home, '/output/', base_name, '/' );
end;
if ~exist( data_directory, 'dir' )
    	mkdir(data_directory);
end;

%SNR_table =[0.5 1 20 0.3];
SNR_table =[20 20 20 20];

for record = 40:5144
	sim_param(record).comment = sprintf('RTL test: %d bits, s-maxlogMAP/8it/8bits', record);
	sim_param(record).SNR = SNR_table(round(rand(1)*3)+1);
	sim_param(record).framesize = record;
	sim_param(record).code_bits_per_frame = sim_param(record).framesize*3+12;
	sim_param(record).channel = 'awgn';  
	sim_param(record).decoder_type = 5;
	sim_param(record).num_engines = 4;
	sim_param(record).dump_input = 1;
	sim_param(record).dump_output = 1;
	sim_param(record).dump_iter = 1;
	sim_param(record).rtl_simulation = 1;
	sim_param(record).dump_dir = [cml_home, '/../test'];
	sim_param(record).sldwin_size = 32;
	sim_param(record).fxp_data_width = [8 2 12 2];
	sim_param(record).max_iterations = 8;
	sim_param(record).plot_iterations = sim_param(record).max_iterations;
	sim_param(record).linetype = 'b-';
	sim_param(record).sim_type = 'coded';
	sim_param(record).code_configuration = 4;
	sim_param(record).SNR_type = 'Eb/No in dB';
	sim_param(record).modulation = 'BPSK';
	sim_param(record).mod_order = 2;
	sim_param(record).mapping = 'gray';
	sim_param(record).bicm = 0;
	sim_param(record).demod_type = 0; 
	sim_param(record).legend = sim_param(record).comment;
	sim_param(record).code_interleaver = ...
	    strcat( 'CreateUmtsInterleaver(', int2str(sim_param(record).framesize ), ')' );
	sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
	sim_param(record).g2 = sim_param(record).g1;
	sim_param(record).nsc_flag1 = 0;
	sim_param(record).nsc_flag2 = 0;
	sim_param(record).pun_pattern1 = [1 1;    1 1];
	sim_param(record).pun_pattern2= [0 0;    1 1 ];
	sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
	sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
	sim_param(record).filename = strcat( data_directory, ...
	    strcat( 'rtl',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, sim_param(record).modulation, int2str(sim_param(record).mod_order), int2str(sim_param(record).decoder_type), int2str(sim_param(record).max_iterations), '.mat') );
	sim_param(record).reset = 1;
	sim_param(record).max_trials = 1;
	sim_param(record).minBER = 1e-9; 
	sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
	sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);   
end

