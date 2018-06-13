#!/usr/bin/perl 
# Uses MACS2 to call narrow, broad and gapped peaks on sets of bed files
# Kenneth Condon Feb 2017
#################################################################################################################
#$HOSTNAME = `hostname -s`; 
#print "$HOSTNAME\n";
use strict;
use warnings;
use File::Path 'make_path';

# store the path to MACS2 (on the grid)
my $macs2 = "/usr/bin/macs2";

# Store input directory
my $in = "/NGS/working_projects/AtacSeq/data/10_beds";

# Store output directories
my $narrow_out = "/NGS/working_projects/AtacSeq/data/11_peaks/ind/narrow";
my $broad_out = "/NGS/working_projects/AtacSeq/data/11_peaks/ind/broad";

# Pass jobs to the grid
opendir(DIR, $in);		
my @all_files = readdir(DIR);
close DIR;
foreach my $x(@all_files)
	{
		chomp $x;
		if ($x =~ /(.+)\.bed$/)
			{
        		system "qsub -cwd -j y -b yes -P NGS -N $1 -o $narrow_out -q small.q $macs2 callpeak --format BED --treatment $in/$x --nomodel --shift -100 --extsize 200 --qvalue 0.001 --cutoff-analysis --gsize mm --bdg --SPMR --keep-dup all --outdir $narrow_out --name $1.narrow --call-summits";
        		system "qsub -cwd -j y -b yes -P NGS -N $1 -o $broad_out -q small.q $macs2 callpeak --format BED --treatment $in/$x --nomodel --shift -100 --extsize 200 --qvalue 0.001 --gsize mm --bdg --SPMR --keep-dup all --outdir $broad_out --name $1.broad --broad --broad-cutoff 0.001";
			}
	}