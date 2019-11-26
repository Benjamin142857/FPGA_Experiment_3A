#!perl -w

use strict;
use Config;
use lib map { /(.*)/ } split /$Config{path_sep}/ => $ENV{DSPIP_TEST};
use Cwd;
use test_submitter_package;
use File::Path;

# BER vs Window size (S) (# Parallel Windows = 8)
# 20: S = 256
# 21: S = 128
# 22: S = 64
# 23: S = 16
# 24: S = 32
#my @BERtests = (1..24);
#my @BERtests = (1,2,5,6,9,10,13,14,17,18,21,22);
#my @BERtests = (3,4,7,8,11,12,15,16,19,20,23,24);

my %full_records = 
	(
		  64 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		 256 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		1024 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		4096 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		6144 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'
	);

my %records = 
	(
		  64 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		 256 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		1024 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		4096 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24',
		6144 => '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24'
	);

sub read_file($)
{
	my $filename = $_[0];
	open(FILE, $filename) || die "Can't read file $filename: $!";
	my @file_contents = <FILE>;
	close (FILE);
	
	return @file_contents;
}

sub write_reg_run_local($$)
{
	my ($filename, $var_def) = @_;
	open(WRITEFILE, ">$filename") || die "Can't open file $filename for writing: $!";
	
	my $reg_run_local_head = "\#\!perl -w
	\#
	\# This script is auto-generated
	\#

	use strict;
	
	";
	
	my $reg_run_local_body = "
	sub run_matlab(\$\$)
	\{
	        my (\$matlab_command, \$matlab_log) = \@_;
	
	        my \$command = \"matlab -r \\\"try \$matlab_command; catch exit; end; exit\\\"\";
	
	        `\$command -nosplash -nodesktop -logfile \$matlab_log`;
	
	}
	
	sub main
	{
	   my \$matlab_command = \"cd ../../;CmlStartup;[sim_param, sim_state]=CmlSimulate(\'\$scenarios_file\',[\$test_case]);\";
	
	   run_matlab(\$matlab_command,\"matlog.txt\");
	}
	
	main();
	";
	
	$reg_run_local_head =~ s/^\t//gm;
	$reg_run_local_body =~ s/^\t//gm;

	print WRITEFILE $reg_run_local_head;
	print WRITEFILE $var_def;
	print WRITEFILE $reg_run_local_body;
	close(WRITEFILE);
}

sub create_tests($)
{
	my ($test_xml_file) = @_;
	my $test;
	my $dir;
	my @tests = ();
	
	my $blocksize;
  
  	foreach $blocksize (keys %records) {
    	my @records = split(/,/, $records{$blocksize});
		foreach $test (@records)
		{
			$dir = "test${test}_lte_rfp_$blocksize";
		
			# remove the directory first
			rmtree($dir,1,1) if (-d $dir);
			
			# create a new directory
			mkdir $dir;
			
			my $test_case_str = "my \$scenarios_file = \"Scenarios_LTE_RFP_${blocksize}bits\";
			my \$test_case = $test;\n";
			$test_case_str =~ s/^\t*//gm;

			write_reg_run_local("$dir/reg_run_local.pl",$test_case_str);
        
      		push(@tests, $dir);
    	}
	}

	open(XMLFILE, ">$test_xml_file") || die "Can't open file $test_xml_file for writing: $!";
	
	print XMLFILE "<\?xml version=\"1.0\"\?>\n<reg_test_suite>\n";
	
	foreach $test (@tests)
	{
 		print XMLFILE "<test name=\"$test\">\n";
    	print XMLFILE "<test_loc>$test</test_loc>\n";
    	print XMLFILE "<description>Test: $test</description>\n";
    	print XMLFILE "<script>perl reg_run_local.pl</script>\n";
   		print XMLFILE "</test>\n\n";
	}
	
	print XMLFILE "</reg_test_suite>\n";
	close(XMLFILE);
	
	return @tests;
}

sub submit_tests($\@)
{
	my ($test_xml_file,$tests) = @_;
	
	print "##########################################################################\n";
	print "# Submitting tests: turbo simulations   \n";
	print "##########################################################################\n";
	
	my $test_root =	getcwd();
	my $test_list = join(',', @$tests);
	
	test_submitter_package->start_submitter("-xml_file=$test_xml_file -timeout=2880m -test_list=$test_list -test_id=turbo_lte_rfp -test_root=$test_root");
}
	
sub main()
{
	my $root_dir = getcwd();
	
	my $xml_file = "turbo_tests_lte_rfp.xml";
	my @new_tests = create_tests($xml_file);

	submit_tests($xml_file,@new_tests);
}

main();
	

