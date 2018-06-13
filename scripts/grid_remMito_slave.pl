#!/usr/bin/perl 
# Runs a bash command on the GRID to remove mitochondrial reads from BAM files
# Kenneth Condon Feb 2017
#################################################################################################################
#$HOSTNAME = `hostname -s`; 
#print "$HOSTNAME\n";
use strict;
use warnings;

# Store input directory
#my $in = "/NGS/working_projects/AtacSeq/data/10_bams_nodups";
my $in = "/NGS/working_projects/AtacSeq/data/test";

# Store output directory
my $out = "/NGS/working_projects/AtacSeq/data/11_bams_noMito";

# Recieve input from grid_sam2sortedbam_master.pl
my $key = "$ARGV[0]";

# Run bash commands to remove mito reads
my $non_chrM_list=`samtools view -H mswatd-1.dedup.bam | grep chr | cut -f2 | sed 's/SN://g' | grep -v chrM`;

#print "non_chrM_list=$(samtools view -H mswatd-1.dedup.bam | grep chr | cut -f2 | sed 's/SN://g' | grep -v chrM)\n";
print "samtools view -b mswatd-1.dedup.bam $non_chrM_list -o mswatd-1_no_mito.bam\n";

##################################################################################################################
exit;