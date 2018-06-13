# !/usr/bin/perl 
# Runs samtools on the GRID to convert unfiltered bam files to sam files
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# samtools
my $samtools = "/NGS/Software/samtools-1.3.1/samtools";

# slave script
my $slave = "/NGS/working_projects/AtacSeq/scripts/grid_bam2sam_slave.pl";

# bam files
my $ufbams = "/NGS/working_projects/AtacSeq/test/9_bams/unfiltered";
opendir(DIR, $ufbams);		
my @all_files = readdir(DIR);
close DIR;

# grid report output directory
my $sams = "/NGS/working_projects/AtacSeq/test/8_sams";

# Convert sam to bam
foreach my $bam(@all_files)
	{
		if ($bam =~ /(.+)\.bam/)
			{
        		system "qsub -cwd -j y -b yes -P NGS -N $bam -o $sams -pe big 10 perl $slave $1";
			}
	}
