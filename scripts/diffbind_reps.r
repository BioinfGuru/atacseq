#!/usr/bin/env Rscript
# Differential binding analysis of replicates
# Kenneth Condon
# Mar 2017
# Usage:  Rscript diffbind_utah.r <sample1> <sample2>
#         All outfiles should be written to same folder 
#         This is necessary for calculations to do with upscaling when creating the score column in diffToBed.pl
#################################################################################################################

# clear environment
rm(list=ls())

# take command line arguments
args <- commandArgs(trailingOnly=TRUE)
#args[1] <- "mswat"
#args[2] <- "fswat"

# set working directory
setwd("/NGS/working_projects/AtacSeq/")

# load libraries
suppressPackageStartupMessages({
  library(DiffBind)
})

# set outfile directory
out.dir <- "data/12_diff_binding/"
  
# Import all samples
all_samples.df <- read.csv("data/12_diff_binding/samples.csv")

# Create a unique contrast id
contrast_id <- paste("gp_",args[1], "_v_", args[2], sep="")

# compare 2 groups of replicates
samplesheet.df<-subset(all_samples.df, all_samples.df$Condition == args[1] | all_samples.df$Condition == args[2])  

# create a differentially binding analysis (DBA) object
dbaobject <- dba(sampleSheet=samplesheet.df)

# count reads
bindingmatrix <- dba.count(dbaobject, summits=250) # summit +/- 250 bases

# tell diffbind which groups to compare
bindingmatrix.contrast <- dba.contrast(bindingmatrix, categories=DBA_CONDITION, minMembers = 2)

# analyse
diff.analysis <- dba.analyze(bindingmatrix.contrast, method = DBA_DESEQ2)

# report
report.df <- as.data.frame(dba.report(diff.analysis, method = DBA_DESEQ2))
report.df["contrast_id"] <- contrast_id
write.table(report.df,file=paste(out.dir,"reports/",contrast_id, "_diffbind_report.txt", sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

# images
filename <- paste(out.dir,"images/",contrast_id,".pdf", sep="")
pdf(filename)
dba.plotMA(diff.analysis, method = DBA_DESEQ2, th= 0.01, bNormalized = TRUE) # MA plot
dba.plotMA(diff.analysis, method = DBA_DESEQ2, th= 0.01, bNormalized = TRUE, bXY=TRUE) # MA plot
dba.plotPCA(diff.analysis, method = DBA_DESEQ2, contrast=1, label = DBA_TISSUE) # PCA clustering of only differential peaks with FDR < 0.05
dba.plotHeatmap(diff.analysis, contrast=1, correlations=FALSE, method = DBA_DESEQ2, th = 0.01) # binding affinity heatmap
dba.plotHeatmap(diff.analysis, correlations=TRUE, method = DBA_DESEQ2, th = 0.01) # significantly different sites heatmap
dba.plotBox(diff.analysis, method = DBA_DESEQ2, th = 0.01, notch=FALSE) # boxplot
dev.off()

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
  # contrast_ID

# MA plots:
	# Each dot in the plot represents a single peak
	# red dots = differentially bound peaks
	# darker blue shade =  area contains highest consentration of peaks
	# light blue shade = area contains few or no peaks
	# blue dots = non significantly differentially bound peaks that stand out on their own (so not shaded)

# Boxplot:
	# shows the distribution of reads within differentially bound sites corresponding to whether they gain or lose affinity between the two sample groups.
	# sum(report$Fold<0) # number of significantly differentially bound sites with decreased binding affinity (-ve fold change)
	# sum(report$Fold>0) # number of significantly differentially bound sites with increased binding affinity (+ve fold change)
	# Key:
		# blue = group 1, red = group 2
		# each pair of boxes is a comparison
		# the higher of the 2 boxes (red or blue) identifies the group (fgwat or mgwat) with the higher mean read concentration...
		# Left 2 boxes    -   ...amongst differentially bound sites overall
		# Middle 2 boxes  -   ...amongst differentially bound sites with increased affinity for group2 (mgwat)
		# Right 2 boxes   -   ...amongst differentially bound sites with increased affinity for group1 (fgwat)

####################################
# Other functions that can be added:
####################################

# pvals.df<-as.data.frame(dba.plotBox(diff.analysis, method = DBA_DESEQ2)) # data frame of p-values 
# computed using a two-sided Wilcoxon ‘Mann-Whitney’ test, paired where appropriate 
# indicates which of the distributions are significantly different from another distribution

#Venn diagrams
#compares the results of DESeq2 with EdgeR
#diff.analysis.all <- dba.analyze(bindingmatrix.contrast,method=c(DBA_EDGER,DBA_DESEQ2))
#diff.analysis.all
#dba.plotVenn(diff.analysis.all,contrast=1,method=DBA_ALL_METHODS_BLOCK,bAll=TRUE,bGain=FALSE,bLoss=FALSE) # middle shows peaks found to be significant by both packages
#dba.plotVenn(diff.analysis.all,contrast=1,method=DBA_ALL_METHODS_BLOCK,bAll=FALSE,bGain=TRUE,bLoss=TRUE) # further breaks down each number by gain or loss of enrichment

# Generate a consensus peakset (not appropriate if consensus peakset used to construct dba)
# data.peaks <- dba.peakset(diff.analysis, consensus=DBA_CONDITION, minOverlap=0.33)
# png("peaks_venn.png",bg="transparent",units="in",width = 6.25, height= 6.25 ,res=600)
# dba.plotVenn(data.peaks,diff.analysis$masks$Consensus)
# dev.off()
