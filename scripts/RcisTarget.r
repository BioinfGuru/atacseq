# Motif Enrichment Analysis

# Vignette: http://scenic.aertslab.org/tutorials/RcisTarget.html 
# Must have databases installed as packages
# source: https://gbiomed.kuleuven.be/english/research/50000622/lcb/tools/scenic
#install.packages("~/NGS_new/Software/RcisTarget/RcisTarget.mm9.motifDatabases.20k_0.1.1.tar.gz", repos = NULL, type="source")

# clear environment
rm(list=ls())

# Set working directory to source directory
setwd("~/NGS_new/working_projects/AtacSeq/data")

# load libraries
suppressPackageStartupMessages({
  library(RcisTarget)
  library(DT) # for PWM logos
})

# Load gene list e
x <- "15_tisSpec/all_tissues/results/preadip_Tau0.80_max-1_gene_list.txt"
geneList1 <- readLines(x) # creates a character object
geneLists <- list(geneListName=geneList1) # converts character object to a list object

# Select motif database to use (i.e. organism and distance around TSS)
library(RcisTarget.mm9.motifDatabases.20k)
data(mm9_10kbpAroundTss_motifRanking)
data(mm9_direct_motifAnnotation)
motifRankings <- mm9_10kbpAroundTss_motifRanking
motifRankings

# Motif enrichment analysis:
motifEnrichmentTable_wGenes <- cisTarget(geneLists,
                                         motifRankings,
                                         motifAnnot_direct=mm9_direct_motifAnnotation)
dim(motifEnrichmentTable_wGenes)

### KEY:
# geneSet: Name of the gene set
# motif: ID of the motif
# NES: Normalized enrichment score of the motif in the gene-set
# AUC: Area Under the Curve (used to calculate the NES)
# TFinDB: Indicates whether the highlightedTFs are included within the direct annotation (two asterisks) or inferred annotation (one asterisk).
# TF_direct: Transcription factors annotated to the motif according to ‘direct annotation’.
# TF_inferred: Transcription factors annotated to the motif according to ‘inferred annotation’.
# enrichedGenes: Genes that are highly ranked for the given motif.
# nErnGenes: Number of genes highly ranked
# rankAtMax: Ranking at the maximum enrichment, used to determine the number of enriched genes.

# Add Position Weight Matrix Logos
motifEnrichmentTable_wGenes_wLogo <- addLogo(motifEnrichmentTable_wGenes) # add PWMs
resultsSubset <- motifEnrichmentTable_wGenes_wLogo[1:20,] #select top 20 rows
datatable(resultsSubset[,-c("enrichedGenes", "TF_inferred"), with=FALSE], 
          escape = FALSE, # To show the logo
          filter="top", options=list(pageLength=20))

# List all TFs annotated to enriched motifs
annotatedTfs <- lapply(split(motifEnrichmentTable_wGenes$TF_direct, motifEnrichmentTable_wGenes$geneSet),
                      function(x) unique(unlist(strsplit(x, "; "))))
annotatedTfs

