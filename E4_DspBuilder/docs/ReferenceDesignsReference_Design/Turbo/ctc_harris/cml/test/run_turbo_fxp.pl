#!perl -w

use strict;
use Config;
use lib map { /(.*)/ } split /$Config{path_sep}/ => $ENV{DSPIP_TEST};
use Cwd;
use test_submitter_package;

# BER vs Window size (S) (# Parallel Windows = 8)
# 20: S = 256
# 21: S = 128
# 22: S = 64
# 23: S = 16
# 24: S = 32
my @BERtests = (20,21,22,23,24);
my @file_contents;

my $test_xml_file = "turbo_tests_fxp.xml";

my @tests = ();

sub read_file($)
{
	my $filename = $_[0];
	open(FILE, $filename) || die "Can't read file $filename: $!";
	@file_contents = <FILE>;
	close (FILE);
}

sub write_to_file($\@)
{
	my ($filename, $contents) = @_;
	open(WRITEFILE, ">$filename") || die "Can't open file $filename for writing: $!";
	
	foreach (@$contents)
	{
		print WRITEFILE;
	}
	
	close(WRITEFILE);
}

sub create_tests()
{
	my $test;
	my $dir;
	
	read_file("test1_fxp/reg_run_local.pl");
	foreach $test (@BERtests)
	{
		$dir = "test${test}_fxp";
		
		unless (-d $dir)
		{
			mkdir $dir;
		}

		foreach (@file_contents)
		{
			s/CmlSimulate\(\'SWScenarios\',\[\d+\]\)/CmlSimulate\(\'SWScenarios_fxp\',\[$test\]\)/;
		}
		
		write_to_file("$dir/reg_run_local.pl",@file_contents);
        
        push(@tests, $dir);
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
}

sub submit_tests()
{
	print "##########################################################################\n";
	print "# Submitting tests: turbo simulations   \n";
	print "##########################################################################\n";
	
	my $test_root =	getcwd();
	my $test_list = join(',', @tests);
	
	test_submitter_package->start_submitter("-xml_file=$test_xml_file -test_list=$test_list -test_id=1 -test_root=$test_root");
}
	
sub main()
{
	create_tests();

	submit_tests();
}

main();


  
