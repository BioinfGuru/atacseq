#!/usr/bin/env Rscript
# Annotation of Peaks + bi-directional promoters
# Kenneth Condon
# May 2017

# clear environment
rm(list=ls())

# load libraries
suppressPackageStartupMessages({
  library(ChIPpeakAnno)
  library(EnsDb.Mmusculus.v79)
  library(org.Mm.eg.db)
  library(gsubfn)
  })

# set working directory to the location of the file to be annotated
wd <- setwd("~/NGS/working_projects/Zfhx3_ChipSeq_v2/FASTQ_2_filtered/Macs_results/Macs_results_005") 

# set the file to be annotated
#filename <- "Zt3_macs_peaks.narrowPeak"
filename <- "Zt15_v_Zt3_diffbind_report.txt"

# collect annotation data
annoData <- toGRanges(EnsDb.Mmusculus.v79, feature="gene")

# read in the file
input_file <- read.delim(file = filename, header = TRUE, dec = ".", fill = FALSE) # if diffbind report: header = TRUE, if narrowPeaks file: header = FALSE

# add column names (only for narrowPeak files)
#colnames(input_file)[1] <- "seqnames"
#colnames(input_file)[2] <- "start"
#colnames(input_file)[3] <- "end"
#colnames(input_file)[4] <- "peak"
#colnames(input_file)[5] <- "score"
#colnames(input_file)[6] <- "strand"
#colnames(input_file)[7] <- "fold_change"
#colnames(input_file)[8] <- "log10pval"
#colnames(input_file)[9] <- "log10qval"
#colnames(input_file)[10] <- "start_to_summit"

# Create GRanges object
suppressWarnings(peaks <- toGRanges(input_file, format="BED")) # ignore "duplicated or NA names found. Rename all the names by numbers"

# annotate peaks
anno <- annotatePeakInBatch(peaks,AnnotationData=annoData,PeakLocForDistance = "middle",select = "all", output = "both")
anno <- addGeneIDs(anno, orgAnn="org.Mm.eg.db",feature_id_type="ensembl_gene_id",IDs2Add=c("symbol"))
anno.df <- as.data.frame(anno)
write.table(anno.df,file=paste(wd,"/",filename,".annotated",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

# annotate bi directional promoters
#suppressWarnings(bdp <- peaksNearBDP(peaks, annoData, maxgap=5000, PeakLocForDistance =  "middle", FeatureLocForDistance = "TSS"))
#bdpPeaks <- unlist(bdp$peaksWithBDP) # convert GRangesList object to GRanges object
#bdpPeaks <- addGeneIDs(bdpPeaks, orgAnn="org.Mm.eg.db", feature_id_type="ensembl_gene_id", IDs2Add=c("symbol"))
#bdpPeaks <- split(bdpPeaks, seqnames(bdpPeaks)) # convert GRanges object to GRangesList object
#bdpPeaks.df <- as.data.frame(bdpPeaks)
#bdpPeaks.df[1] <- NULL # remove group column
#bdpPeaks.df[1] <- NULL # remove group_name column
#write.table(bdpPeaks,file=paste(wd,"/",filename,".annotated.bdp",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote=FALSE)

