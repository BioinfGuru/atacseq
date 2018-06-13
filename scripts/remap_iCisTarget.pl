# !/usr/bin/perl 
# converts icisTarget target.bed output files from mm9 to mm10
# Kenneth Condon July 2017
#################################################################################################################
use strict;
use warnings;

# Print usage:
print "\nUSAGE:\tperl remap_iCistarget.pl <pathToBedfiles>\nNOTE 1:\tThe path must start with /home/k.condon/ not /home/kcondon/\nNOTE 2:\tRename folders with spaces in the name e.g. TF_binding_sites\nNOTE 3: This will not overwrite mm10.bed files... delete them first\n\n";

# Path to bedfiles
my $wd = "$ARGV[0]";

# Store the bed files
opendir(DIR, $wd);	
my @folder = readdir(DIR);
close DIR;

# # Process the bedfiles
foreach my $bedfile(@folder)
	{
		if ($bedfile =~ m/(.+).targets.bed$/)
			{
				print "Processing $bedfile\n";
				#system "sed -i '/track/d' $wd/$bedfile"; # removes UCSC file header
				#system "perl /home/k.condon/NGS_new/Software/Factory/New_remap/remap_api.pl --mode asm-asm --from GCF_000001635.18 --dest GCF_000001635.20 --annotation $wd/$bedfile --annot_out $wd/$1.targets.mm10.bed --in_format bed"; # run remap
				system "sed -i '/NT_/d' $wd/$1.targets.mm10.bed"; # removes NT contigs
			}
	}
