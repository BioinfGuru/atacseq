# !/usr/bin/perl 
# Kenneth Condon May 2017
###########################################################################################
use strict;
use warnings;

# samtools
my $samtools = "/NGS/Software/samtools-1.3.1/samtools";

# bam files
my $ufbams = "/NGS/working_projects/AtacSeq/test/9_bams/unfiltered";

# output directory
my $sams = "/NGS/working_projects/AtacSeq/test/8_sams";

# sample name
my $sample = "$ARGV[0]";

# To convert UNfiltered BAM back to SAM
system "$samtools view -h $ufbams/$sample.bam > $sams/$sample.sam"

###########################################################################################
