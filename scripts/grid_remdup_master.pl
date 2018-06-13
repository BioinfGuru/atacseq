# !/usr/bin/perl 
# Runs Picard tools on the GRID to remove duplicates from BAM files
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# Store the slave script
my $slave_script = "/NGS/working_projects/AtacSeq/scripts/grid_remdup_slave.pl";

# Store input directory
my $bams_in = "/NGS/working_projects/AtacSeq/data/9_bams";
#my $bams_in = "/NGS/working_projects/AtacSeq/data/test_rmdup";

# Store output directory
my $bams_out = "/NGS/working_projects/AtacSeq/data/10_bams_nodups";

# Use grid to run picard tools on bam files
opendir(DIR, $bams_in);		
my @all_files = readdir(DIR);
close DIR;
#my $count = 0;
foreach my $x(@all_files)
	{
		chomp $x;
		#if ($x =~ /^(m.+)\.bam$/)
		#if ($x =~ /^(mswatd4)\.bam$/)
			{
				#$count++;
				#print "$1\n";
        		system "qsub -cwd -j y -b yes -P NGS -N $1 -o $bams_out -pe big 4 perl $slave_script $1";
			}
	}
#print "$count\n";

##################################################################################################################
exit;