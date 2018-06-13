#!/usr/bin/perl 
# Creates fold enrichment, log likelihood and poisson q-value signal tracks as bigwig files
# Required: *treat_pileup.bdg, *control_lambda.bdg, *.bed, mm10_chr_size.txt
# Kenneth Condon Mar 2017
############################################################################################
use strict;
use warnings;
use File::Copy qw(move);

# Look at broad or narrow peaks? enter "broad" or "narrow"
my $peak_type = "narrow";

# Input chromosome size file - for required mm10_chr_size.txt
my $chr_size = "/NGS/musRefs_10/mm10_chr_size.txt";

# bigwig directory
#my $bigwig_dir = "/NGS/working_projects/AtacSeq/test/11_peaks/ind/$peak_type/bigwigs";
my $bigwig_dir = "/NGS/working_projects/AtacSeq/data/11_peaks/ind/$peak_type/bigwigs";

# Convert bdg to bw
opendir(DIR, $bigwig_dir);		
my @all_files = readdir(DIR);
close DIR;
my $total = `ls $bigwig_dir/*bdg | wc -l`;
chomp $total;
print "$total\n";
my $count = 0;
foreach my $bdg(@all_files)
 	{
 		chomp $bdg;
 		if ($bdg =~ /^(.+)\.bdg$/)
			{
				$count++;
				print "Creating bigwig $count/$total: $1.bw\n";
				system "bedtools slop -i $bigwig_dir/$bdg -g $chr_size -b 0 | bedClip stdin $chr_size $bigwig_dir/$bdg.clip";
				system "bedGraphToBigWig $bigwig_dir/$bdg.clip $chr_size $bigwig_dir/$bdg.bw";
				move "$bigwig_dir/$bdg.bw", "$bigwig_dir/$1.bw";
			}	
	}

############################################################################################
exit;