#!/usr/bin/env Rscript
# Annotation of Peaks
# Kenneth Condon + Sid Sethi
# May 2017
# USAGE:  Rscript chipPeakAnno.r <narrowPeak file> <output directory> <output name>

# clear environment
rm(list=ls())

# take command line arguments
args <- commandArgs(trailingOnly=TRUE)

# For testing narrowPeak files
#args[1] <- "~/NGS/working_projects/AtacSeq/test/14_annotation/mmswat.narrow_peaks.narrowPeak" # for narrowPeaks files
#args[2] <- "~/NGS/working_projects/AtacSeq/test/14_annotation"
#args[3] <- "mmswat"


# For testing diffbind report files
args[1] <- "/NGS/working_projects/AtacSeq/test/14_annotation/mmswat_v_fmswat_diffbind_report.txt"
args[2] <- "/NGS/working_projects/AtacSeq/test/14_annotation/"
args[3] <- "mmswat_v_fmswat"


# Set working directory
setwd(args[2])

# load libraries
suppressPackageStartupMessages({
  library(ChIPpeakAnno)
  library(EnsDb.Mmusculus.v79)
  library(org.Mm.eg.db)
  library(TxDb.Mmusculus.UCSC.mm10.knownGene)
  library(reactome.db)
  library(BSgenome.Mmusculus.UCSC.mm10)
  library(GO.db)
  library(biomaRt)
  })

# Import data and convert to a GRanges object
data <- read.delim(file = args[1], header = TRUE, dec = ".", fill = FALSE)
data.df <- as.data.frame(data)
#head(data.df)
#suppressWarnings(peaks <- toGRanges(data, format="narrowPeak"))
suppressWarnings(peaks <- toGRanges(data, format="BED"))
#peaks[1:3] # view top 3 rows of GRanges object

# collect annotation data
annoData <- toGRanges(EnsDb.Mmusculus.v79, feature="gene")
#annoData[1:2]

# Distribution of peaks to the nearest TSS
#png(paste(args[3],".peakTSSDist.png",sep=""),bg="transparent",units="in",width = 8.25, height= 8.25 ,res=600)
#binOverFeature(peaks, annotationData=annoData,radius=5000, nbins=20, FUN=length, errFun=0,ylab="count", main="Distribution of aggregated peak numbers around TSS")
#dev.off()

# % distribution of peaks by feature
#peakFeatureDist<-assignChromosomeRegion(peaks, nucleotideLevel=FALSE,precedence=c("Promoters", "immediateDownstream","fiveUTRs", "threeUTRs", "Exons", "Introns"), TxDb=TxDb.Mmusculus.UCSC.mm10.knownGene)
#png(paste(args[3],".peakFeatureDist.png",sep=""),bg="transparent",units="in",width = 8.25, height= 8.25 ,res=600)
#barplot(peakFeatureDist$percentage, las=2, main="% distribution of peaks by feature")
#dev.off()

# annotate peaks + add gene IDs
anno <- annotatePeakInBatch(peaks,AnnotationData=annoData,PeakLocForDistance = "middle",select = "all", output = "both")
anno <- addGeneIDs(anno, orgAnn="org.Mm.eg.db",feature_id_type="ensembl_gene_id",IDs2Add=c("symbol"))
anno.df <- as.data.frame(anno)

# insideFeature column explained: feature="gene"
#   upstream: peak resides upstream of the feature 
#   downstream: peak resides downstream of the feature 
#   inside: peak resides inside the feature
#   overlapStart: peak overlaps with the start of the feature 
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

# write annotation file
write.table(anno.df,file=paste(args[3],".annotated.bed",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

# Plot distribution of peaks around features
#png("overlapFeatures.png",bg="transparent",units="in",width = 8.25, height= 8.25 ,res=600)
#pie1(table(anno$insideFeature))
#dev.off()

## Gene Ontology enrichment
#go <- getEnrichedGO(anno, orgAnn="org.Mm.eg.db", maxP=0.01, minGOterm=10, multiAdjMethod="BH", condense=TRUE)
#go.df <- as.data.frame(go[["bp"]][, -c(3, 10)])
#write.table(go.df,file=paste(args[3],".go.bed",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

# Pathway enrichment
#pathways <- getEnrichedPATH(anno, "org.Mm.eg.db", "reactome.db", maxP=0.01, minPATHterm=10, multiAdjMethod="BH")
#write.table(pathways,file=paste(args[3],".pathways.bed",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

# Get sequences around peaks
#seq <- getAllPeakSequence(peaks, upstream=20, downstream=20, genome=Mmusculus)
#write2FASTA(seq, paste(args[3],".fa",sep=""))

# Find bi directional promoters
suppressWarnings(bdp <- peaksNearBDP(peaks, annoData, maxgap=5000, PeakLocForDistance =  "middle", FeatureLocForDistance = "TSS"))
#c(bdp$percentPeaksWithBDP, bdp$n.peaks, bdp$n.peaksWithBDP)
bdpPeaks <- unlist(bdp$peaksWithBDP) # convert GRangesList object to GRanges object
bdpPeaks <- addGeneIDs(bdpPeaks, orgAnn="org.Mm.eg.db", feature_id_type="ensembl_gene_id", IDs2Add=c("symbol"))
bdpPeaks <- split(bdpPeaks, seqnames(bdpPeaks)) # convert GRanges object to GRangesList object
bdpPeaks.df <- as.data.frame(bdpPeaks)
write.table(bdpPeaks,file=paste(args[3],".bdp.bed",sep=""), sep="\t", col.names=TRUE, row.names=FALSE, quote = FALSE)

# Code to Visualize and compare the binding pattern around features (creates heatmap for given feature/peak ranges)
# see https://www.bioconductor.org/packages/devel/bioc/vignettes/ChIPpeakAnno/inst/doc/pipeline.html 



