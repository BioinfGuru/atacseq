# !/usr/bin/perl 
# Renames all ATAC file names
# Kenneth Condon Feb 2017
#################################################################################################################
use strict;
use warnings;
use File::Copy; # qw(move);

#################################################################################################################
######################################### CREATE A TEST FOLDER ##################################################
#################################################################################################################
# # Read in all file names 
# opendir(DIR, "data/");		
# my @files = readdir(DIR);
# close DIR;

# # create a test folder with identical filenames but all are empty text files
# mkdir 'test';
# system 'chmod -R 777 test/';
# foreach my $file(@files)
# 	{

# 		open(OUT,">test/$file");
# 		#print $file, "\n";
# 		close OUT;
# 	}
#################################################################################################################
#################################################################################################################
#################################################################################################################

# Create a hash to store the ID and Sample names
my %hash = ();
open (IN, "filenames.tsv");
foreach my $line(<IN>)
	{
		chomp $line;								
		my @array = split(/\t/,$line);			# split each line of the file by tab	
		$hash{$array[0]} = ($array[1]);			# store the ID (keys) and Sample names (values)
		delete ($hash {ID});					# remove the header
	}	

# Read in the old file names 
opendir(DIR, "data/");		
my @old_file_names = readdir(DIR);
my @fastq_1_files;
foreach my $file(@old_file_names)
	{
		if ($file =~ /^WTCHG_\d{6}_\d{2}_1\.fastq\.gz/)
			{
				chomp $file;
				push (@fastq_1_files, $file);
			}
	}
close DIR;

# Rename the fastq_1 files first (to correctly count replicates)
my @used;
my $new_name;
foreach my $old_name(@fastq_1_files)
	{
		chomp $old_name;
		if ($old_name =~ /^WTCHG_(\d{6}_\d{2})(_1\.fastq\.gz)/)
			{
				# get the sample name for the ID
				my $id = $1;
				my $sample = $hash{$1};

				# change the name of each replicate
				my $occurances = grep { $_ eq $sample } @used;
				
				if ($occurances == 0) # For replicate 1
					{
						push (@used, $sample);
						move ("data/$old_name", "data/$sample"."_R1_".$1.$2);

						# Search for the ID in the directory to find all other files for this replicate
						foreach my $file(@old_file_names)
							{
								# rename the fastq_2 file
								if ($file =~ /^WTCHG_($id)(_2\.fastq\.gz)/){move ("data/$file", "data/$sample"."_R1_".$id.$2);}

								# rename the remaining files
								if ($file =~ /^WTCHG_($id)(\..+)/){move ("data/$file", "data/$sample"."_R1_".$id.$2);}
							}
					}

				elsif ($occurances == 1) # for replicate 2 # 674
					{
						push (@used, $sample);
						move ("data/$old_name", "data/$sample"."_R2_".$1.$2);
						
						# Search for the ID in the directory to find all other files for this replicate
						foreach my $file(@old_file_names)
							{
								# rename the fastq_2 file
								if ($file =~ /^WTCHG_($id)(_2\.fastq\.gz)/){move ("data/$file", "data/$sample"."_R2_".$id.$2);}

								# rename the remaining files
								if ($file =~ /^WTCHG_($id)(\..+)/){move ("data/$file", "data/$sample"."_R2_".$id.$2);}
							}
					}

				elsif ($occurances == 2) # For replicate 3 # 917
					{
						push (@used, $sample);
						move ("data/$old_name", "data/$sample"."_R3_".$1.$2);
						
						# Search for the ID in the directory to find all other files for this replicate
						foreach my $file(@old_file_names)
							{
								# rename the fastq_2 file
								if ($file =~ /^WTCHG_($id)(_2\.fastq\.gz)/){move ("data/$file", "data/$sample"."_R3_".$id.$2);}

								# rename the remaining files
								if ($file =~ /^WTCHG_($id)(\..+)/){move ("data/$file", "data/$sample"."_R3_".$id.$2);}
							}

				 	}


			}
	}