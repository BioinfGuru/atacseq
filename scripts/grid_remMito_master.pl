#!/usr/bin/perl 
# Runs bash command to remove mitochondrial reads from the bam files
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# Store the slave script
my $slave_script = "/NGS/working_projects/AtacSeq/scripts/grid_remMito_slave.pl";

# Store input directory
#my $bams_in = "/NGS/working_projects/AtacSeq/data/10_bams_nodups";
my $in = "/NGS/working_projects/AtacSeq/data/test";

# Store output directory
my $out = "/NGS/working_projects/AtacSeq/data/11_bams_noMito";

# Submit jobs to the grid
opendir(DIR, $in);		
my @all_files = readdir(DIR);
close DIR;
#my $count = 0;
foreach my $x(@all_files)
	{
		chomp $x;
		if ($x =~ /^(.+)\.dedup\.bam$/)
			{
				#$count++;
				#print "$1\n";
        		system "qsub -cwd -j y -b yes -P NGS -N $1 -o $out -q small.q $slave_script $1";
			}
	}
#print "$count\n";

##################################################################################################################
exit;