#!/usr/bin/perl 
# Creates fold enrichment, log likelihood and poisson q-value signal tracks as bigwig files
# Required: *treat_pileup.bdg, *control_lambda.bdg, *.bed, mm10_chr_size.txt
# Kenneth Condon Mar 2017
############################################################################################
use strict;
use warnings;
use File::Copy qw(move);

# store the path to MACS2 + bedClip (on the grid)
my $macs2 = "/usr/bin/macs2";
my $bedClip = "/NGS/Software/blat_src/userApps/bin/bedClip";

# Sample name
my $prefix = "$ARGV[0]";

# Look at broad or narrow peaks? enter "broad" or "narrow"
my $peak_type = "$ARGV[1]";

# Input chromosome size file
my $chr_size = "/NGS/musRefs_10/mm10_chr_size.txt";

# Input beds directory
#my $beds_dir = "/NGS/working_projects/AtacSeq/test/10_beds";
my $beds_dir = "/NGS/working_projects/AtacSeq/data/10_beds";

# Input peaks directory
#my $peaks_dir = "/NGS/working_projects/AtacSeq/test/11_peaks/ind/$peak_type";
my $peaks_dir = "/NGS/working_projects/AtacSeq/data/11_peaks/ind/$peak_type";

# Output bigwigs directory
#my $bigwigs_dir = "/NGS/working_projects/AtacSeq/test/11_peaks/ind/$peak_type/bigwigs";
my $bigwigs_dir = "/NGS/working_projects/AtacSeq/data/11_peaks/ind/$peak_type/bigwigs";

###########################################################################################
# Create signal tracks + convert to bigwig
###########################################################################################

# bdgcmp command to create bedgraphs for conversion to bigwig
my $bdgcmp = "$macs2 bdgcmp -t $peaks_dir/$prefix.$peak_type"."_treat_pileup.bdg -c $peaks_dir/$prefix.$peak_type"."_control_lambda.bdg --o-prefix $bigwigs_dir/$prefix";
#my $bdg;

# calculate scaling factor for poisson p/qpois bigwigs
my $nmr = `wc -l <$beds_dir/$prefix.bed`;	#####
chomp $nmr;									# counts reads per million in bed file used in callpeak -t option
$nmr=$nmr/1000000;							#####

# create the signal track bedgraphs
system "$bdgcmp -m FE";											
system "$bdgcmp -m logLR -p 0.0000000001";								
system "$bdgcmp -m ppois -S $nmr";										
system "$bdgcmp -m qpois -S $nmr";									

############################################################################################
exit;