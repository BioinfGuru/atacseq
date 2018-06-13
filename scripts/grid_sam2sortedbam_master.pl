# !/usr/bin/perl 
# Runs samtools on the GRID to convert sam to sorted bam files
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# samtools
my $samtools = "/NGS/Software/samtools-1.3.1/samtools";

# slave script
my $slave = "/NGS/working_projects/AtacSeq/scripts/grid_sam2sortedbam_slave.pl";

# sam files
my $sams = "/NGS/working_projects/AtacSeq/data/8_sams";
opendir(DIR, $sams);		
my @all_files = readdir(DIR);
close DIR;

# grid report output directory
my $bams = "/NGS/working_projects/AtacSeq/data/9_bams";

# Convert sam to bam
foreach my $sam(@all_files)
	{
		if ($sam =~ /(.+)\.sam/)
			{
        		system "qsub -cwd -j y -b yes -P NGS -N $sam -o $bams -pe big 10 perl $slave $1";
			}
	}
