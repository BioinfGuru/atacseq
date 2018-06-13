#!/usr/bin/env Rscript
# creates heatmap from diffbind matrix
# Kenneth Condon
# Mar 2017
#################################################################################################################

# clear environment
rm(list=ls())

# set working directory
setwd("~/NGS_new/working_projects/AtacSeq/")
wd <- getwd()

# load libraries
suppressPackageStartupMessages({
  library(ggplot2)
  library(reshape)
  library(corrplot)
})

######################
# ggplot group heatmap
######################

# read the matrix into a dataframe
groups.df <- read.delim(file = "data/12_diff_binding/group_matrix.txt", header = TRUE, sep = "\t", dec = ".")

# keep the order of the dataframe
groups.df$X2<-factor(groups.df$X, as.character(groups.df$X))

# convert to long format
melted.groups.df <- melt(groups.df)

# plot heatmap
groupHeat <- ggplot(data = melted.groups.df, aes(x = X2, y = variable, fill = value)) +
  geom_tile(colour = "white") + 
  scale_fill_gradient(low = "white", high = "orange", name="Number of\n     Peaks")+
  labs(title= "", x = "Group 1", y = "Group 2")+
  theme_grey(base_size = 9)+
  theme(
    axis.title.x = element_text(size=16, face="bold"),
    axis.text.x = element_text(size = 12, angle=35, hjust = 1),
    axis.title.y = element_text(size=16, face="bold"),
    axis.text.y = element_text(size = 12)
  )

groupHeat

pdf(paste(wd, "/data/12_diff_binding/images/groupHeatmap.pdf", sep=""))
print(groupHeat)
dev.off()

#####################
# ggplot pair heatmap
#####################

# read the matrix into a dataframe
pairs.df <- read.delim(file = "data/12_diff_binding/pair_all_matrix.txt", header = TRUE, sep = "\t", dec = ".")

# correct the sample names
colnames(pairs.df)[colnames(pairs.df)=="fgwatd.1"] <- "fgwatd-1"          
colnames(pairs.df)[colnames(pairs.df)=="fswatd.1"] <- "fswatd-1"
colnames(pairs.df)[colnames(pairs.df)=="mgwatd.1"] <- "mgwatd-1"
colnames(pairs.df)[colnames(pairs.df)=="mswatd.1"] <- "mswatd-1"

# keep the order of the dataframe
pairs.df$X2<-factor(pairs.df$X, as.character(pairs.df$X))

# convert to long format
melted.pairs.df <- melt(pairs.df)

# plot heatmap
pairHeat <- ggplot(data = melted.pairs.df, aes(x = X2, y = variable, fill = value)) +
  geom_tile(colour = "white") + 
  scale_fill_gradient(low = "steelblue", high = "orange", name="Number of\n     Peaks")+
  #labs(title= "", x = "", y = "")+
  theme_grey(base_size = 9)+
  theme(
  axis.title.x = element_text(size=12, face="bold"),
  axis.text.x = element_text(angle=35, hjust = 1),
  axis.title.y = element_text(size=12, face="bold")
  )

pairHeat

pdf(paste(wd, "/data/12_diff_binding/images/pairHeatmap.pdf", sep=""))
print(pairHeat)
dev.off()


############################################
# corrplot heatmap of ALL differential peaks
############################################

pairs.all.mx <- as.matrix(read.table(file = "data/12_diff_binding/pair_all_matrix.txt", header=TRUE, sep = "\t", row.names = 1, as.is=TRUE))
#pairs.all.mx <- cor(pairs.all.mx) # used when creating a correlation plot (rescales matrix to range -1 to +1)

corrplot(
  
  # general parameters
  pairs.all.mx,                 # matrix object
  is.corr = FALSE,              # "FALSE" if plotting raw matrix, "TRUE" if plotting correlation
  method = "circle",            # "circle" (default), "square", "ellipse", "number", "shade", "color", or "pie"
  type = "full",                # "full", "lower", or "upper
  order = "hclust",             # "original" (default), "AOE", "FPC", "hclust", or "alphabet"
  hclust.method = "complete",   # "complete", "ward","ward.D", "ward.D2", "single", "average", "mcquitty", "median", or "centroid"
  add = FALSE,                  # "TRUE" when combining an upper and lower plot into 1 full plot
  bg="white",                   # background color
  title = "myplot",             # plot title
  diag = TRUE,                  # FALSE removes the diagonal set of cells where the correlation is +1
  mar = c(3,0,3,0),             # margin around plot
  addgrid.col = "darkgrey",     # grid line colors
  
  # cell contents
  outline = FALSE,              # black outline around content inside each cell
  #addCoef.col = "white",       # adds + colors correlation coefficient inside each cell
  #addCoefasPercent = TRUE,     # number in cell is a percent instead of raw value
  #number.digits = 1,           # number of decimal places in cell
  #number.cex = 0.1,            # text size of number in cell
  #number.font = 2,             # ???
  
  # labels
  tl.pos = "lt",                # position
  tl.col= "black",              # color
  tl.srt= 45,                   # angle
  tl.cex = 0.75,                # size
  tl.offset = 0.5,              # gap from lable to plot
  
  # legend
  cl.pos = "b",                 # color legend position "b" or "r" (default)  
  cl.cex = 0.55,                # size of legend text
  cl.ratio = 0.15,              # width of legend color bar
  cl.align.text = "l",          # "c" (default), "l", or "r"
  cl.offset = 0.5,              # gap from bar to text
  cl.lim = c(0,32000),          # lower and upper color limits
  col = colorRampPalette(c("darkred","white","midnightblue"))(16), # color + scale (used instead of cl.length)
  
  # highlight clusters
  addrect=8,                    # rectangles around highest n correlation groups
  rect.col = "black",           # color of rectangles
  rect.lwd = 3                  # thickness of rectangles 
  
  # Further options are available when using a matrix of p-values or confidence intervals or when method = "shade": see help
)        

###################################################################
# corrplot heatmap of differential peaks split by up/down regulated
###################################################################

pairs.up.mx <- as.matrix(read.table(file = "data/12_diff_binding/pair_up_matrix.txt", header=TRUE, sep = "\t", row.names = 1, as.is=TRUE))
#pairs.up.mx <- cor(pairs.up.mx) # used when creating a correlation plot (rescales matrix to range -1 to +1)

pairs.down.mx <- as.matrix(read.table(file = "data/12_diff_binding/pair_down_matrix.txt", header=TRUE, sep = "\t", row.names = 1, as.is=TRUE))
#pairs.down.mx <- cor(pairs.down.mx) # used when creating a correlation plot (rescales matrix to range -1 to +1)

ord=hclust(1-as.dist(pairs.down.mx))$order

corrplot(
  title = "Down/Up differentially open peaks", 
  pairs.up.mx[ord,ord],
  method="circle",
  outline = TRUE,
  type = "upper",
  addgrid.col = "darkgray",
  mar = c(3,0,3,0),
  is.corr = FALSE,
  
  # when is.corr = TRUE
  #col = colorRampPalette(c("midnightblue","white"))(10),
  
  # when is.corr = FALSE
  cl.lim = c(0,32000),      
  col = colorRampPalette(c("white","midnightblue"))(16),
  
  # labels
  tl.pos = "lt",                
  tl.col= "black",            
  tl.srt= 45,                 
  tl.cex = 0.75,             
  tl.offset = 0.5,             
  
  # legend
  cl.pos = "b",                  
  cl.cex = 0.75,            
  cl.ratio = 0.15,             
  cl.align.text = "l",         
  cl.offset = 0.5
)

corrplot(
  add=T,
  pairs.down.mx[ord,ord],
  method="square",
  outline = TRUE,
  type = "lower",
  addgrid.col = "darkgray",
  mar = c(3,0,3,0),
  is.corr = FALSE,
  
  # when is.corr = TRUE
  #col = colorRampPalette(c("darkred","white"))(10),
  
  # when is.corr = FALSE
  cl.lim = c(0,32000),      
  col = colorRampPalette(c("white","darkred"))(16),
  
  # labels
  tl.pos = "lt",               
  tl.col= "black",             
  tl.srt= 45,                 
  tl.cex = 0.75,             
  tl.offset = 0.5,              
  
  # legend
  cl.pos = "r",                  
  cl.cex = 0.75,                
  cl.ratio = 0.15,              
  cl.align.text = "l",          
  cl.offset = 0.5
)

#####################################################
# Interpretation of corrplot heatmaps
# Where correlation = 1, there is no differential peaks e.g. comparing 2 identical samples 
# Where correlation = -1, the number of differential peaks is equeal to the matrix maximum - these are the most different samples
