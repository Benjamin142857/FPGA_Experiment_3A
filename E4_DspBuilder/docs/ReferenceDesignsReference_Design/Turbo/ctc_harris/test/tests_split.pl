#!perl -w

use Cwd;
use Cwd 'abs_path';
use File::Path;
use File::Basename;
use Getopt::Long;
use Tie::File;
use Fcntl;
#use strict;

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
	my @file_contents;

	while(<FILE>)
	{
		chomp;
		push(@file_contents, $_);
	}
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

sub test_split()
{
	use POSIX qw(ceil floor);
	my (@blocks, @input_data, @output_u, @output_data, @iter_data);
	my $blksize_file = "ctc_blksize.txt";
	my $input_data_file = "ctc_data_input.txt";
	my $output_u_file = "ctc_output_u_gold.txt";
	my $output_gold_file = "ctc_decoded_output_gold.txt";
	my $iter_data_file = "ctc_iter_data.txt";

	tie @blocks, Tie::File, $blksize_file or die "Can't tie to $blksize_file : $!\n";
	tie @input_data, Tie::File, $input_data_file or die "Can't tie to $input_data_file : $!\n";
	tie @output_u, Tie::File, $output_u_file or die "Can't tie to $output_u_file : $!\n";
	tie @output_data, Tie::File, $output_gold_file or die "Can't tie to $output_gold_file : $!\n";
	tie @iter_data, Tie::File, $iter_data_file or die "Can't tie to $iter_data_file : $!\n";

	my $num_engines = 4;
	my $data_count = 0;
	my ($count, $iter);
	my $blk_count = 0;
	my ($data_size,$blksize);
	my $id_count = 0;
	my $out_u_count = 0;
	foreach $data_size (@blocks)
	{
		my $blksize = $data_size - 4;

		$count = $data_count + $data_size;
		
		my $filename = "split/ctc_data_input${blksize}.txt";
		open(FILE, ">$filename") || die "Can't open file $filename for writing: $!";
	
		while( $data_count < $count)
		{
			print FILE "$input_data[$data_count]\n";
			$data_count++;
		}
		close (FILE);
		
		$count = $blk_count + $blksize;
		$filename = "split/ctc_decoded_output_gold${blksize}.txt";
		open(FILE, ">$filename") || die "Can't open file $filename for writing: $!";
	
		while( $blk_count < $count)
		{
			print FILE "$output_data[$blk_count]\n";
			$blk_count++;
		}
		close (FILE);
		
		$iter = $iter_data[$id_count];

		$count = $out_u_count + ceil($blksize/$num_engines)*$iter;
		$filename = "split/ctc_output_u_gold${blksize}.txt";
		open(FILE, ">$filename") || die "Can't open file $filename for writing: $!";
	
		while( $out_u_count < $count)
		{
			print FILE "$output_u[$out_u_count]\n";
			$out_u_count++;
		}
		close (FILE);
		
		$id_count++;

#		printf("%d %d %d %d\n",$id_count,$blksize, $count, ceil($blksize/$num_engines));
	}
}

sub test_join()
{
#	my @tests = (512,528,408,800,40,40,48,56,64,72);
	my @tests = (1577,3158,2458,2693,1249,2781,3292,336,4136,298,4480,4486,2321,421,2824,579,4917,4269,4245,2910,171,5097,1851,586,5088,3520,1480,4525,453,2065,496,905,934,3110,3535,4545,3423,3667,4087,3012,472,3524,4333,4776,3288,2796,5112,2268,2980,152,3727);

	my (@blocks, @input_data, @output_u, @output_data, @iter_data);
	my $blksize_file = "join/ctc_blksize.txt";
	my $input_data_file = "join/ctc_data_input.txt";
	my $output_u_file = "join/ctc_output_u_gold.txt";
	my $output_gold_file = "join/ctc_decoded_output_gold.txt";
	my $iter_data_file = "join/ctc_iter_data.txt";

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
	my @file_contents;
	my $num_engines = 2;
	my $iter;

	foreach $blk_size (@tests)
	{
		push(@blocks, $blk_size+4);

		@file_contents = read_file("split/ctc_data_input${blk_size}.txt");
		push(@input_data,@file_contents);

		@file_contents = read_file("split/ctc_decoded_output_gold${blk_size}.txt");
		push(@output_data,@file_contents);

		@file_contents = read_file("split/ctc_output_u_gold${blk_size}.txt");
		push(@output_u,@file_contents);

		$iter = @file_contents/ceil($blk_size/$num_engines);
		push(@iter_data,$iter);

	}
}

sub main()
{
	my $test_join = 0;

	GetOptions( 'join' => \$test_join,
	 			'help' => sub { help() and exit; }
	 		  ) or help() and exit;

	if ($test_join)
	{
		test_join();
	}
	else
	{
		test_split();
	}


#print @iter_data;
}

main();
