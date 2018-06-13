#!/usr/bin/env Rscript
# Differential binding analysis of replicates
# Kenneth Condon
# Mar 2017
# Usage:  Rscript diffbind_utah.r <sample1> <sample2>
#         All outfiles should be written to same folder 
#         This is necessary for calculations to do with upscaling when creating the score column in diffToBed.pl
######################################################################################################################################
# Caveat: Without replicates there is no way to assess variance so confidence statistics (pvalue, FDR) can not be reliably calculated.
#         https://support.bioconductor.org/p/71464/ 
######################################################################################################################################

# clear environment
rm(list=ls())

# take command line arguments
args = commandArgs(trailingOnly=TRUE)
args[1] <- "fmgwat" 
args[2] <- "fgwatd0"  

# set working directory
setwd("~/NGS/working_projects/AtacSeq/")

# load libraries
suppressPackageStartupMessages({
  library(DiffBind)
  })

# set outfile directory
out.dir <- "test/12_diff_binding/"

# Import all samples
all_samples.df <- read.csv("data/12_diffBinding/samples.csv")

# Create a unique contrast id
contrast_id <- paste(args[1], "_v_", args[2], sep="")

# compare 2 samples without replicates
samplesheet.df<-subset(all_samples.df, all_samples.df$Tissue == args[1] | all_samples.df$Tissue == args[2])

# create a differentially binding analysis (DBA) object
dbaobject <- dba(sampleSheet=samplesheet.df)

# count reads
bindingmatrix <- dba.count(dbaobject, summits=250) # summit +/- 250 bases

# tell diffbind what to compare
bindingmatrix.contrast <- dba.contrast(bindingmatrix,  group1=1, name1=args[1], group2=2, name2=args[2])

# analyse
diff.analysis <- dba.analyze(bindingmatrix.contrast, method = DBA_DESEQ2)

# report
report.df <- as.data.frame(dba.report(diff.analysis, contrast=1, th=1, bCount=TRUE))
report.df["contrast_id"] <- contrast_id
write.table(report.df,file=paste(out.dir,"reports/",contrast_id, "_diffbind_report.txt", sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

# MA plots
#filename <- paste(out.dir,"images/",contrast_id,".pdf", sep="")
#pdf(filename)
#dba.plotMA(diff.analysis, method = DBA_DESEQ2, th= 0.01, bNormalized = TRUE)
#dba.plotMA(diff.analysis, method = DBA_DESEQ2, th= 0.01, bNormalized = TRUE, bXY=TRUE)
#dev.off()

###################
# Output explained:
###################

# REPORT KEY:
  # First 3 columns: peak, location, strand
  # Conc = Concentration --> calculated by mean (log) reads across all samples in both groups
  # Conc_group1 = Concentration --> calculated by mean (log) reads across all samples in group1
  # Conc_group2 = Concentration --> calculated by mean (log) reads across all samples in group2
  # Fold = Fold difference --> calculated by Conc_group1 - Conc_group2 # sign indicates group with higher conc
  # p-value = confidence emeasure
  # FDR = multiple testing corrected p-value
  # group1 = read count
  # group2 = read count
  # contrast ID

# MA plots:
  # Each dot in the plot represents a single peak
  # red dots = differentially bound peaks
  # darker blue shade =  area contains highest consentration of peaks
  # light blue shade = area contains few or no peaks
  # blue dots = non significantly differentially bound peaks that stand out on their own (so not shaded)