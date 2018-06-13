# !/usr/bin/perl 
# parse i regulon file to get TFs regulating each gene name
# Requirements: iregulon_result.tsv and gene_list.tsv
# Kenneth Condon Jan 2017
#################################################################################################################
use strict;
use warnings;

# Store usage options #######################################################################################
use Getopt::Long;

my ($gene_list,$ireg, $help) = "";

GetOptions(
			'help' => \$help,
    		'g=s' => \$gene_list,
    		'r=s' => \$ireg
			);

if(!$ireg or !$gene_list) { print "\n MISSING ARGUMENTS : Give all the required options\n" ; &useage ;}

sub useage { die(qq/
	USAGE : perl <script> <arguments>
	ARGUMENTS : 
                    REQUIRED
                    -g -> input gene_list.txt file
                    -r -> input iregulon.tsv file
                    OPTIONAL
                    -help -> prints this help message

               \n/);
			}

if($help) { &useage ;}

###############################################################################################################

# create an outfile
open OUT, ">gene_regulators.txt";

# parse the infile
open (IN, $gene_list);
foreach my $gene(<IN>)
	{
		chomp($gene);
		$gene =~ s/\r//g;	# removes return character at end of line

		# create an array to store the TFs
		my @TFs;

		#search the iregulon results file for TFs for that gene
		open (IN2, $ireg);
		while (<IN2>)
			{
		 		if ($_ =~ m/^(\d+)/)
		 			{
		 				# split the line by the tab delimiter
		 				my @line = split("\t", $_);

		 				# Is the gene name in the list of genes?
		 				if ($line[6] =~ /($gene)/)
		 					{
		 						if ($line[5] =~ /^$/) # if novel
									{
										# Avoid duplicating Motifs in the output
										my $count_TF = grep { $_ eq $line[5] } @TFs;
										if ($count_TF == 0)
											{
												push (@TFs, $line[1]);
											}	
									}
								else # if known
									{
										# Avoid duplicating TFs in the output
										my $count_TF = grep { $_ eq $line[5] } @TFs;
										if ($count_TF == 0)
											{
												push (@TFs, $line[5]);
											}
									}
		 					}
		 			}
			}
		my $TF_string=join (",", @TFs);
		print OUT "$gene\t", $TF_string, "\n";
	}