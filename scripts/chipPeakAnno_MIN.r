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

# set working directory
setwd("~/NGS/working_projects/AtacSeq/test") 

# collect annotation data
annoData <- toGRanges(EnsDb.Mmusculus.v79, feature="gene")

# reads the file contents into a list of data frames
filenames=list.files(path="12_diff_binding/reports", full.names=TRUE)

# create a counter
max <- length(filenames)
min <- 0

# iterate through the files
for (i in filenames)
	{
		# store the sample name
		sampleName <- strapplyc(i, "12_diff_binding/reports/(.*)_diffbind_report.txt", simplify = TRUE)
		
		# print counter
		min <- min+1
		cat(min,"/",max,"\n",sep="")

 	  	# read in the file
 	  	report <- read.delim(file = i, header = TRUE, dec = ".", fill = FALSE)

 	  	# Create GRanges object
		  suppressWarnings(peaks <- toGRanges(report, format="BED"))
  
  	 	# annotate peaks
 	  	anno <- annotatePeakInBatch(peaks,AnnotationData=annoData,PeakLocForDistance = "middle",select = "all", output = "both", FeatureLocForDistance = "TSS")
 	  	anno <- addGeneIDs(anno, orgAnn="org.Mm.eg.db",feature_id_type="ensembl_gene_id",IDs2Add=c("symbol"))
 	  	anno.df <- as.data.frame(anno)
 	  	write.table(anno.df,file=paste("14_annotations/",sampleName,".annotated.bed",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)
 	  	
 	  	##### insideFeature column explained: feature="gene"
 	  	  #   upstream: peak resides upstream of the feature (-1Mb to -250 bases approx)
   	  	#   overlapStart: peak overlaps with the start of the feature (-700 to +700 bases approx)
 	  	  #   inside: peak resides inside the feature (+250 to end)
 	  	  #   downstream: peak resides downstream of the feature
 	  	  #   overlapEnd: peak overlaps with the end of the feature
 	  	  #   includeFeature: peak include the feature entirely
 	  	
 	  	# Annotate with MGI IDs - https://support.bioconductor.org/p/74357/
 	  	#mgi_ids <- select(org.Mm.eg.db, anno.df$feature, "MGI","ENSEMBL")
 	  	#mgi_ids.df <- as.data.frame(mgi_ids)
 	  	#colnames(mgi_ids.df) = c("feature", "MGI")
 	  	#write.table(mgi_ids.df,file="ensg_mgi.txt", sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)
 	  	#df1 <- anno.df
 	  	#df2 <- mgi_ids.df
 	  	#final.df <- merge(df1, df2, by="feature", all.x=TRUE, all.y=FALSE)
 	  	#final.df <- merge(df1, df2, by.x = "feature", by.y="feature")
 	  	#merge(dat1, dat2, by.x = "Gene_Id", by.y="Gene_Id")

  		# annotate bi directional promoters
		  #suppressWarnings(bdp <- peaksNearBDP(peaks, annoData, maxgap=5000, PeakLocForDistance =  "middle", FeatureLocForDistance = "TSS"))
		  #bdpPeaks <- unlist(bdp$peaksWithBDP) # convert GRangesList object to GRanges object
		  #bdpPeaks <- addGeneIDs(bdpPeaks, orgAnn="org.Mm.eg.db", feature_id_type="ensembl_gene_id", IDs2Add=c("symbol"))
		  #bdpPeaks <- split(bdpPeaks, seqnames(bdpPeaks)) # convert GRanges object to GRangesList object
		  #bdpPeaks.df <- as.data.frame(bdpPeaks)
		  #write.table(bdpPeaks,file=paste("14_annotations/",sampleName,".bdp.bed",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote=FALSE)
}
