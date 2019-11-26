#!perl -w

use strict;
use Config;
use lib map { /(.*)/ } split /$Config{path_sep}/ => $ENV{DSPIP_TEST};
use Cwd;
use test_submitter_package;
use File::Path;
use Getopt::Long;

my %records = 
	(
		huawei => [1..8]
#		huawei => [101,102,103,104,105,106,107,108,109,110,111,112]
#		huawei => '1,2,4,5,6,7,9,10,13,14,15,16'
#		huawei => '9,10,13,14,16'
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
	
	        my \$command = \"matlab /wait -r \\\"try, \$matlab_command; catch exit; end; exit\\\"\";
	
	        `\$command -nosplash -nodesktop -logfile \$matlab_log`;
	
	}
	
	sub main
	{
	   my \$matlab_command = \"cd ../../;CmlStartup;[sim_param, sim_state]=CmlSimulate(\'\$scenarios_file\',[\$test_case]);\";
	
	   my \@logs;
	   my \$filename = \"matlog.txt\";
	   my \$grep_str;
	   
	   do
	   {
	   	 run_matlab(\$matlab_command,\$filename);
	     \$grep_str = `grep \"Elapsed time\" \$filename`;
	   } while (length(\$grep_str) == 0);
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
	
	my $scenario;
  
  	foreach $scenario (keys %records) {
#    	my @recs = split(/,/, $records{$scenario});
		my $recs_ref = $records{$scenario};
		foreach $test (@$recs_ref)
		{
			$dir = "test${test}_lte_$scenario";
		
			# remove the directory first
			rmtree($dir,1,1) if (-d $dir);
			
			# create a new directory
			mkdir $dir;
			
			my $test_case_str = "my \$scenarios_file = \"Scenarios_LTE_${scenario}\";
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

sub help()
{
	print STDERR "This script is to run turbo simulation

Usage : perl $0 [options]

Required Options:
     None

Optional Options:
     -help        : print this help message
     -extra_tests   : run extra tests

Examples:
	 perl $0 -extra 1,2,3
";
}

sub submit_tests($\@)
{
	my ($test_xml_file,$tests) = @_;
	
	print "##########################################################################\n";
	print "# Submitting tests: turbo simulations   \n";
	print "##########################################################################\n";
	
	my $test_root =	getcwd();
	my $test_list = join(',', @$tests);
	
	test_submitter_package->start_submitter("-xml_file=$test_xml_file -timeout=2880m -test_list=$test_list -test_id=turbo_lte_sim -test_root=$test_root");
}
	
sub main()
{
	my $root_dir = getcwd();
	my $more_tests;

	GetOptions( 'extra_tests=s' => \$more_tests,
	 			'help' => sub { help() and exit; }
	 		  ) or help() and exit;
	
	if (defined $more_tests)
	{
		$records{huawei} = ();
		push(@{$records{huawei}},split(/,/,$more_tests));
	}
	
	my $xml_file = "turbo_tests_lte_huawei.xml";
	my @new_tests = create_tests($xml_file);

	submit_tests($xml_file,@new_tests);
}

main();
	

