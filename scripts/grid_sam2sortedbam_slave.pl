# !/usr/bin/perl 
# Recieves input from grid_sam2sortedbam_master.pl to convert sam files to sorted bam files
# Kenneth Condon Feb 2017
###########################################################################################
use strict;
use warnings;

# samtools
my $samtools = "/NGS/Software/samtools-1.3.1/samtools";

# sam files
my $sams = "/NGS/working_projects/AtacSeq/data/8_sams";

# output directories
my $bams = "/NGS/working_projects/AtacSeq/data/9_bams/temp";
my $fbams = "/NGS/working_projects/AtacSeq/data/9_bams/filtered";
my $ufbams = "/NGS/working_projects/AtacSeq/data/9_bams/unfiltered";

# sample name
my $sample = "$ARGV[0]";

# create filtered bam file
#system "$samtools sort -n -@ 10 -T $bams/$sample $sams/$sample.sam -o - | $samtools fixmate -r - - | $samtools view -u -q 30 - -o - | $samtools sort -l 9 -@ 10 -T $bams/$sample-final - -o $fbams/$sample.bam";

#create UNfiltered bam file (sorts by coordinates first)
#system "$samtools sort -l 9 -@ 10 -T $bams/$sample $sams/$sample.sam -o $ufbams/$sample.bam"

###########################################################################################

# SEPARATED working commands in UTAH

#SORT by NAME (needed for fixmate)
#samtools sort -n -@ 32 -T temp/mswatd1 mswatd1.sam -o mswatd1_name_sorted.sam

#FIXMATES and REMOVE UNMAPPED READS
#samtools fixmate -r mswatd1_name_sorted.sam mswatd1_fixed.sam 

# VIEW to REMOVE MAPQ<30
#samtools view -u -q 30 mswatd1_fixed.sam -o mswatd1_mapq.sam

#SORT BY COORDINATE + CONVERT TO BAM
#samtools sort -l 9 -@ 32 -T temp/mswatd1 mswatd1_mapq.sam -o mswatd1.bam

# To convert UNfiltered BAM back to SAM
system "$samtools view -h $ufbams/$sample.bam > $sams/$sample.bam"

###########################################################################################
