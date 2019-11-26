#!perl -w

use strict;
use Config;
use lib map { /(.*)/ } split /$Config{path_sep}/ => $ENV{DSPIP_TEST};
use Cwd;
use Cwd 'abs_path';
use POSIX qw(ceil floor);
#use test_submitter_package;
use File::Path;
use File::Basename;
use Getopt::Long;

my @umts_blocks = (40 .. 5114);

my @pass = ();
my @fail = ();

my @pass_u = ();
my @fail_u = ();

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

sub read_file($)
{
	my $filename = $_[0];
	open(FILE, $filename) || die "Can't read file $filename: $!";
	my @file_contents = <FILE>;
	close (FILE);

	return @file_contents;
}

sub write_file($\@)
{
	my ($filename, $file_contents_ref) = @_;
	open(FILE, ">$filename") || die "Can't open file $filename for writing: $!";

	foreach (@$file_contents_ref)
	{
		print FILE "$_\n";
	}

	close (FILE);
}

sub do_design()
{
	my @rtl_output = read_file("ctc_decoded_output.txt");
	my @gold_output = read_file("ctc_decoded_output_gold.txt");
	my @blk_sizes = read_file("ctc_blksize.txt");

	if ($#rtl_output != $#gold_output)
	{
		return;
	}

	my $block_size;
	my $i;
	my $sum = 0;

	my $pwd = getcwd();
	my $num_blocks = @blk_sizes;
	my $num_pass_dir = 0;
	my $num_fail_dir = 0;

	foreach (@blk_sizes)
	{
		chomp;
		$block_size = $_ - 4;

		my $res_diff = 0;

		for($i = $sum; $i < $sum + $block_size; $i++)
		{
			if ($gold_output[$i] != $rtl_output[$i])
			{
				$res_diff = 1;
				last;
			}
		}

		$sum += $block_size;

		if ($res_diff)
		{
			push(@fail, $block_size);
			$num_fail_dir++;
		}
		else
		{
			push(@pass, $block_size);
			$num_pass_dir++;
		}
	}

    print "$pwd: $num_blocks, $num_pass_dir passed, $num_fail_dir failed\n";
}

sub do_design_u()
{
	my @rtl_output = read_file("output_u.txt");
	my @gold_output = read_file("ctc_output_u_gold.txt");
    my @iter = read_file("ctc_iter_data.txt");
	my @blk_sizes = read_file("ctc_blksize.txt");

	if ($#rtl_output != $#gold_output)
	{
		return;
	}

	my $block_size;
	my $i;
	my $sum = 0;

	my $pwd = getcwd();
	my $num_blocks = @blk_sizes;
	my $num_pass_dir = 0;
	my $num_fail_dir = 0;

    my $index = 0;

	foreach (@blk_sizes)
	{
		chomp;
		$block_size = $_ - 4;

        my $expected_lines = $iter[$index++]*(ceil($block_size/4));

		my $res_diff = 0;

		for($i = $sum; $i < $sum + $expected_lines; $i++)
		{

            my $j;
            my @split1 = split(/ /, $gold_output[$i]);
            my @split2 = split(/ /, $rtl_output[$i]);

            if (@split1 == @split2)
            {
                for($j=0; $j<@split1; $j++){
                    if ($split1[$j] != $split2[$j])
                    {
                        $res_diff = 1;
                    }
                }
            }
            else {
                $res_diff = 1;
            }

            if ($res_diff == 1) {
                last;
            }
		}

		$sum += $expected_lines;

		if ($res_diff)
		{
			push(@fail_u, $block_size);
			$num_fail_dir++;
		}
		else
		{
			push(@pass_u, $block_size);
			$num_pass_dir++;
		}
	}

    print "$pwd: u_output: $num_blocks, $num_pass_dir passed, $num_fail_dir failed\n";
}

sub write_pass_fail()
{
	@pass = sort { $a <=> $b } @pass;
	@fail = sort { $a <=> $b } @fail;
	write_file("pass.txt",@pass);
	write_file("fail.txt",@fail);

	my $num_passed = @pass;
	my $num_failed = @fail;
	my $total_blocks = $num_passed + $num_failed;

	if ($total_blocks > 0)
	{
        print("Decoded output pass fail summary:");
		printf("#total: %d, #passed: %d, #failed: %d, Passing rate: %.2f\n",
			$total_blocks, $num_passed, $num_failed, $num_passed/$total_blocks);
	}
}

sub write_pass_fail_u()
{
	@pass_u = sort { $a <=> $b } @pass_u;
	@fail_u = sort { $a <=> $b } @fail_u;
	write_file("pass_u.txt",@pass_u);
	write_file("fail_u.txt",@fail_u);

	my $num_passed = @pass_u;
	my $num_failed = @fail_u;
	my $total_blocks = $num_passed + $num_failed;

	if ($total_blocks > 0)
	{
        print("Output u pass fail summary:");
		printf("#total: %d, #passed: %d, #failed: %d, Passing rate: %.2f\n",
			$total_blocks, $num_passed, $num_failed, $num_passed/$total_blocks);
	}
}

sub parse_transcript()
{
    my $transcript_file = "transcript";
    my @file_content = ();
    open(TRANS_FILE, $transcript_file);
    push(@file_content,<TRANS_FILE>);
    close(TRANS_FILE);

    my @warnings = ();

    my $lines = @file_content;

    my $i;
    my $end_of_reset = 0;

    for ($i=0; $i< $lines; $i++) {

        my $line = $file_content[$i];

        if ($line =~ m/generating new block/) {
            $end_of_reset = 1;
        }

        if ($end_of_reset == 1) {
            if ($line =~ m/Warning:/) {
                push(@warnings, @file_content[$i..$i+1]);
            }
        }
    }

    if (@warnings > 0) {
        print("Warnings observed in test at: ", getcwd(), "\n");
        print(" -> See warnings.txt in testdir for details\n");
        write_file("warnings.txt",@warnings);
    }
    else
    {
        print("No warnings in test:", getcwd());
    }
}

sub main()
{
	my $cur_dir = getcwd();

#	GetOptions( 'extra_tests=s' => \$more_tests,
#				'cml_home=s' => \$cml_home,
#				'test_rootdir=s' => \$test_rootdir,
#	 			'help' => sub { help() and exit; }
#	 		  ) or help() and exit;


    opendir (RES, $cur_dir) || die "Can't open results directory";
	my @designs = readdir(RES);
	closedir(RES);

    # use below to force only looking at one or more testdirs
    #@designs = ("test7", "test8", "test17", "test30", "test34", "test39", "test41", "test43", "test44");

    my $count = 0;


	foreach ( sort @designs )
	{
    	next if /^\.\.?$/;   # skip . and ..
    	next unless (-d);    # skip normal files
    	next unless (/^test/i); # folder should start with "test"
		$count++;

		my $design_dir = $_;

    	# change to the design dir
    	chdir $design_dir;

    	do_design() if (-f "ctc_decoded_output.txt");
        do_design_u() if (-f "output_u.txt");

        parse_transcript() if (-f "transcript");

		# return to the results dir
		chdir "..";
	}

	write_pass_fail();
    write_pass_fail_u();
}

main();
