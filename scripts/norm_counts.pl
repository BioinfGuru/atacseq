#!/usr/bin/perl 
# normalises raw read counts by number of properly mapped reads
# Required:
# 1) sequencing_depth.txt file from checking bam file stats
# 2) all_peaks_ra_counts.txt file from bedtools multicov
# Kenneth Condon Mar 2017
###############################################################################
use strict;
use warnings;

# Store the scaling factor for each sample (total number of properly mapped reads divided by 1 million)
my %depth;
open (IN, "/NGS/working_projects/AtacSeq/data/9_bams/sequencing_depth.txt");
foreach my $line(<IN>)
	{
		chomp $line;
		if ($line =~ /^(.+)\.nodup.nomito.bam.stats:(\d+)/)
			{
				chomp $1;
				chomp $2;
				my $scale = $2/1000000;
				$depth{$1} = ($scale);
			}
	}	
close IN;

# Normalise raw read counts by number of properly mapped reads
open (IN, "/NGS/working_projects/AtacSeq/data/11_peaks/narrow/consensus/test.txt");
foreach my $peak(<IN>)
	{
		chr1	3119706	3119707	consensus.narrow_peak_6a	1429.02344	98	91	41	56	67	85	57	14	101	76	71	66	109	105	70	8	110	82	39	85	64	61	45	14	75	71	32	63	115	76	56	8
		my @array = split(/\t+/,$peak);
	}