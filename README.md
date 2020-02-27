# Automated_QC_of_MQ_data

With this script LiP MS data from the MaxQuant software can be checked for quality. The only input needed is the txt folder of the MaxQuant output, the proteome as a FASTA file from Uniprot, and a mapping file with information about the experiment.

Some concepts and ideas are taken from the [PTXQC package](https://pubs.acs.org/doi/pdf/10.1021/acs.jproteome.5b00780), however the code was completely written by me and is considerably faster than PTXQC.

The scriped is written in the RMarkdown format. It generates an HTML report when executed by clicking the Knit button in RStudio. 

## Getting started

It is important that you have all the required packages installed before running the script. You don't need to load them, this the script will do for you. 

The required packages include: 

**tidyverse:** The tidyverse is an opinionated collection of R packages designed for data science. All packages share an underlying design philosophy, grammar, and data structures.  
**janitor:** Usefull for making column names more R friendly.  
**DT:** Data table to create interactive tables for markdown.  
**data.table:** Package similar to dplyr, faster but less intuitive.  
**phylotools:** Has read.fasta function to import fasta files to R.  
**ggrepel:** This package allows the addition of improved labels to ggplot.  
**pheatmap:** Makes pretty and easy heatmaps.  
**dendsort:** Sort the dendrogram created for heatmap.  
**plotly:** Creates interactive figures from ggplot.  
**scales:** It provides additional functions for plots.

Just execute the following command to install missing packages.

```{r eval=FALSE}
list_of_packages <- c("tidyverse", "janitor", "DT", "data.table", "phylotools", "ggrepel", "pheatmap", "dendsort", "plotly", "scales")
new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
```

