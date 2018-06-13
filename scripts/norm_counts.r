# Script for normalising read counts by number of properly mapped reads
# Required:
# 1) depth.txt file produced from checking bam file stats
# 2) all_peaks_raw_counts.txt file from bedtools multicov
# Kenneth Condon Mar 2017

#################################################################################################################
#########################################          SETUP           ##############################################
#################################################################################################################

# clear environment
rm(list=ls())

# Set + store working directory
setwd("~/NGS/working_projects/AtacSeq/data/11_peaks/narrow/consensus")
source.dir<-(getwd())

# load libraries
library(plyr)                                                                          # to rename columns

#################################################################################################################
#########################################     READ IN THE DATA     ##############################################
#################################################################################################################
# Store the sample names in the desired order
samples<-c("fgwatd-1","fgwatd0", "fgwatt4", "fgwatd1", "fgwatd2", "fgwatd4", "fgwatd7", "fmgwat", "fswatd-1", "fswatd0", "fswatt4", "fswatd1", "fswatd2", "fswatd4", "fswatd7", "fmswat", "mgwatd-1", "mgwatd0", "mgwatt4", "mgwatd1", "mgwatd2", "mgwatd4", "mgwatd7", "mmgwat", "mswatd-1", "mswatd0", "mswatt4", "mswatd1", "mswatd2", "mswatd4", "mswatd7", "mmswat")

# read in the depth file
setwd("~/NGS/working_projects/AtacSeq/data/9_bams")
depth.df <- read.delim(file = 'depth.txt', header = FALSE, sep = "\t", dec = ".")
depth.df<-rename(depth.df, c("V1"="sample", "V2"="depth"))                             # rename the columns
depth.df$sample <- as.character(depth.df$sample)                                       # changes the samples from factors to characters
row.names(depth.df) <- depth.df$sample                                                 # assigns samples as row names
depth.df$sample<-NULL                                                                  # delete sample column
depth.df<-as.data.frame(t(depth.df))                                                   # transpose and keep correct names (need data frame)

# read in the raw counts file
setwd(source.dir)
raw.counts.df <- read.delim(file = 'all_peaks_raw_counts.txt', header = TRUE, sep = "\t", dec = ".")
colnames(raw.counts.df)[colnames(raw.counts.df)=="fgwatd.1"] <- "fgwatd-1"             # change to correct sample name
colnames(raw.counts.df)[colnames(raw.counts.df)=="fswatd.1"] <- "fswatd-1"
colnames(raw.counts.df)[colnames(raw.counts.df)=="mgwatd.1"] <- "mgwatd-1"
colnames(raw.counts.df)[colnames(raw.counts.df)=="mswatd.1"] <- "mswatd-1"
raw.counts.df$X<-NULL                                                                  # delete X column

#################################################################################################################
#########################################   NORMALISE THE DATA    ###############################################
#################################################################################################################

# Create a dataframe to store the normalised raw counts
norm.counts.df<-data.frame(chr=raw.counts.df$chr, start=raw.counts.df$start, end=raw.counts.df$end, id=raw.counts.df$id, score=raw.counts.df$score)

# normalise the raw counts
for (i in samples)
{
  scaling.factor<-depth.df[,i]/1000000                                                # work out the number of properly mapped reads per million (the scaling factor)
  norm.counts.df$newcol = raw.counts.df[,i]/scaling.factor                            # normalise by the scaling factor
  norm.counts.df<-rename(norm.counts.df, c("newcol"= i))                              # rename the column
}

# Create a dataframe to store the log2(normalised raw counts)
log2.norm.counts.df<-data.frame(chr=raw.counts.df$chr, start=raw.counts.df$start, end=raw.counts.df$end, id=raw.counts.df$id, score=raw.counts.df$score)

# log2 the normalised counts
for (i in samples)
{
  log2.norm.counts.df$newcol = log2(norm.counts.df[,i]+0.0000000001)                            # normalise by the scaling factor
  log2.norm.counts.df<-rename(log2.norm.counts.df, c("newcol"= i))                              # rename the column
}

#################################################################################################################
#########################################       OUTPUT       ####################################################
#################################################################################################################

# normalised counts
write.table(format(norm.counts.df, digits=2, nsmall=2), file = "normalised_counts.txt", sep = "\t", dec = ".", row.names = TRUE, col.names = NA, quote = FALSE)

# log2 nromalised counts
write.table(format(log2.norm.counts.df, digits=2, nsmall=2), file = "log2_normalised_counts.txt", sep = "\t", dec = ".", row.names = TRUE, col.names = NA, quote = FALSE)





















                          