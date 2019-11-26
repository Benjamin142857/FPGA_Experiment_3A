#!perl -w

use Cwd;
use Cwd 'abs_path';
use File::Path;
use File::Basename;
use Getopt::Long;
use Tie::File;
use Fcntl;
use Data::Dumper;
# use strict;
use POSIX qw(ceil floor);

my $cml_home = "../../cml";
my $test_rootdir;
my $test_data_dir;

my $reset = 0;
my $random = 1;
my $start_num_from = 1000;
my $run_tests = 1;
my $local = 0;
my $clear_data = 1;
my $num_engines = 4;

my %records = ();
my $test_index;

my %record_to_test_map = ();

#my @umts_blocks = ( 40 .. 5114 );
#my @umts_blocks = ( 40 .. 2047 );

    my @umts_blocks_sm = ( 40 .. 2000 );
    my @umts_blocks_mid = ( 2001 .. 3999);
    my @umts_blocks_lg = ( 4000 .. 5114 );
    my @umts_blocks = (@umts_blocks_sm, @umts_blocks_mid, @umts_blocks_lg);
    my @harris_umts = (320,  496,  544,  656,  768,  832,  992,  1168, 1216, 1328, 1440, 1504, 1664, 1840, 1888, 2176, 2224, 2336, 2512,
                       2560, 2672, 2688, 2784, 2800, 2848, 2912, 3008, 3024, 3104, 3120, 3232, 3248, 3344, 3360, 3440, 3472, 3520, 3536,
                       3680, 3776, 3792, 3808, 3856, 3920, 3952, 4016, 4032, 4096, 4112, 4128, 4144, 4176, 4192, 4208, 4240, 4288, 4304,
                       4352, 4368, 4400, 4416, 4432, 4464, 4480, 4496, 4512, 4544, 4576, 4592, 4608, 4640, 4656, 4672, 4688, 4704, 4736,
                       4752, 4768, 4784, 4816, 4832, 4848, 4864, 4880, 4896, 4912, 4928, 4944, 4960, 4976, 4992, 5008, 5024, 5040, 5056,
                       5072, 5088, 5104);

sub create_record_to_test_map()
{
	my $test;
	my $recs_ref;
	my $rec;
	foreach $test (keys %records)
	{
		$recs_ref = $records{$test};
		foreach $rec (@$recs_ref)
		{
			$record_to_test_map{$rec} = $test;
		}
	}
}

sub read_file($)
{
	my $filename = $_[0];
	open(FILE, $filename) || die "Can't read file $filename: $!";
	my @file_contents;

	while(<FILE>)
	{
		chomp;
		s/\r$//; # convert to unix format
		push(@file_contents, $_);
	}
	close (FILE);

	return @file_contents;
}

sub write_reg_run_local_rtl($$$)
{
	my ($filename, $var_def, $num_test_cases) = @_;
	open(WRITEFILE, ">$filename") || die "Can't open file $filename for writing: $!";

	my $reg_run_local_head = "\#\!perl -w
	\#
	\# This script is auto-generated
	\#

	# use strict;
	use Tie::File;
	use Fcntl;
	use File::Copy;
	use File::Compare \'compare_text\';
    use POSIX qw(ceil floor);

    my \$warnings = 0;
	";

    my $minimise_cmd = ($^O =~ /linux/i ) ? "-nodesktop" : "-minimize";


    my $reg_run_local_body0 = "
    sub parse_transcript()
        {
            my \$transcript_file = \"transcript\";
            my \@file_content = ();
            open(TRANS_FILE, \$transcript_file);
            push(\@file_content,<TRANS_FILE>);
            close(TRANS_FILE);

            my \@warnings = ();

            my \$lines = \@file_content;

            my \$i;
            my \$end_of_reset = 0;

            for (\$i=0; \$i< \$lines; \$i++) {

                my \$line = \$file_content[\$i];

                if (\$line =~ m/generating new block/) {
                    \$end_of_reset = 1;
                }

                if (\$end_of_reset == 1) {
                    if (\$line =~ m/Warning:/) {
                        push(\@warnings, \@file_content[\$i..\$i+1]);
                    }
                }
            }

            if (\@warnings > 0) {
                \$warnings = 1;
            }
        }
    ";


    my $reg_run_local_body1 = "
	sub run_matlab(\$\$)
	\{
	    my (\$matlab_command, \$matlab_log) = \@_;

        my \$command = \"matlab /wait -r \\\"try, \$matlab_command; catch, exit; end; exit\\\"\";

	    `\$command -nosplash $minimise_cmd -logfile \$matlab_log`;
	}

	sub main
	{
	   my \$num_blocks;
	   do
	   {
	   		my \$matlab_command = \"cd ../$cml_home;CmlStartup;[sim_param, sim_state]=CmlSimulate(\'\$scenarios_file\',[\$test_case]);\";

	  		run_matlab(\$matlab_command,\"matlog.txt\");
	  		\$num_blocks = `wc -l < \"ctc_blksize.txt\"`;
	   } while(\$num_blocks < $num_test_cases);

	 ";

	my $reg_run_local_body2 = "
	sub test_vector_join()
	{
#		my (\$test_data_dir,\$test_dir,\$tests_ref) = \@_;

		my (\@blocks, \@input_data, \@iter_data, \@output_data);
		my \$input_info_file = \"ctc_blksize.txt\";
		my \$iter_data_file = \"ctc_iter_data.txt\";
		my \$input_data_file = \"ctc_data_input.txt\";
		my \$output_gold_file = \"ctc_decoded_output_gold.txt\";
        my \$output_u_gold_file = \"ctc_output_u_gold.txt\";

        unlink \$iter_data_file if (-f \$iter_data_file);
		unlink \$input_data_file if (-f \$input_data_file);
		unlink \$output_gold_file if (-f \$output_gold_file);
        unlink \$output_u_gold_file if (-f \$output_u_gold_file);

		tie \@blocks, Tie::File, \$input_info_file or die \"Can't tie to \$input_info_file : \$!\\n\";
		tie \@input_data, Tie::File, \$input_data_file or die \"Can't tie to \$input_data_file : \$!\\n\";
		tie \@iter_data, Tie::File, \$iter_data_file or die \"Can't tie to \$iter_data_file : \$!\\n\";
		tie \@output_data, Tie::File, \$output_gold_file or die \"Can't tie to \$output_gold_file : \$!\\n\";
        tie \@output_u_data, Tie::File, \$output_u_gold_file or die \"Can't tie to \$output_u_gold_file : \$!\\n\";

		my \$blk_size;
		my \$block_size;
		my \$input_file;
     	my \$blk_output_gold_file;
        my \$blk_output_u_gold_file;

        my \@file_contents = ();
        my \$num_of_blocks_per_engine;

        my \$iter;

		foreach \$blk_size (\@blocks)
		{

			\$block_size = \$blk_size - 4;
			\$input_file = \"$test_data_dir/ctc_data_input\${block_size}.txt\";
			open(INPUT_FILE,\$input_file) || die \"Can't read file \$input_file\";
			push(\@input_data,<INPUT_FILE>);
			close(INPUT_FILE);

			\$blk_output_gold_file = \"$test_data_dir/ctc_decoded_output_gold\${block_size}.txt\";
			open(OUTPUT_GOLD_FILE,\$blk_output_gold_file) || die \"Can't read file \$blk_output_gold_file\";
			push(\@output_data,<OUTPUT_GOLD_FILE>);
			close(OUTPUT_GOLD_FILE);

            \$blk_output_u_gold_file = \"$test_data_dir/ctc_output_u_gold\${block_size}.txt\";
			open(OUTPUT_U_GOLD_FILE,\$blk_output_u_gold_file) || die \"Can't read file \$blk_output_u_gold_file\";
			push(\@output_u_data,<OUTPUT_U_GOLD_FILE>);
            close(OUTPUT_U_GOLD_FILE);

            \@file_contents = ();
			open(OUTPUT_U_GOLD_FILE,\$blk_output_u_gold_file) || die \"Can't read file \$blk_output_u_gold_file\";
			push(\@file_contents,<OUTPUT_U_GOLD_FILE>);
			close(OUTPUT_U_GOLD_FILE);

            \$num_of_blocks_per_engine = ceil(\$block_size/$num_engines);
            \$iter = ceil(\@file_contents/\$num_of_blocks_per_engine);

            push(\@iter_data, \$iter);
		}
	}
	sub main
	{
	  # prepare the test
		test_vector_join();
	";

	my $reg_run_local_body3 = q<
	   # run ModelSim simulation
	   `vsim -c -do msim.do`;

	   my $pass = !compare_text("ctc_decoded_output_gold.txt", "ctc_decoded_output.txt", sub{$_[0] =~ s/\r$//; $_[0] ne $_[1]});
       $pass = $pass && !compare_text("ctc_output_u_gold.txt", "output_u.txt", sub{$_[0] =~ s/\r$//; $_[0] ne $_[1]});

       parse_transcript();

	   if ($pass && ($warnings == 0))
	   {
		  unlink("FAIL") if (-f "FAIL");
		  `touch PASS`;

	>;

	my $reg_run_local_body4 = q<
		  # delete data files
			my $input_data_file = "ctc_data_input.txt";
			my $output_gold_file = "ctc_decoded_output_gold.txt";
			my $output_file = "ctc_decoded_output.txt";
			my $output_u_file = "output_u.txt";
            my $out_u_gold_file = "ctc_output_u_gold.txt";

			unlink $input_data_file if (-f $input_data_file);
			unlink $output_gold_file if (-f $output_gold_file);
			unlink $output_file if (-f $output_file);
			unlink $output_u_file if (-f $output_u_file);
            unlink $out_u_gold_file if (-f $out_u_gold_file);
	>;

	my $reg_run_local_body5 = q<
		 }
	   else
	   {
		  unlink("PASS") if (-f "PASS");
		  `touch FAIL`;
		  exit(1); # tell ACE this is a failure
	   }
	}

	main();
	>;

	$reg_run_local_head =~ s/^\t//gm;
	$reg_run_local_body0 =~ s/^\t//gm;
	$reg_run_local_body1 =~ s/^\t//gm;
	$reg_run_local_body2 =~ s/^\t//gm;
	$reg_run_local_body3 =~ s/^\t//gm;
	$reg_run_local_body4 =~ s/^\t//gm;
	$reg_run_local_body5 =~ s/^\t//gm;

	print WRITEFILE $reg_run_local_head;

    # always parse_transcript
    print WRITEFILE $reg_run_local_body0;

    if ($reset)
	{
		print WRITEFILE $var_def;
		print WRITEFILE $reg_run_local_body1;
	}
	else
	{
		print WRITEFILE $reg_run_local_body2;
	}

	print WRITEFILE $reg_run_local_body3;
	print WRITEFILE $reg_run_local_body4 if ($clear_data);
	print WRITEFILE $reg_run_local_body5;
	close(WRITEFILE);
}

sub write_modelsim_do_file($)
{
	my ($filename) = @_;
	open(WRITEFILE, ">$filename") || die "Can't open file $filename for writing: $!";

	my $do_file_body = "
		transcript off

		vmap lpm ../../../compiled_libs/lpm
		vmap altera ../../../compiled_libs/altera
		vmap altera_mf ../../../compiled_libs/altera_mf
		vmap sgate ../../../compiled_libs/sgate
		vmap stratixiii ../../../compiled_libs/stratixiii
		vmap auk_dspip_lib ../../../compiled_libs/auk_dspip_lib
		vmap auk_dspip_ctc_umts_lib ../../../compiled_libs/auk_dspip_ctc_umts_lib
		vmap work ../../../compiled_libs/rtl_work

		vsim -t 1ps -L lpm -L altera -L altera_mf -L sgate -L stratixiii -L work work.tb_auk_dspip_ctc_umts_decoder_top
		set StdArithNoWarnings  1
		set NumericStdNoWarnings  1
		run -all
		quit -f
	";

	$do_file_body =~ s/^\t//gm;

	print WRITEFILE $do_file_body;
	close(WRITEFILE);
}

sub write_scenario_file($\@$)
{
	my ($filename,$tests_ref,$test_dir) = @_;

	my $dirname = abs_path(dirname($filename));
	my $basename = basename($filename);
	printf("Writing scenario file $basename to $dirname\n");
	open(WRITEFILE, ">$filename") || die "Can't open file $filename for writing: $!";

	my $scenario_file_head = "load( \'CmlHome.mat\' );

	% determine where to store your files
	base_name = \'umts_rtl\';
	if ispc
    	data_directory = strcat( cml_home, '\\output\\', base_name, '\\' );
	else
    	data_directory = strcat( cml_home, '/output/', base_name, '/' );
	end;
	if ~exist( data_directory, 'dir' )
    	mkdir(data_directory);
	end;

	";

	$scenario_file_head =~ s/^\t//gm;

	print WRITEFILE $scenario_file_head;

	# Only write duplicated tests once
	my %seen = ( );
	my @tests = grep { ! $seen{$_} ++ } @$tests_ref;

	my $count = 0;
	my $block_size;
	my $num_umts_blocks = @umts_blocks;
	my $block_id;
    foreach $block_id (@tests)
    {
    	if ($block_id > $num_umts_blocks)
    	{
    		die "Invalid block id: $block_id!";
    	}

    	$block_size = $umts_blocks[$block_id-1];
 		printf WRITEFILE ("record = %d;\n",$block_id);

#			sim_param(record).dump_dir = [ cml_home,\'/../test\' ]; %[ cml_home,\'/test$block_size/\' ];

 		my $record_content = "
			sim_param(record).comment = \'RTL test: $block_size bits, s-maxlogMAP/8it/8bits\';
			sim_param(record).SNR = 2.0:2.0:2.0;
			sim_param(record).framesize = $block_size;
			sim_param(record).channel = \'awgn\';
			sim_param(record).decoder_type = 5;
			sim_param(record).num_subblocks = 8;
			sim_param(record).dump_input = 1;
			sim_param(record).dump_output = 1;
			sim_param(record).dump_iter = 1;
			sim_param(record).rtl_simulation = 1;
			sim_param(record).dump_dir = \'$test_dir/\';
			sim_param(record).subblock_size = 32;
			sim_param(record).fxp_data_width = [8 2 11 2];
			sim_param(record).max_iterations = 8;
			sim_param(record).plot_iterations = sim_param(record).max_iterations;
			sim_param(record).linetype = \'b-\';
			sim_param(record).sim_type = \'coded\';
			sim_param(record).code_configuration = 1;
			sim_param(record).SNR_type = \'Eb/No in dB\';
			sim_param(record).modulation = \'BPSK\';
			sim_param(record).mod_order = 2;
			sim_param(record).mapping = \'gray\';
			sim_param(record).bicm = 1;
			sim_param(record).demod_type = 0;
			sim_param(record).legend = sim_param(record).comment;
			sim_param(record).code_interleaver = ...
			    strcat( \'CreateUMTSInterleaver(\', int2str(sim_param(record).framesize ), \')\' );
			sim_param(record).g1 = [1 0 1 1;    1 1 0 1];
			sim_param(record).g2 = sim_param(record).g1;
			sim_param(record).nsc_flag1 = 0;
			sim_param(record).nsc_flag2 = 0;
			sim_param(record).pun_pattern1 = [1 1;    1 1];
			sim_param(record).pun_pattern2= [0 0;    1 1 ];
			sim_param(record).tail_pattern1 = [1 1 1;    1 1 1];
			sim_param(record).tail_pattern2 = sim_param(record).tail_pattern1;
			sim_param(record).filename = strcat( data_directory, ...
			    strcat( \'rtl\',int2str(record),  int2str(sim_param(record).framesize ), sim_param(record).channel, sim_param(record).modulation, int2str(sim_param(record).mod_order), int2str(sim_param(record).decoder_type), int2str(sim_param(record).max_iterations), \'.mat\') );
			sim_param(record).reset = 1;
			sim_param(record).max_trials = 1;
			sim_param(record).minBER = 1e-6;
			sim_param(record).max_frame_errors = 40*ones( 1, length(sim_param(record).SNR) );
			sim_param(record).save_rate = ceil(614400/sim_param(record).framesize);

		";

		$record_content =~ s/^\t+//gm;

 		print WRITEFILE $record_content;
	}

	close(WRITEFILE);
}

sub test_vector_join($$\@)
{
	my ($test_data_dir,$test_dir,$tests_ref) = @_;
#	my @tests = (512,528,408,800,40,40,48,56,64,72);

	my (@blocks, @input_data, @output_u, @output_data, @iter_data);
	my $blksize_file = "$test_dir/ctc_blksize.txt";
	my $input_data_file = "$test_dir/ctc_data_input.txt";
	my $output_u_file = "$test_dir/ctc_output_u_gold.txt";
	my $output_gold_file = "$test_dir/ctc_decoded_output_gold.txt";
	my $iter_data_file = "$test_dir/ctc_iter_data.txt";

	unlink $blksize_file if (-f $blksize_file);
	unlink $input_data_file if (-f $input_data_file);
	unlink $output_u_file if (-f $output_u_file);
	unlink $output_gold_file if (-f $output_gold_file);
	unlink $iter_data_file if (-f $iter_data_file);

	tie @blocks, Tie::File, $blksize_file or die "Can't tie to $blksize_file : $!\n";
	tie @input_data, Tie::File, $input_data_file or die "Can't tie to $input_data_file : $!\n";
	tie @output_u, Tie::File, $output_u_file or die "Can't tie to $output_u_file : $!\n";
	tie @output_data, Tie::File, $output_gold_file or die "Can't tie to $output_gold_file : $!\n";
	tie @iter_data, Tie::File, $iter_data_file or die "Can't tie to $iter_data_file : $!\n";

	my $blk_size;
	my @file_contents = ();
	my $num_engines = 4;
	my $iter;

	foreach $blk_size (@$tests_ref)
	{
		push(@blocks, $blk_size+4);

		@file_contents = read_file("$test_data_dir/ctc_data_input${blk_size}.txt");
		push(@input_data,@file_contents);

		@file_contents = read_file("$test_data_dir/ctc_decoded_output_gold${blk_size}.txt");
		push(@output_data,@file_contents);

        @file_contents = read_file("$test_data_dir/ctc_output_u_gold${blk_size}.txt");
        push(@output_u,@file_contents);

        my $num_of_blocks_per_engine = ceil($blk_size/$num_engines);
        $iter = @file_contents/$num_of_blocks_per_engine;

        push(@iter_data,$iter);
	}
}

sub create_and_submit_tests()
{
	my $test;
	my $test_dir;
	my @tests = ();

	my $scenario;
	my $scenario_file;

  	foreach $test (sort keys %records)
  	{
#		$dir = $test_rootdir . "/test${test}_umts_$scenario";
#		$dir = $test_rootdir . "/test$umts_blocks[$test-1]";

		$test_dir = "test${test}";
  		push(@tests, $test_dir);
		$test_dir = $test_rootdir . "/test${test}";

		print "Creating test $test_dir ...\n";

		# remove the directory first
		if (-d $test_dir)
		{
			print "Deleting old directory ...\n";
			rmtree($test_dir,0,1);
		}
		print "Creating test $test ...\n";

		# create a new directory
		mkdir $test_dir;
		my $test_recs_ref = $records{$test};
		my $test_recs_str = join(",", @$test_recs_ref);
		my $num_test_cases = @$test_recs_ref;

#		test_vector_join($test_data_dir,$test_dir,@$test_recs_ref);

		# ------------ write input_info_file only
		my $input_info_file = "$test_dir/ctc_blksize.txt";
		unlink $input_info_file if (-f $input_info_file);

		tie @blocks, Tie::File, $input_info_file or die "Can't tie to $input_info_file : $!\n";

		foreach my $blk_size (@$test_recs_ref)
		{
		  push(@blocks, $blk_size+4);
		}
		# ----------- done input_info_file

		my $test_case_str = "my \$scenarios_file = \"Scenarios_UMTS_RTL${test}\";
		my \$test_case = \"$test_recs_str\";\n";
		$test_case_str =~ s/^\t*//gm;

		write_reg_run_local_rtl("$test_dir/reg_run_local.pl",$test_case_str,$num_test_cases);
		write_modelsim_do_file("$test_dir/msim.do");

    if ($run_tests)
    {

        if ($local)
        {
            chdir $test_dir;
            submit_test($test_dir);
            chdir("..");
        }
        else
        {
            my $timeout = "14400m"; # 10 days
            my $options = "modelsim_se/6.5b, modelsim_se-lic/hdl,dev/perl/5.8.8"; # modelsim/6.4c/se
            chdir $test_dir;
            system("arc submit -t $options os=linux timeout=$timeout \"perl reg_run_local.pl\"");
            chdir("..");
        }
    }
	}

	return @tests;
}

sub submit_test($)
{
	my ($test_dir) = @_;
 	my $timeout = "1440m"; # 1 days
  my $options = "modelsim_se/6.5b, modelsim_se-lic/hdl,dev/perl/5.8.8"; # modelsim/6.4c/se

  print "Submitting test $test_dir ...\n";

#      	if ($count % $num_nodes == 0) {
#      	system("arc submit node/uk-swcf0151 matlab/R2008b matlab-lic/designated-computer/uk-swcf0151 group=matlab1 perl $dir/reg_run_local.pl");
#      	  $options = "node/uk-swcf0151,matlab/R2008b, matlab-lic/designated-computer/uk-swcf0151";
#        } else {
#      	  $options = "node/uk-swcf0154,matlab-lic/designated-computer/uk-swcf0154";
#        }

 	system("perl reg_run_local.pl");
}

sub help()
{
	print STDERR "This script is to run turbo simulation

Usage : perl $0 [options]

Required Options:
     None

Optional Options:
     -help             : print this help message
     -extra_tests      : run extra tests
     -cml_home         : specify cml_home directory (default ../../cml)
     -generate         : re-generate test vectors via MATLAB
     -random           : run random test cases (this would take long to run)
     -start_num_from \# : create the tests from number \#
     -debug            : generate debug data (ctc_output_pw_gold.txt)


Examples:
	 perl $0 -extra 1,2,3
";
}

sub generate_random_test_cases()
{

	my $num_of_tests = 200;
    #my $num_of_tests = scalar(@umts_blocks);
	my $num_of_blocks = 100;
	my $num_of_duplicates = 4;
	my $i;

    my $toggle = 0;

	# For each test, randomly pick 30 blocks from @umts_blocks and duplicate each 0 to 4 times
	for ($i = $start_num_from + 1; $i <= $start_num_from + $num_of_tests; $i++)
	{
        push(@{$records{$test_index}}, @umts_blocks[ map { (rand @umts_blocks) x (1+rand($num_of_duplicates)) } ( 1 .. $num_of_blocks )] );
        $test_index++;
	}
}

sub generate_haris_random_test_cases()
{

	my $num_of_tests = 100;
    #my $num_of_tests = scalar(@umts_blocks);
	my $num_of_blocks = 50;
	my $num_of_duplicates = 4;
	my $i;

    my $toggle = 0;

	# For each test, randomly pick 30 blocks from @umts_blocks and duplicate each 0 to 4 times
	for ($i = $start_num_from + 1; $i <= $start_num_from + $num_of_tests; $i++)
	{
        push(@{$records{$test_index}}, @harris_umts[ map { (rand @harris_umts) x (1+rand($num_of_duplicates)) } ( 1 .. $num_of_blocks )] );
        $test_index++;
	}
}

sub sweep_blk_sizes_test_cases()
{
    my @blocks_to_sweep = (@umts_blocks);
    #my @blocks_to_sweep = (4296, 5114, 4288, 4287, 4286, 4285);

	#my $num_of_tests = @blocks_to_sweep;
    my $num_of_tests = 10;
    my $i;

    my $toggle = 0;

    $test_rootdir = $test_rootdir . "/../sweep_blks/";

	# For each test, randomly pick 30 blocks from @umts_blocks and duplicate each 0 to 4 times
	for ($i = 0; $i < $num_of_tests; $i++)
	{
        push(@{$records{$test_index}}, $blocks_to_sweep[$i] );
        $test_index++;
	}

}

sub generate_lg_sm_test_cases()
{
	my $num_of_tests = 50;
    #my $num_of_tests = scalar(@umts_blocks);
	my $num_of_blocks = 50;
	my $num_of_duplicates = 4;
	my $i;
    my $j;
    my $k;
    my $block;

    my $toggle = true;

	# For each test, randomly pick 30 blocks from @umts_blocks and duplicate each 0 to 4 times
	for ($i = $start_num_from + 1; $i <= $start_num_from + $num_of_tests; $i++)
	{
        for ($j = 0; $j<$num_of_blocks; $j++)
        {
            if ($toggle)
            {
                $block = @umts_blocks_lg[rand(@umts_blocks_lg)];
            }
            else
            {
                $block = @umts_blocks_sm[rand(@umts_blocks_sm)];
            }

            for ($k=0; $k<1+rand($num_of_duplicates); $k++)
            {
                push(@{$records{$test_index}}, $block);
            }
            $toggle = !$toggle;
        }

        $test_index++;
	}

}

sub generate_block_test_cases()
{
	my $num_of_block_tests = 100;

    use List::Util 'shuffle';

	@shuffled_blocks = shuffle(@umts_blocks);
#	@shuffled_blocks = @umts_blocks;

#	@umts_blocks = (40 .. 60);

	# shuffle the blocks
    my $i = $#umts_blocks;
    my $num_blocks_per_test = $i / $num_of_block_tests;

#    while ($i--)
#    {
#    	my $j = int rand ($i+1);
#        @umts_blocks[$i,$j] = @umts_blocks[$j,$i];
#    }

#	print Dumper @shuffled_blocks[0..10]; exit;

	my $first_test = 0;
	my $end_test = 0;
	for ($i = 0; $i < $num_of_block_tests; $i++)
	{
		my $key = $i+1;
		$first_test  = $end_test;
		if ($i == $num_of_block_tests - 1)
		{
			$end_test = $#umts_blocks + 1;
		}
		else
		{
			$end_test  = ceil($key*$num_blocks_per_test);
		}

		$key = $i+$start_num_from+1;
		my $end_id = $end_test - 1;
		push(@{$records{$key}}, @shuffled_blocks[$first_test..$end_id]);

#		print "$i, $first_test, $end_id $key\n";
	}

#	my $key;
#	my @test_cases;
#	foreach $key (sort keys %records)
#	{
#		@test_cases = @{$records{$key}};
#		$records{$key} = ();
#		push(@{$records{$key}}, @test_cases);
#	}

#	print Dumper %records; exit;
}

sub main()
{
	my $root_dir = getcwd();
	my $more_tests;

	GetOptions( 'extra_tests=s' => \$more_tests,
				'cml_home=s' => \$cml_home,
				'test_rootdir=s' => \$test_rootdir,
				'generate' => \$reset,
				'random' => \$random,
				'start_num_from=i' => \$start_num_from,
				'help' => sub { help() and exit; }
	 		  ) or help() and exit;


	if (defined $more_tests)
	{
		%records = ();
		push(@{$records{1}},split(/,/,$more_tests));
	}

    $test_rootdir = getcwd() if (not defined $test_rootdir);
  $test_data_dir = "$test_rootdir/ctc_input_data";


    # clear all cases
	%records = ();
    $test_index = $start_num_from;

	if ($random)
	{
		#generate_random_test_cases();
        #generate_lg_sm_test_cases();
        #generate_haris_random_test_cases();
        sweep_blk_sizes_test_cases();
	}
	else
	{
		generate_block_test_cases();
#		%records = ( 1 => [881,736,404,609,610,117,47,280,944,251] );
	}

	my @new_tests = create_and_submit_tests();
}

main();


