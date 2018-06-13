#!/usr/bin/perl 
# Creates normalized peak signal track bigwig files for each sample from a consensus set of peaks
# Normalisation by fold enrichment, log likelihood or poisson q-value
# Required: *treat_pileup.bdg, *control_lambda.bdg, *.bed, mm10_chr_size.txt
# NB: Dont delete the bed files! you need them for calculating poisson q-value
# Kenneth Condon Mar 2017
############################################################################################
use strict;
use warnings;

# Slave script
my $slave_script = "/NGS/working_projects/AtacSeq/scripts/grid_macs2bdg_slave.pl";

# Look at broad or narrow peaks? enter "broad" or "narrow"
my $peak_type = "narrow";

# Input bed file directory
#my $beds_dir = "/NGS/working_projects/AtacSeq/test/10_beds";
my $beds_dir = "/NGS/working_projects/AtacSeq/data/10_beds";

# Output bigwig directory
#my $bigwigs_dir = "/NGS/working_projects/AtacSeq/test/11_peaks/ind/$peak_type/bigwigs";
my $bigwigs_dir = "/NGS/working_projects/AtacSeq/data/11_peaks/ind/$peak_type/bigwigs";

# Submit jobs to the grid
opendir(DIR, $beds_dir);
my @all_files = readdir(DIR);
close DIR;
foreach my $x(@all_files)
	{
		chomp $x;
		if ($x =~ /^(.+)\.bed$/)
			{
				system "qsub -cwd -j y -b yes -P NGS -N $1 -o $bigwigs_dir -pe big 6 $slave_script $1 $peak_type"; # on big q
				# 8-10 hr runtime, not parallelised but needs memory from 6 cores
			}
	}