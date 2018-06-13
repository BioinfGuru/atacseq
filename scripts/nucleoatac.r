#!/usr/bin/env Rscript
# For use on output of nucleoatac
# Kenneth Condon
# Mar 2017

#################################################################################################################
#####################################          SETUP          ###################################################
#################################################################################################################

# clear environment
rm(list=ls())

# Set + store working directory
setwd("/home/kcondon/NGS/working_projects/AtacSeq/data/13_nucleoatac")
#setwd("S:/working_projects/AtacSeq/testnucleoatac")
source.dir<-(getwd())

# Load libraries
library(NucleoATACR)

#################################################################################################################

# Read in nucleosome and nfr positions:
nucs.gr <- readNucs("fswatd0.nucmap_combined.bed.gz", out = "GRanges")
nucs.df <- readNucs("fswatd0.nucmap_combined.bed.gz", out = "data.frame")
nfrs.gr <- readNFRs("fswatd0.nfrpos.bed.gz", format = "GRanges")
nfrs.df <- readNFRs("fswatd0.nfrpos.bed.gz", format = "data.frame")

# Read in nucleoatac signal track for particular locus (1 value returned per nucleotide)
signal <- readBedgraph("fswatd0.nucleoatac_signal.bedgraph.gz", "chr1", 3119876, 3119877)

# Read in vplot and plot:
v <- read_vplot("fswatd0.VMat")
plotV(v)

# Get +1 and -1 nucleosomes:
fake_tss <- GenomicRanges::GRanges("chrII", IRanges::IRanges(start = c(707200,707500), width = 1), strand = c("+","-")) 
p1 <- get_p1_nuc(nucs.ranges = nucs.gr, sites = fake_tss)
m1 <- get_m1_nuc(nucs.ranges = nucs.gr, sites = fake_tss)
