#!/usr/bin/perl 
# takes a diffbind/narrowPeak file annotated by chipPeakAnno(file 1) and a tissue specific gene list (file 2)
# outfile contains only peaks (from file 1) that target tissue specific genes (from file 2)
# Kenneth Condon May 2017
# perl /NGS/working_projects/AtacSeq/scripts/diffspec.pl -d fgwat.enh.filtered.txt -s /NGS/working_projects/AtacSeq/data/15_tisSpec/all_tissues/results/preadip_Tau0.80_max-1_gene_list.txt -o fgwat.enh.filtered.tisspec.txt

###############################################################################
use strict;
use warnings;
use List::Compare;
use Getopt::Long;

###############################################################################

my ($help, $mode, $anno, $tisspec, $outfile) = "" ;
GetOptions(
    'h' => \$help,
    'm=s' => \$mode,
    'a=s' => \$anno, # file 1
    's=s' => \$tisspec, # file 2
    'o=s' => \$outfile
  
) or die "\n**********  Incorrect usage!  ***********\nrun with -h option to see the useage\n\n"; 

sub useage { die(qq/
	USAGE : perl diffspec.pl -m [d|n] -a [annotated file] -s [tissue specific gene list] -o [output file]
	ARGUMENTS : 
                    REQUIRED
                    -m -> mode (d or n)
                    -a -> input annotated file
                    -s -> input tissue specific gene list file
                    -o -> output file

                    OPTIONAL
                    -h -> prints this message
                \n/);
}

if ($help) { &useage ;}
if (!$mode || !$anno || !$tisspec || !$outfile) { print "\n MISSING ARGUMENTS:\tPlease give all the required options\n" ; &useage ;}
if (($mode ne "d") and ($mode ne "n")) {print "\n Please input mode as 'd' or 'n'\n"; &useage;}

###############################################################################

# List all genes targeted by the peaks
my %anno = ();
my @selectedPeaks;
my @Llist;
open (ANNO, $anno)or die("$anno not found\n");
foreach my $line(<ANNO>)
 	{	
 		$line =~ s/\n|\r|\s+$//g;
        my @array = split(/\t/,$line);
 		if ($array[0] eq "seqnames"){next;}
        if ($mode eq "d")
            {
                if ($array[22] ne "NA")
                    {
                        $anno{$array[22]}=();
                        push @selectedPeaks, $line;
                    }
            }
            
        elsif($mode eq "n"){if ($array[19] ne "NA"){$anno{$array[19]}=(); push @selectedPeaks, $line;}}
    }
foreach my $dkey (sort keys %anno){$dkey =~ s/\n|\r|\s+$//g; unless ($dkey eq "") {push @Llist, $dkey;}}

# # List all genes that are tissue specific
my @Rlist;
open (TISSPEC, $tisspec)or die(" $tisspec not found\n");
foreach my $line(<TISSPEC>){$line =~ s/\n|\r|\s+$//g; unless ($line eq "") {push @Rlist, $line;}}

# intersection the 2 gene lists
my $lc = List::Compare->new(\@Llist, \@Rlist);
my @intersection = $lc->get_intersection;
# my $count = 0;
# foreach my $gene(@intersection){$count++;}
# print "$count tissue specific genes targetted\n";
# print "@intersection\n";

# Extract peaks that target tissue specific genes
open (OUT, ">$outfile");
my %tisspec;
foreach my $g(@intersection) {$g =~ s/\n|\r|\s+$//g; $tisspec{$g} = ();}
foreach my $peak(@selectedPeaks)
    {
        $peak =~ s/\n|\r|\s+$//g;
        my @array = split(/\t/,$peak);
        if ($mode eq "d"){if (exists ($tisspec{$array[22]})){print OUT "$peak\n";}}
        elsif($mode eq "n"){if (exists ($tisspec{$array[19]})){print OUT "$peak\n";}}
    }

# #################################################################################
exit;