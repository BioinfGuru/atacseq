#!/usr/bin/perl 
# Takes chromhmm bed files, sorts them and converts them to bigBed for UCSC Track Hub
# Required: *d0_dense.mod.mm10.bed, mm10_chr_size.txt
# Kenneth Condon Apr 2017
###############################################################################
use strict;
use warnings;

# Store the chromhmm bed files
#my $chromhmm_dir = "/NGS/working_projects/AtacSeq/data/test";
#my $chromhmm_dir = "/NGS/users/Sid/MikkelsenAnalysis/ChromHmm/LearnModel/State_14/Dense_mod/mm10/ForUcscHub";
my $chromhmm_dir = "/NGS/working_projects/MikkelsenData/HumanChromHMM/ChromHMM/LearnModel/State_14/Dense_mod/hg18Tomm9/mm9Tomm10";
opendir(DIR, $chromhmm_dir);		
my @all_files = readdir(DIR);
close DIR;
my @beds;
#foreach my $x(@all_files){if ($x =~ m/^(.+)_dense\.mod\.mm10\.bed$/){push (@beds, "$chromhmm_dir"."/"."$x");}} # for mouse
foreach my $x(@all_files){if ($x =~ m/^(.+)_mm10\.bed$/){push (@beds, "$chromhmm_dir"."/"."$x");}} # for human

# Parse each bed file
foreach my $bed(@beds)
	{
		if ($bed =~ m/(.+)_mm10\.bed/)
			{	
				# create a temp file with only chr1-22|X|Y
				open (IN, $bed);
				open (OUT, ">$bed.temp");
				foreach my $line(<IN>)
					{
						chomp $line;
						if (($line =~ /random/) or ($line =~ /chrUn/)){next;}
						else{print OUT "$line\n";}
 					}

 				# create the big bed file
 				system "sort -k1,1 -k2,2n $bed.temp >$bed.sorted";
 				my $chr_size = "/NGS/musRefs_10/mm10_chr_size.txt";
 				system "bedToBigBed -tab $bed.sorted $chr_size $1.bb; rm $bed.temp $bed.sorted";
			}
	}
exit;