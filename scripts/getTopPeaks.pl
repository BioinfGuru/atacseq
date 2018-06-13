#!/usr/bin/perl 
# Selects the top 100,000 non-overlapping peaks from summits.bed
# Required: MACS2 narrow peaks output summit.bed files - these files MUST be sorted by by position
# Kenneth Condon Mar 2017
###############################################################################
use strict;
use warnings;

# Store the input/output directoy
my $peaks_dir = "/NGS/working_projects/AtacSeq/data/11_peaks/narrow/consensus";
#my $peaks_dir = "/NGS/working_projects/AtacSeq/data/test";
opendir(DIR, $peaks_dir);		
my @all_files = readdir(DIR);
close DIR;

# Parse the file
foreach my $bed(@all_files)
	{
		# Initialise the sliding window variables
		my $line_A = "";		
		my $chr_A;				
		my $UL_A;				
		my $score_A;			
		my $line_B = "";		
		my $chr_B;				
		my $summit_B;			
		my $UL_B;
		my $score_B;			

		# Iterate through each line of each POSITION SORTED summits.bed file
		if ($bed =~ /(.+_narrow_summits)\.bed$/)
			{
				open (OUT, ">$peaks_dir/$1.noverlap.bed");
				open (IN, "$peaks_dir/$bed");
				
				foreach my $new_line(<IN>)
					{
						# store its values
						chomp $new_line;
						my @array = split(/\t+/,$new_line);
						
						# Create the sliding window
						if($line_A eq "")
							{
								# Store line A
								$line_A = $new_line;
								$chr_A = $array[0];
								$UL_A = $array[1]+250;
								$score_A = $array[4];
								next;
							}
						else
							{	
								# Store line B
								$line_B = $new_line;
								$chr_B = $array[0];
								$summit_B = $array[1];
								$UL_B = $array[1]+250;
								$score_B = $array[4];

								# Evaluate first 2 lines of the file
								if (($chr_A ne $chr_B) or ($UL_A < $summit_B)) # if first line is non-overlapping
									{
										print OUT "$line_A\n";
										$line_A = $line_B;
										$chr_A = $chr_B;
										$UL_A = $UL_B;
										$score_A = $score_B;
									}
								elsif ($score_B > $score_A) # if first line is overlapping but B has highest score
									{
										$line_A = $line_B;
										$chr_A = $chr_B;
										$UL_A = $UL_B;
										$score_A = $score_B;
									}
							}
					}
				# The final best peak is not printed yet	
				print OUT "$line_A\n";
				close IN;
				close OUT;
			}
	}
