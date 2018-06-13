# !/usr/bin/perl 
# Recieves input from merge_fastq_master.pl to merge fastq.gz files
# Requires: merge_fastq_A.pl
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# Store input directory
my $wd = "/NGS/users/Kenneth/ATAC/data/1_fastq_files/";

# Store the zcat output directory
my $zcat_out = "/NGS/users/Kenneth/ATAC/data/2_merged_fastq_files/";

# Recieve input from merge_fasta_A.pl
my $key = "$ARGV[0]";

# Merge the files
system"zcat $wd/$key*_1.fastq.gz | gzip -c > $zcat_out/$key.1.fq.gz";
system"zcat $wd/$key*_2.fastq.gz | gzip -c > $zcat_out/$key.2.fq.gz";