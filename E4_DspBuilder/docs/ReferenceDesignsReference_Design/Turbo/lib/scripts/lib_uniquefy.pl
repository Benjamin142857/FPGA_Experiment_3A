#!perl -w
#
###########################################################################################
#
# This script is for making DSPIP library entity names to be core and version specific
#
# Authors:  Zhengjun Pan
#
# Copyright (c) Altera Corporation 2007
# All rights reserved.
#
###########################################################################################
#
# $Log: lib_uniquefy.pl,v $
# Revision 1.8  2008/04/01 13:11:20  lrigby
# SPR: 268856/267066 - Filtered fb and cb from the version string so that the uniqification does not append fb/cb to the end of the filenames.
#
# Revision 1.7  2007/11/08 21:26:32  zpan
# if core_name and ver aren't defined, just copy files
#
# Revision 1.6  2007/02/02 14:51:56  zpan
# don't remove comments as they may be synthesis attributes
#
# Revision 1.5  2007/01/09 13:38:34  zpan
# lib_dirs are passed through arguments, so the script aren't limited to specific cores
#
# Revision 1.4  2007/01/09 10:40:44  zpan
# a minor update
#
# Revision 1.3  2007/01/05 23:49:28  zpan
# a minor update
#
# Revision 1.2  2007/01/05 23:35:55  zpan
# convert all .vhd/.v/.ocp files in the listed directories
#
# Revision 1.1  2007/01/04 17:00:42  zpan
# first revision
#
#

use strict;
use Time::localtime;

# command line options processing
use Getopt::Long;
use Data::Dumper;
use FileHandle;
use File::Copy;

my @file_contents;

my $debug = 0;

my @lib_dirs = ();
my @lib_files = ();


my %entity_name_map = ();

my ($libdirs,$dst_dir,$core_name,$ver);

sub help()
{
	print STDERR "This script is for making DSPIP library entity names to be core and version specific

Usage : perl $0 [options]

Required Options:
    -core_name core       : Core name
    -version ver          : Release version number
    -libdirs dir          : Library paths, separated by ';'
    -dst_dir dir          : A directory where the generated files will be saved to
		 			
Optional Options:
    -help        : print this help message
    -debug       : print debug messages

Examples:
	 perl $0 -core_name CIC -ver 7.1 -libdirs ../fu/avalon_streaming/rtl;../fu/delay/rtl;../fu/roundsat/rtl;../fu/fastaddsub/rtl;../packages;../../CIC/src/rtl -dst ../../CIC/src/lib

";
}

sub read_src_file ($)
{
	my $src_file = shift;
	
	open(SRC_FH, "< $src_file") || die "Can't read file $src_file: $!";
	
	@file_contents = <SRC_FH>;
	
	close(SRC_FH);
}

sub replace_and_write($)
{
	my $src_file = shift;
	
	my ($entity_name,$file_ext) = $src_file =~ /\/*([\w]+)\.(\w+)$/;
	
	my $dst_file = "$dst_dir/${entity_name}_${core_name}_$ver.$file_ext";
	
	open(DST_FH, "> $dst_file") || die "Can't read file $dst_file: $!";
	
	my $new_entity_name;
	
	foreach(@file_contents)
	{
		# skip comment lines in .vhd file
#		next if (/^\s*--/ && $file_ext =~ /^vhd$/i);

		# skip comment lines in .v file
#		next if (/^\/\// && $file_ext =~ /^v$/i);
		
		foreach $entity_name (keys %entity_name_map)
		{
			$new_entity_name = $entity_name_map{$entity_name};
		
			# replace $entity_name with $new_entity_name
			s/\b$entity_name\b/$new_entity_name/g;
		}
		
		print DST_FH $_;
	}
	
	close(DST_FH);
}

# Get an array of vhd/v/ocp files in the directory
sub get_dir_lib_files($)
{
	my $libdir = shift;
	
	opendir (DIR, $libdir) || die "Can't open directory $libdir for reading: $!";

	# Only care about .vhd, .v, .ocp files
	my @dirfiles = grep { /\.(vhd|v|ocp)$/i } readdir(DIR);
	closedir(DIR);
	
	return @dirfiles;
}

sub process_lib_dir($)
{
	my $lib_dir = shift;

	# Get .vhd, .v, .ocp files
	my @dir_files = get_dir_lib_files($lib_dir);

	foreach (@dir_files)
	{
		process_lib_file($lib_dir,$_);
	}
}

sub build_entity_name_map()
{
	my $entity_name;

	# For each file in @lib_files, its entity_name is renamed	
	foreach (@lib_files)
	{
		($entity_name) = /([\w]+)\.\w+$/;
	
		$entity_name_map{$entity_name} = "${entity_name}_${core_name}_$ver";
	}
}

sub add_files_to_lib_files($)
{
	my $libdir = shift;

	# Get .vhd, .v, .ocp files
	my @dir_files = get_dir_lib_files($libdir);

	# adding files in the directory to @lib_files
	push(@lib_files, @dir_files);
}

sub process_lib_file($$)
{
	my ($src_dir,$src_file) = @_;

	my ($file_ext) = $src_file =~ /[\w]+\.(\w+)$/;

	# Replace \ with /
	$src_file =~ s/\\/\//g;
	
	my $dst_file = "$dst_dir/$src_file";

	# attach $src_dir to $src_file
	$src_file = "$src_dir/$src_file";
	
	if (defined $core_name and defined $ver)
	{
		read_src_file($src_file);

		replace_and_write($src_file);
	}
	else
	{
		# delete the destination file if it exists.
		unlink $dst_file if (-f $dst_file);
			
		copy($src_file,$dst_file) or die "Copy $src_file to $dst_file failed: $!";
	}
}	

sub main
{
	GetOptions(	'libdirs=s' => \$libdirs,
	 			'dst_dir=s' => \$dst_dir,
	 			'core_name=s' => \$core_name,
	 			'version=s' => \$ver,
	 			'debug' => \$debug,
	 			'help' => sub { help() and exit; }
	 		  ) or help() and exit;

	help() and exit unless (defined $libdirs and 
							defined $dst_dir);

	# Convert core name to lower cases
	$core_name = lc($core_name) if (defined $core_name);
	
	# Remove . in version number
	$ver =~ s/\.//g if (defined $ver);
	
	# Remove cb from version number
	$ver =~ s/cb//g if (defined $ver);

	# Remove fb from version number
	$ver =~ s/fb//g if (defined $ver);

	# Replace \ with /
	$dst_dir =~ s/\\/\//g;
	
	unless (-d $dst_dir)
	{
		print "Directory $dst_dir does not exist. Making directory $dst_dir ...\n" if $debug;
		mkdir $dst_dir || die "Can't make directory $dst_dir: $!"
	}
	
	# Get lib directories from string $libdirs
	@lib_dirs = split(/;/, $libdirs);
	
	# Read files in all directories and add them to @lib_files
	foreach (@lib_dirs)
	{
		add_files_to_lib_files("$_");
	}

	if (defined $core_name and defined $ver)
	{
		build_entity_name_map();
	}	
	
	foreach (@lib_dirs)
	{
		process_lib_dir($_);
	}
}

main();