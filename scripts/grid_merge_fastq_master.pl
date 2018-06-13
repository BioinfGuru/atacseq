# !/usr/bin/perl 
# Merge fastq.gz files via the grid NB: grid can't hand the ">" operator so you must tell it to run merge_fastq_B.pl
# Requires: grid_merge_slave.pl
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# Store input directory
my $wd = "/NGS/users/Kenneth/ATAC/data/1_fastq_files/";
opendir(DIR, $wd);		
my @all_fastq_files = readdir(DIR);
close DIR;

# Store the zcat output directory
my $zcat_out = "/NGS/users/Kenneth/ATAC/data/2_merged_fastq_files/";

# Store all sample names
my %samples;
foreach my $file(@all_fastq_files)
	{
		chomp $file;
		if ($file =~/^(.+)_R\d.+_(\d)\.fastq\.gz$/) 
			{
			$samples{$1} = ();
			}
	}

# Merge on grid
foreach my $key (keys %samples) 
	{
		print $key, "\n";
		system "qsub -cwd -j y -b yes -P NGS -N $key.1 -o $zcat_out -q small.q perl /NGS/users/Kenneth/ATAC/data/grid_merge_fastq_slave.pl $key";
	}

exit;