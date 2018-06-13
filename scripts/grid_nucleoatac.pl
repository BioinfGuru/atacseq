#!/usr/bin/perl 
# Runs nucleoatac on ATAC-seq broad peak files to identify nucleosome positions
# Required files:
#	1. sorted + indexed BAM files (.bam + .bam.bai)
#	2. indexed reference genome fasta file (.fa + .faidx)
#	3. processed broadPeak file
# Kenneth Condon Mar 2017
############################################################################################
use strict;
use warnings;

# my $HOSTNAME = `hostname -s`; 
# print "$HOSTNAME\n";

# path to nucleoatac binary
#my $path = "/usr/local/sbin/miniconda2/bin/nucleoatac";

# Input bam files path
# my $bam_dir = "/NGS/working_projects/AtacSeq/data/test_grid_nucleoatac";
my $bam_dir = "/NGS/working_projects/AtacSeq/data/9_bams";

# Input reference genome file path
my $genome = "/NGS/musRefs_10/ref_mm10.fasta";

# Input broadPeak file
my $peaks = "/NGS/working_projects/AtacSeq/data/11_peaks/broad/consensus/final.broadPeak";

# Output directory
# my $out_dir = "/NGS/working_projects/AtacSeq/data/test_grid_nucleoatac";
my $out_dir = "/NGS/working_projects/AtacSeq/data/11_peaks/broad/consensus/nucleoatac";

# Submit jobs to the grid
opendir(DIR, $bam_dir);
my @all_files = readdir(DIR);
close DIR;

###############
# Store the names of the remaining bam files in an array 
my @remaining_bams = ('mswatd2.bam', 'mmswat.bam', 'mmgwat.bam', 'mgwatt4.bam', 'mgwatd4.bam', 'mgwatd1.bam', 'fswatt4.bam', 'fswatd-1.bam', 'fswatd7.bam', 'fswatd2.bam', 'fswatd1.bam', 'fgwatt4.bam', 'fgwatd-1.bam', 'fgwatd7.bam', 'fgwatd4.bam', 'fgwatd1.bam', 'fgwatd0.bam');
my $count = 0;
###############

# foreach my $x(@all_files)
foreach my $x(@remaining_bams)
	{
		chomp $x;
		if ($x =~ /^(.+)\.bam$/)
			{
				# $count++;
				
				# print "$count\t$x\t$1\n";
		        
		        # print "qsub -cwd -j y -b yes -P NGS -N $1 -o $out_dir -pe big 16 -p -500 nucleoatac run --bed $peaks --bam $bam_dir/$x --fasta $genome --out $1 --cores 16\n";
		        
		        system "qsub -cwd -j y -b yes -P NGS -N $1 -o $out_dir -pe big 16 -p -500 nucleoatac run --bed $peaks --bam $bam_dir/$x --fasta $genome --out $1 --cores 16";
			}
	}