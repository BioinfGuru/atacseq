# !/usr/bin/perl 
# Runs Bowtie2 on paired trimmed fq files on the GRID
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# Store the bowtie2 path
my $bowtie2 = "/NGS/Software/bowtie2-2.3.0/bowtie2";

# Store input directory
my $wd = "/NGS/working_projects/AtacSeq/data/5_trimmed/last";
opendir(DIR, $wd);		
my @all_files = readdir(DIR);
close DIR;

# Store the bowtie2 index directory
my $index = "/NGS/musRefs_10";

# Store the bowtie2 output directory
my $bowtie2_out = "/NGS/working_projects/AtacSeq/data/8_sams";

# Store all sample names
my %hash;
foreach my $file(@all_files)
	{
		chomp $file;
		if ($file =~ /(.+)\.1_val_1\.fq\.gz/)
			{
				$hash{$1} = ();
			}
	}


#Align with bowtie2 on the grid
foreach my $key (keys %hash) 
	{
		my $fq_1 = "$key.1_val_1.fq.gz";
		my $fq_2 = "$key.2_val_2.fq.gz";
        system "qsub -cwd -j y -b yes -P NGS -N $key -o $bowtie2_out/ -pe big 10 $bowtie2 -p 10 --very-sensitive -X 2000 --no-mixed --no-discordant -x $index/ref_mm10 -1 $wd/$fq_1 -2 $wd/$fq_2 -S $bowtie2_out/$key.sam";
	}

exit;