#!/usr/bin/perl 
# Runs diffbind on grid
# Kenneth Condon May 2017
############################################################################################
use strict;
use warnings;

# Rscripts
my $norepsR = "/NGS/working_projects/AtacSeq/scripts/diffbind_noreps.r";
my $repsR = "/NGS/working_projects/AtacSeq/scripts/diffbind_reps.r";

# output directory
my $out = "/NGS/working_projects/AtacSeq/data/12_diff_binding/";

# sample + groups IDs
my @samples = qw "mswatd-1 mswatd0 mswatt4 mswatd1 mswatd2 mswatd4 mswatd7 mmswat fswatd-1 fswatd0 fswatt4 fswatd1 fswatd2 fswatd4 fswatd7 fmswat mgwatd-1 mgwatd0 mgwatt4 mgwatd1 mgwatd2 mgwatd4 mgwatd7 mmgwat fgwatd-1 fgwatd0 fgwatt4 fgwatd1 fgwatd2 fgwatd4 fgwatd7 fmgwat";
my @groups = qw "mswat fswat mgwat fgwat";
#my @samples = qw "mswatd-1 mswatd0";
#my @groups = qw "mswat fswat";

# submit replicate jobs to the grid
my $groupcount = 0;
foreach my $x(@groups)
	{
		foreach my $y(@groups)
			{
				if ($x eq $y) {next;}
				$groupcount++;
				my $jobname = "j".$groupcount."_of_12";
				system "qsub -cwd -j y -b yes -P NGS -N $jobname -o $out -pe big 8 /R/R-Kenneth/bin/Rscript $repsR $x $y";
			}
	}

# submit non-replicate jobs to the grid
my $paircount = 0;
foreach my $x(@samples)
	{
		foreach my $y(@samples)
			{
				if ($x eq $y) {next;}
				$paircount++;
				my $jobname = "j".$paircount."_of_992";
				system "qsub -cwd -j y -b yes -P NGS -N $jobname -o $out -pe big 2 /R/R-Kenneth/bin/Rscript $norepsR $x $y";
			}
	}

exit;