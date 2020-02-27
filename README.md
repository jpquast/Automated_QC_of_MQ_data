# Automated_QC_of_MQ_data

With this script LiP-MS data from the MaxQuant software can be checked for quality. The only input needed is the txt folder of the MaxQuant output, the proteome as a FASTA file from Uniprot, and a mapping file with information about the experiment.

Some concepts and ideas are taken from the [PTXQC package](https://pubs.acs.org/doi/pdf/10.1021/acs.jproteome.5b00780), however the code was completely written by me and is considerably faster than PTXQC.

The scriped is written in the RMarkdown format. It generates an HTML report when executed by clicking the Knit button in RStudio. 

The github repository contains the following useful files: 

* The script.
* An example for the output in HTML format.
* An example for the map file. 
* The yeast and human proteome from Uniprot. 

## Before you get started

It is important to specify certain run parameters in MaxQuant for this script to run properly. 

Make sure that you specify "Experiment" when you load in the files. The experiment column should contain abbreviated names for the usually very long file names. The names should be unique. Something like control_01, control_02, treated_01 etc. makes sense. 

You can (but don't have to) search both your tryptic control and lip files at the same time in MaxQuant. To avoid match between runs between these you can specify fractions. Your LiP samples can be all fraction 1 and the tryptic control samples all fraction 11. 

**Note:** It is important to not use fraction 1 and 2 because match between run is computed not only within but also with the previous and next fraction. 

Make sure to use a uniprot fasta file for the reference proteome if you want to use the same fasta file in the script later on. This is because different websites have different header rules in their proteome fasta files. This script is only able to extract information from a fasta file with the uniprot header rule. 

If you want proteinase K or any other contaminant proteins of interest to show up in the contaminant QC you should add it to the contaminants fasta in the MaxQuant folder. The path is the following: `MaxQuant/bin/conf/contaminants.fasta`. 

You are good to go to run your MaxQuant search.

## Getting started

It is important that you have all the required packages installed in R before running the script. You don't need to load them, this the script will do for you. 

The required packages include: 

* **tidyverse:** The tidyverse is an opinionated collection of R packages designed for data science. All packages share an underlying design philosophy, grammar, and data structures.  
* **janitor:** Usefull for making column names more R friendly.  
* **DT:** Data table to create interactive tables for markdown.  
* **data.table:** Package similar to dplyr, faster but less intuitive.  
* **phylotools:** Has read.fasta function to import fasta files to R.  
* **ggrepel:** This package allows the addition of improved labels to ggplot.  
* **pheatmap:** Makes pretty and easy heatmaps.  
* **dendsort:** Sort the dendrogram created for heatmap.  
* **plotly:** Creates interactive figures from ggplot.  
* **scales:** It provides additional functions for plots.

Just execute the following code to install missing packages.

```{r eval=FALSE}
list_of_packages <- c("tidyverse", "janitor", "DT", "data.table", "phylotools", "ggrepel", "pheatmap", "dendsort", "plotly", "scales")
new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
```

Once you have installed all missing packages you can proceed to making a map file that contains all the important information about your experiment. 

### Making a map.txt file

This file containing information about the experiment and is gnerated by the user. It is important that the column names are exactly like the specified names. Columns that are absolutely required are marked with a \*. 

Structure of the `map.txt` file:

* **sample_number\*:** 1, 2, 3...
* **strain:** E. coli (K12)... 
* **biological_replicate:** 1, 2, 3...
* **technical_replicate\*:** 1, 2, 3..
* **pipline\*:** LiP, Trypsin Digest (make sure to call it exactly like this)
* **ms_running_order:** 1, 2, 3...
* **vial_position:** A1, A2, A3...
* **filename:** Name of the file that was the input for MaxQuant.Take from summary file.
* **experiment\*:** Abbreviated name of the sample. Specified in MaxQuant as "Experiment". Take from summary file. E.g.: Control_01, Control_02, Treated_01... 
* **replicate_group\*:** One name for each replicate group. control, control, control, control, treated, treated, treated, treated...

### Setting up the folder

You will need the txt output folder of the MaxQuant search. Specifically you will need the following files: 

`parameters.txt`: File genereated by MaxQuant. Contains information about search and run parameters.  
`peptides.txt`: File genereated by MaxQuant. The peptides table contains information on the identified peptides in the processed raw-files.  
`evidence.txt`: File genereated by MaxQuant. The evidence file combines all the information about the identified peptides and normally is the only file required for processing the results. Additional information about the peptides, modifications, proteins, etc. can be found in the other files by unique identifier linkage.  
`summary.txt`: File generated by MaxQuant. The summary file contains summary information for all the raw files processed with a single MaxQuant run. The summary information consists of some MaxQuant parameters, information of the raw file contents, and
statistics on the peak detection. Based on this file a quick overview can be gathered on the quality of the data
in the raw file. 

Copy your `map.txt` file into this folder. Then copy the R script `Automated_QC_of_MQ_data_1.4.Rmd` into this folder. 

You do not need to also add the proteome fasta file into the same folder but you should know where it is. You will be promted to choose the file once you start running the script.

`*_proteome.fasta`: File containing informaition about every protein in the desired proteome. Contains Uniprot ID's and sequence.  

**Note:** This does not seem to work on MacOS due to a different behaviour of Rmarkdown documents. You can still manually run `file.choose()` and select the fasta file. The path will be the output. In line 79, replace `file.choose(".")` with that path. 

```{r eval = FALSE}
# Standard code, works for Windows
fasta <- read.fasta(file.choose("."))%>%clean_names()
# Modified code for MacOS
fasta <- read.fasta("filepath/to/the/file.fasta")%>%clean_names()
```

## Running the script

Open the script in R studio and simply press the Knit button. You will be promted to select your proteome fasta file as described in the previous section. 

The script should run through without a problem and supply you with a report of your experiment in HTML format. Some of the plots are interactive. 

In addition it will create a file with normalised intensities and further information that you can use for further processing. 

**Note:** Some of the peptide normalised_intensities are duplicated. This is because the table also contains precursor information with individual non-normalised intensities. You should filter the data accordingly. 
