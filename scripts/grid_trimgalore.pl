# !/usr/bin/perl 
# Pass multiple trim_galore jobs to the grid
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# Store input directory
my $wd = "/NGS/working_projects/AtacSeq/data/2_merged_fastq_files";
opendir(DIR, $wd);		
my @fastq = readdir(DIR);
close DIR;

# Store trim_galore output directory
my $trim_galore_out = "/NGS/working_projects/AtacSeq/data/5_trimmed";

# Read the paired fastq files into a hash
my %hash;
foreach my $f1(@fastq)
	{
		if ($f1 =~ /^(.+)\.1(\.fq\.gz)$/)
			{			
				my $f2 = $1.".2".$2;
				$hash{$f1} = ($f2);
			}
	}

# Pass each key/value pair to the grid for trim galore 
my $count = 0;
while ((my $fq1, my $fq2) = each (%hash))
	{
		if ($fq1 =~ /^(.+)\.1(\.fq\.gz)$/)
			{
				$count++;
				# system "qsub -cwd -j y -b yes -P NGS -N $1 -o $grid_out -q small.q trim_galore --paired --retain_unpaired -o $trim_galore_out $wd/$fq1 $wd/$fq2";
				print "qsub -cwd -j y -b yes -P NGS -N $1 -o $trim_galore_out -q small.q trim_galore --paired --retain_unpaired -o $trim_galore_out $wd/$fq1 $wd/$fq2\n";

			}
	}

print "$count jobs sent to grid\n";

