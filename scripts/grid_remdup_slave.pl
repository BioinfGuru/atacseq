# !/usr/bin/perl 
# Runs Picard tools on the GRID to remove duplicates from BAM files
# Kenneth Condon Feb 2017
#################################################################################################################
#$HOSTNAME = `hostname -s`; 
#print "$HOSTNAME\n";
use strict;
use warnings;

# Store the path of the picard tools
my $MarkDuplicates = "/usr/java/latest8/bin/java -XX:ParallelGCThreads=4 -jar /NGS/Software/picard/build/libs/picard.jar MarkDuplicates";

# Store input directory
my $bams_in = "/NGS/working_projects/AtacSeq/data/9_bams";
#my $bams_in = "/NGS/working_projects/AtacSeq/data/test_rmdup";

# Store output directory
my $bams_out = "/NGS/working_projects/AtacSeq/data/10_bams_nodups";

# Recieve input from grid_sam2sortedbam_master.pl
my $key = "$ARGV[0]";

# Run picard tools on bam files
system "$MarkDuplicates I=$bams_in/$key.bam O=$bams_out/$key.dedup.bam M=$bams_out/$key.metrics REMOVE_DUPLICATES=true ASSUME_SORTED=true";	# when running on grid

##################################################################################################################
exit;



# To run MarkDuplicates on Utah
# java -Xmx8g -jar /NGS/Software/picard-tools-1.76/MarkDuplicates.jar I=in.bam O=out.bam M=out.metrics.txt REMOVE_DUPLICATES=true ASSUME_SORTED=true