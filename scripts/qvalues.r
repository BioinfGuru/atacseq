#!/usr/bin/env Rscript
# Generate q values and stats from a list of p values
# Kenneth Condon
# April 2017

#################################################################################################################
#####################################          SETUP          ###################################################
#################################################################################################################

# clear environment
rm(list=ls())

# Set working directory
#setwd("/NGS/working_projects/AtacSeq/data") # work
setwd("S:/working_projects/AtacSeq/data/12_diff_binding") # home

# load libraries
library(qvalue)

#################################################################################################################

# read in p-values
diffbind_report.df <- read.delim(file = 'mswatd-1_v_mswatd1_diffbind_report.txt', header = TRUE, sep = "\t", dec = ".")
pvalues <- diffbind_report.df$p.value
#pvalues

# alternatively run on package test data
#data("hedenfalk")
#pvalues <- hedenfalk$p # to see package test data
#pvalues

# p-value frequency distribution
hist(pvalues)

# create an object of type qvalue
qobj <- qvalue(p = pvalues, fdr.level = 0.1)
#qobj
summary(qobj)
hist(qobj)                                                # q-value frequency distribution
plot(qobj)

# extract the individual elements of the qvalue object
names(qobj)                                               # lists the names of each of the 10 elements
call <- qobj$call                                         # 1 paramaters passed to qvalue() function to create the qvalue object
pi0 <- qobj$pi0                                           # 2 estimated proportion of null p-values
qvalues <- qobj$qvalues                                   # 3 lists generated q values
max(qvalues[qobj$pvalues <= 0.01])                               # extract the maximum q value for "p values <= 0.01"
input_pvalues <- qobj$pvalues                             # 4 lists input p values 
lfdr <- qobj$lfdr                                         # 5 estimated local FDR values
fdr <- qobj$fdr.level                                     # 6 fdr threshold for significance
sig <- qobj$significant                                   # 7 boolean matrix of reaching significance threshold
summary(sig)                                                     # count number of significant FDR values
pi0.lambda <- qobj$pi0.lambda                             # 8 
lambda <- qobj$lambda                                     # 9 
pi0.smooth <- qobj$pi0.smooth                             # 10

#################################################################################################################