#!/usr/bin/perl 
# Takes nucleoatac output files and creates bed files which is then converted to bigBed for UCSC Track Hub
# Required: nfrpos.bed, nucmap_combined.bed
# Kenneth Condon Apr 2017
###############################################################################
use strict;
use warnings;

# Store the nucleoatac input files
#my $nuc_dir = "/NGS/working_projects/AtacSeq/data/test";
my $nuc_dir = "/NGS/working_projects/AtacSeq/data/13_nucleoatac";
opendir(DIR, $nuc_dir);		
my @all_files = readdir(DIR);
close DIR;
my @beds;
foreach my $x(@all_files){if (($x =~ m/(.+\.nucmap_combined)\.bed\.gz$/) or ($x =~ m/(.+\.nfrpos)\.bed\.gz$/)){push (@beds, "$nuc_dir"."/"."$x");}}

# Parse each bed file
foreach my $bed(@beds)
	{
		if ($bed =~ m/(.+)\.bed\.gz/)
			{
				# create a temp bed file for conversion to bigbed
				system "gzip -d $bed; cut -f 1-3 $1.bed >$1.temp; gzip $1.bed";

				# create the bigbed file
 				system "sort -k1,1 -k2,2n $1.temp >$1.sorted";
 				my $chr_size = "/NGS/musRefs_10/mm10_chr_size.txt";
 				system "bedToBigBed -tab $1.sorted $chr_size $1.bb; rm $1.temp $1.sorted";
			}
	}
exit;