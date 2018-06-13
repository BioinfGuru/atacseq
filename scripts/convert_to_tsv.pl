# !/usr/bin/perl 
# Converts space separated file to tab separated file --> then sorts the tab separated file by a specified column
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;

# Store usage options #######################################################################################
use Getopt::Long;

my ($input_file_name, $output_file_name, $help) = "";

GetOptions(
			'help' => \$help,
    		'i=s' => \$input_file_name,
    		'o=s' => \$output_file_name
			);

if(!$input_file_name or !$output_file_name) { print "\n MISSING ARGUMENTS : Give all the required options\n" ; &useage ;}

sub useage { die(qq/
	USAGE : perl <script> <arguments>
	ARGUMENTS : 
                    REQUIRED
                    -i -> input file name
                    -o -> output file name
                    OPTIONAL
                    -help -> prints this help message

               \n/);
			}

if($help) { &useage ;}

###############################################################################################################


# Convert space separated file to tab separated file
open (OUT, ">$output_file_name");
print OUT "ID", "\t", "Sample", "\t", "Count", "\n";

open (IN, "$input_file_name");
foreach my $line(<IN>)
	{
		chomp $line;
		my @array = split(/\s+/,$line);
		
		if ($array[0] =~ /^WTCHG_(.+)/)
			{$array[0] = $1}

		if ($array[1] =~ /^Sample:(.+)/)
			{$array[1] = $1}

		if ($array[2] =~ /^Count:(.+)/)
			{$array[2] = $1}

		my $string = join ("\t",@array);	
		print OUT $string, "\n";
	}
close IN;