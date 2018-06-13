#!/usr/bin/perl 
# Takes diffbind reports and creates matrices (for creating heatmaps) and bed files (for creating bigbeds for UCSC Track Hub)
# Required: *diffbind_reports.txt, mm10_chr_size.txt
# Kenneth Condon Apr 2017
###############################################################################
use strict;
use warnings;

# report directory
my $report_dir = "/NGS/working_projects/AtacSeq/data/12_diff_binding/reports"; 
opendir(DIR, $report_dir);
my @all_files = readdir(DIR);
close DIR;

# count reports
my $total = 0;
foreach my $report(@all_files){if ($report =~ m/^(.+)_diffbind_report.txt$/){$total++;}}

# outfile directory
my $out = "/NGS/working_projects/AtacSeq/data/12_diff_binding";

###############
# Pair matrices
###############

# store sample names
my @samples = qw "mswatd-1 mswatd0 mswatt4 mswatd1 mswatd2 mswatd4 mswatd7 mmswat fswatd-1 fswatd0 fswatt4 fswatd1 fswatd2 fswatd4 fswatd7 fmswat mgwatd-1 mgwatd0 mgwatt4 mgwatd1 mgwatd2 mgwatd4 mgwatd7 mmgwat fgwatd-1 fgwatd0 fgwatt4 fgwatd1 fgwatd2 fgwatd4 fgwatd7 fmgwat";
print "Creating pair matrix...\n";

# create sample matrix
open AMX, ">$out/pair_all_matrix.txt";
open UMX, ">$out/pair_up_matrix.txt";
open DMX, ">$out/pair_down_matrix.txt";

# print header (tab separated)
foreach my $scolname(@samples){print AMX "\t$scolname"; print UMX "\t$scolname"; print DMX "\t$scolname";}
print AMX "\n";
print UMX "\n";
print DMX "\n";

# # populate each cell, 1 line at a time
my $sfile = 0;
foreach my $sx(@samples)
	{ 
		print AMX "$sx";
		print UMX "$sx";
		print DMX "$sx";

 		foreach my $y(@samples)
			{
				my $report = "$sx"."_v_"."$y"."_diffbind_report.txt";
				my $exists = grep { $_ eq $report } @all_files;
				if ($sx eq $y) {print AMX "\t0"; print UMX "\t0"; print DMX "\t0";}	# print 0 where the 2 samples are the same
				elsif ($exists == 0) {print AMX "\tNA"; print UMX "\tNA"; print DMX "\tNA";}	# print NA if comparison doesn't exist
				else
					{	
						# count the number of lines that meet the conditions:
						$sfile++;
						print "- counting $sfile/$total\n";
						open (IN, "$report_dir/$report") or die "$report doesn't exist in this folder!\n";
						my $Acount = 0;
						my $Ucount = 0;
						my $Dcount = 0;
						foreach my $line(<IN>)
 							{	
 								# filter to include only lines where p value is less than 0.05 and...
 								my @in = split(/\t+/,$line);
 								if ($in[0] =~ /^seqnames/){next;}
 								if ((($in[8] <= -1.5) or ($in[8] >= 1.5)) and ($in[9]<0.05)){$Acount++;} # ... fold change is at least +/- 1.5
 								if (($in[8] >= 1.5) and ($in[9]<0.05)){$Ucount++;}                       # ... fold change is at least + 1.5 (upregulated)
 								if (($in[8] <= -1.5) and ($in[9]<0.05)){$Dcount++;}						 # ... fold change is at least - 1.5 (downregulated)	
 							}
 						print AMX "\t$Acount";
 						print UMX "\t$Ucount";
  						print DMX "\t$Dcount"; 						
					}
			}
 		# start a new row
 		print AMX "\n";
 		print UMX "\n";
 		print DMX "\n";
	}

# ##############
# # Group matrix
# ##############

# # store group names
# my @groups = qw "mgwat fgwat mswat fswat";
# print "Creating group matrix...\n";

# # create group matrix
# open GMX, ">$out/group_matrix.txt";

# # print header (tab separated)
# foreach my $gcolname(@groups){print GMX "\t$gcolname";}
# print GMX "\n";

# # populate each cell, 1 line at a time
# my $gfile = 0;
# foreach my $gx(@groups)
# 	{ 
# 		print GMX "$gx";
# 		foreach my $y(@groups)
# 			{
# 				my $report = "gp_"."$gx"."_v_"."$y"."_diffbind_report.txt";
# 				my $exists = grep { $_ eq $report } @all_files;
# 				if ($gx eq $y) {print GMX "\t0";}	# print 0 where the 2 groups are the same
# 				elsif ($exists == 0) {print GMX "\tNA";}	# print NA if comparison doesn't exist
# 				else
# 					{	
# 						# count the number of lines that meet the conditions
# 						$gfile++;
# 						print "- counting $gfile/12\n";
# 						open (IN, "$report_dir/$report") or die "$report doesn't exist in this folder!\n";
# 						my $count = 0;
# 						foreach my $line(<IN>)
# 							{	
# 								# filter to include only lines where fold change is greater than 1.5 and p value is less than 0.05
# 								my @in = split(/\t+/,$line);
# 								if ($in[0] =~ /^seqnames/){next;}
# 								elsif ((($in[8] <= -1.5) or ($in[8] >= 1.5)) and ($in[10]<0.01))
# 									{
# 										$count++;
# 									}
# 							}
# 						print GMX "\t$count";
# 					}
# 			}
# 		# start a new row
# 		print GMX "\n";
# 	}

# ################################################################################
# #################		Calculate Scaling Factor		 #######################
# ################################################################################
# ######         Each peak in a bigbed needs a score between 0-1000         ######
# ###### The scaling factor will transform the FC of a peak into its score  ######
# ################################################################################

# print "Calculating scaling factor...\n";

# my $current = 0;
# my $upper_limit = 0;

# foreach my $report(@all_files)
#  	{
#  		if ($report =~ m/^(.+)_diffbind_report.txt$/)
#  			{	
#  				$current++;
#  				print "file $current/$total\t";
#  				open (IN, "$report_dir"."/"."$report");		
# 				foreach my $line(<IN>)
# 					{
#  						# parse the line by tab
#  						my @in = split(/\t+/,$line);

# 						# skip the header;
# 						if ($in[0] =~ /^seqnames/){next;}
#  						else
#  							{
# 	 							# store the greatest fold change
#  								my $fold = $in[8];
#  								if ($fold<0){$fold = $fold*-1};
#  								if ($fold>$upper_limit){$upper_limit = $fold}
#  							}
# 					}
# 				print "(max FC: $upper_limit)\n";
# 				close IN;
# 			}
# 	}
# if ($upper_limit>15){print "Warning: fold change upper limit >15\t outliers may skew data\n";}
# my $scaling_factor = 1000/$upper_limit;

# ###############################################################################
# #################			 Create BIGBED files			###################		
# ###############################################################################
# print "Creating BigBed files...\n";
# foreach my $report(@all_files)
# 	{
# 		#if ($report =~ m/^(.+)_v_(.+)_diffbind_report.txt$/)
# 		if (($report =~ m/^(.+)_v_(.+)_diffbind_report.txt$/) or ($report =~ m/^(gp_.+)_v_(.+)_diffbind_report.txt$/))
# 			{	
# 				print "Processing $report\n";
# 				#push (@diffbind_reports, $report);
# 				my @in;
# 				my $chrom;
# 				my $chromStart;
# 				my $chromEnd;
# 				my $raw;
# 				my $percent;
# 				my $name;
# 				my $score;
# 				my $strand;
# 				my $thickStart;
# 				my $thickEnd;
# 				my $itemRgb;
				
# 				# create the bed file
# 				open (IN, "$report_dir"."/"."$report");
# 				open (OUT, ">$report_dir"."/"."$1"."_v_"."$2".".bed");
# 				foreach my $line(<IN>)
# 					{	
# 						# filter to include peaks where fold change is greater than 1.5 and p value is less than 0.05
# 						@in = split(/\t+/,$line);
# 						if ($in[0] =~ /^seqnames/){next;}
# 						elsif (($in[0] =~ /^(.+)$/) and (($in[8] <= -1.5) or ($in[8] >= 1.5)) and ($in[9]<0.05))
# 						 	{
# 						 		my @out;
# 						 		my $colour_flag = "pos";
# 								$chrom = $1;
# 								$chromStart = $in[1];
# 								$chromEnd = $in[2];
# 								$name = "$in[8] ($in[9])";
# 								$score = $in[8]*$scaling_factor;							# upscale
# 								if ($score<0){$score = $score*-1; $colour_flag = "neg";}	# remove negatives
# 								if ($score>1000){$score = 1000;}							# stay between 0-1000
# 								$score = sprintf("%.0f", $score);							# round to integers
# 								$strand = ".";
# 								$thickStart = $chromStart;
# 								$thickEnd = $chromEnd;
# 								if ($colour_flag eq "neg"){$itemRgb = "0,0,255";} else {$itemRgb = "255,0,0";} # blue = neg, red = pos
# 								push (@out, $chrom, $chromStart, $chromEnd, $name, $score, $strand, $thickStart, $thickEnd, $itemRgb);
# 								my $string = join ("\t",@out);	
# 								print OUT "$string\n";
# 						 	}
# 					}
# 				close IN;
# 				close OUT;
			
# 				# create the bigbed file
# 				system "sort -k1,1 -k2,2n $report_dir"."/"."$1"."_v_"."$2".".bed > $report_dir"."/"."$1"."_v_"."$2".".sorted.bed";
# 				my $chr_size = "/NGS/musRefs_10/mm10_chr_size.txt";
# 				system "bedToBigBed -tab $report_dir"."/"."$1"."_v_"."$2".".sorted.bed $chr_size $report_dir"."/"."$1"."_v_"."$2".".bb";
# 			}
#  	}

# system "rm $report_dir"."/*.bed";
# system "mv $report_dir"."/*.bb $out/bigbeds";
