# The Manual
- **[extract_gene_functions](#extract_gene_functions)**   
- **[prepare_input_paml.pl](#prepare_input_paml)**  
- **[codeml.pl](#codeml)**                
- **[mhclust](#mhclust)**  
- **[mpca_rna](#mpca_rna)**                 
- **[extract_reads_nb](#extract_reads_nb)**  
- **[quality_control.pl](#quality_control)**       
- **[mpca](#mpca)**  
- **[DESeq](#DESeq)**  
- **[RNAnorm](#RNAnorm)**  
- **[ChangeHeader](#ChangeHeader)**  
- **[Create extract_gene_expression_plot](#extract_gene_expression_plot)**  
*********
*********
## [extract_gene_functions](#The-Manual)    
### run extract_gene_functions  

chmod +x extract_gene_functions   

**Example**: 
```bash
extract_gene_functions -i Enrichment/\*\_enrichment.txt \
-a Orthogroup-uniprot.gene.name \
--gene_column 1 \
--func_column 3 \
--functions functions_txt/pH_functions.txt \
--output 1
```

will print the overal functional enrichment results of all \*\_enrichment.txt provided,
and all genes of these files underlying the functions provided by functions_txt/pH_functions.txt (the target functions).  

### usage:    
Options:

    --input,-i      your input enrichment files: could be many files (such as *_enrichment.txt) or a single file
    --anotation,-a      your anotation files to the genes under the functions file
    --gene_column,-g    which column is your gene_id in your anotation files
    --func_column       which column is your function name in your enrichment files
    --functions         your target functions need to be extracted
    --output,-o         the prefix of the output results
    --help,-h       Print this help
*********
*********
## [prepare_input_paml](#The-Manual)

This script is used to prepare the input for PAML  
### Usage:  
```bash
perl prepare_input_paml.pl \
--input ortho_list.txt \
--seq_dir . \
--cor_list correlation.txt \
--output .
```

**Example**:  
1. --input:  
the first column is the protein sequence id of reference, the other columns are the nucleotide sequences of each species  
```
\# orth_id  reference_protein   spe1_nuc    spe2_nuc    spe3_nuc    spe4_nuc    spe5_nuc    spe6_nuc  
OG0000014   sp|O62714|CASR_PIG  Apoly_6299  Padel_40993 Daru_99354  Acura_116661    Ocomp_39102 Pmol_166022  
OG0000021   sp|Q9JHX4|CASP8_RAT Apoly_3749  Padel_10792 Daru_24893  Acura_7918  Ocomp_30861 Pmol_46346  
OG0000035   sp|O14936|CSKP_HUMAN    Apoly_14462 Padel_8374  Daru_143421 Acura_125242    Ocomp_155787    Pmol_97813  
OG0000047   sp|P30568|GSTA_PLEPL    Apoly_17254 Padel_33286 Daru_13087  Acura_32119 Ocomp_171369    Pmol_47987  
```

2. --seq_dir: directory of sequences  

3. --cor_list:  
Example table:
```
refer   reference_protein.fasta     # the first row of cor_list (the column 1 of input) are the id of reference protein sequences  
spe1    spe1.fasta                  # the second row of cor_list (the column 2 of input) are the nucleotide sequences of spe1  
spe2    spe2.fasta                  # the third row of cor_list (the column 3 of input) are the nucleotide sequences of spe2  
...     ...                         ...
```

**Options**:  
```
    --input         the list of orthologous genes, which should include the reference protein sequences id  
                    and the nucleotide sequences per species  
    --seq_dir       the directory of nucleotide sequences and reference protein sequences  
    --cor_list      the corresponding list between species and sequence fasta file  
    --output,-o     the directory of the output results  
    --help,-h       Print this help  
```

*********
*********
## [codeml](#The-Manual)
This script is used to run codel per gene  

### Usage:  
**branch model**  
```bash
perl codeml.pl --input final_orth_input_paml.txt \
--model branch \
--dir . \
--output_suf Apoly \
--tree PNG_species_Apoly.tre \
--icode 0 \
--omega 1.2  
```

**free-ratio model**: notice the tree should not have the foreground marker in the phylogeny tree  
```bash
perl codeml.pl --input final_orth_input_paml.txt \
--model free-ratio \
--dir . \
--tree PNG_species.tre \
--icode 0 --omega 1.2  
```

**Example**:  
1. --input:  
```
OG0000035  
OG0000047  
OG0000055  
OG0000059  
OG0000063  
OG0000083  
```

2. --model:  
```
pairwise (pairwise-null, pairwise-alt);  
free-ratio;  
branch (branch-null, branch-alt);  
branch-site (branch-site-null, branch-site-alt);  
```

3. --output_suf: **optional**  

4. --0mega:  

5. --dir: **the directory to save the result**  

6. --tree:  

7. --icode: **0 (the codons are universal) or mt. code (1)**  
*********
*********
## [mhclust](#The-Manual)
This script is used to output the PCA plot from multiple reads number matrixs  
print command to a Rscript and then run it to output the plot  

### Usage:  
```
mhclust --matrix Blenny_control_read_nb.xls Blue_eyed_control_read_nb.xls Common_control_read_nb.xls Yaldwyn_control_read_nb.xls \
--samples coldata_Blenny_control.txt coldata_Blue_eyed_control.txt coldata_Common_control.txt coldata_Yaldwyn_control.txt \
--column Site_2 Site_1 Site_1 Site_2 \
--title Blenny Blue_eyed Common Yaldwyn \
--prefix total
```

**Example**:  
1. --matrix: Blenny_read_nb.xls  
```
    B61 B62 B63 B64 B65 B66 B67 B68 B69 B71 B72 B73 B74 B75 B76 B77 B78 B79
OG0038649   430 218 222 486 402 612 266 159 278 334 365 190 614 464 346 543 477 490
OG0039547   0   1   0   0   0   0   0   0   0   0   0   3   0   0   0   0   0   0
```

2. --samples: coldata_Blenny.txt  
```
    Site_1  Site_2  Species
B61 Vn  Vent    Blenny
B62 Vn  Vent    Blenny
```
*********
*********
## [mpca_rna](#The-Manual)
This script is used to output the PCA plot from multiple reads number matrixs  
print command to a Rscript and then run it to output the plot  

### Usage:  
```
mpca_rna --matrix Blenny_control_read_nb.xls Blue_eyed_control_read_nb.xls Common_control_read_nb.xls Yaldwyn_control_read_nb.xls \
--samples coldata_Blenny_control.txt coldata_Blue_eyed_control.txt coldata_Common_control.txt coldata_Yaldwyn_control.txt \
--column Site_1 Site_1 Site_1 Site_1 \
--title Blenny Blue_eyed Common Yaldwyn \
--prefix total_pca
```

**Example**:
1. --matrix: Blenny_read_nb.xls  
```
    B61 B62 B63 B64 B65 B66 B67 B68 B69 B71 B72 B73 B74 B75 B76 B77 B78 B79
OG0038649   430 218 222 486 402 612 266 159 278 334 365 190 614 464 346 543 477 490
OG0039547   0   1   0   0   0   0   0   0   0   0   0   3   0   0   0   0   0   0
```

2. --samples: coldata_Blenny.txt  
```
    Site_1  Site_2  Species
B61 Vn  Vent    Blenny
B62 Vn  Vent    Blenny
```
*********
*********
## [extract_reads_nb](#The-Manual)
This script is used to extract reads number from an overall reads number matrix  

### Usage:  
~/Documents/2021/White_island/reads_number_matrix  
```
extract_reads_nb --matrix all_species_matrix.xls --genes zona_related_genes.txt --samples 1.txt
extract_reads_nb --matrix all_species_matrix.xls --samples 1.txt|head >2.txt
```

**Example**:
1. --matrix: the overall reads number matrix  

2. --genes: zona_related_genes.txt;  
```
OG0015450   sp|P79762|ZP3_CHICK Zona pellucida sperm-binding protein 3
OG0018177   sp|Q12836|ZP4_HUMAN Zona pellucida sperm-binding protein 4
OG0023058   sp|Q9BH10|ZP2_BOVIN Zona pellucida sperm-binding protein 2
```

3. --samples: coldata.txt; # has header  
```
    Site_1  Site_2  Species
B6  Cs  Control Common
B7  Cs  Control Common
B8  Cs  Control Common
B9  Cs  Control Common
```
*********
*********
## [quality_control](#The-Manual)
this script is used for the quality control of raw reads by fastqc and Trimmomatic  
**MUST NOTICE** the kraken library  

### Usage:  
```bash
perl quality_control.pl --input data_list.txt --raw_dir ./raw_data \
--trim_dir ~/software/Trimmomatic-0.39 \
--kraken_lib ~/software/kraken2/library \
--fastqc ~/software/FastQC/fastqc
```

**Example: (SNORLAX)**  
1. The fisrt time quality control  
provide a list for the raw file including its path and the name after Trimmomatic  

**Input**: (data_list.txt)
```
Original_name   Changed_name
B71_S70_R1_001.fastq.gz B71_R1.fq.gz
B71_S70_R2_001.fastq.gz B71_R2.fq.gz
B72_S71_R1_001.fastq.gz B72_R1.fq.gz
B72_S71_R2_001.fastq.gz B72_R2.fq.gz
```

**Directory of raw fastq files**: \$raw_dir  
**Directory of Trimmomatic**: \$trim_dir  
**Directory of kraken library**: \$kraken_lib:  
**Directory of FastQC command**: \$fastqc  

*********
*********
## [mpca](#The-Manual)
This script is used to output the PCA plot from multiple reads number matrixs based on all genes in your matrix  
print command to a Rscript and then run it to output the plot  
**Usage**:  
```bash
mpca --matrix Blenny_control_read_nb.xls Blue_eyed_control_read_nb.xls Common_control_read_nb.xls Yaldwyn_control_read_nb.xls \
--samples coldata_Blenny_control.txt coldata_Blue_eyed_control.txt coldata_Common_control.txt coldata_Yaldwyn_control.txt \
--column Site_1 Site_1 Site_1 Site_1 \
--title Blenny Blue_eyed Common Yaldwyn \
--label \
--prefix total_pca_all_gene
```

Example:
1. --matrix: Blenny_read_nb.xls  
```
    B61 B62 B63 B64 B65 B66 B67 B68 B69 B71 B72 B73 B74 B75 B76 B77 B78 B79
OG0038649   430 218 222 486 402 612 266 159 278 334 365 190 614 464 346 543 477 490
OG0039547   0   1   0   0   0   0   0   0   0   0   0   3   0   0   0   0   0   0
```

2. --samples: coldata_Blenny.txt  
```
    Site_1  Site_2  Species
B61 Vn  Vent    Blenny
B62 Vn  Vent    Blenny
```

3. --label: use this parameter to whether have the label of the indviduals in the plot  
*********
*********
## [DESeq](#The-Manual)
This script is used to DESeq2 results from multiple reads number matrixs based on all genes  
save the DESeq2 result of all comparisons  
print the DEGs number per comparison in the screen  

**Usage**:  
```bash
DESeq --matrix Blenny_read_nb.xls \
--samples coldata_Blenny.txt \
--column Site_1 \
--prefix Blenny
```

**Example**:
1. --matrix: Blenny_read_nb.xls  
```
    B61 B62 B63 B64 B65 B66 B67 B68 B69 B71 B72 B73 B74 B75 B76 B77 B78 B79
OG0038649   430 218 222 486 402 612 266 159 278 334 365 190 614 464 346 543 477 490
OG0039547   0   1   0   0   0   0   0   0   0   0   0   3   0   0   0   0   0   0
```

2. --samples: coldata_Blenny.txt  
```
    Site_1  Site_2  Species
B61 Vn  Vent    Blenny
B62 Vn  Vent    Blenny
```
*********
*********
## [RNAnorm](#The-Manual)
Used to extract raw TPM/FPKM/expected_count from the RSEM results, and also could do the normalization;  

This script was revised from the script from two script in **Trinity** as follows:  
############################  
**abundance_estimates_to_matrix.pl** && **run_TMM_scale_matrix.pl**  
can also use the two script to output the TPM-cross-sample-normalized matrix:  
```bash
~/software/trinityrnaseq-2.8.5/util/abundance_estimates_to_matrix.pl --est_method RSEM --gene_trans_map none --cross_sample_norm TMM  *.results
```
the target file: RSEM.isoform.TMM.EXPR.matrix


############################
This script do not consider the relationship between gene and transcript, will treat the  
first column of \*.isoforms.results as an unit  

### **Required**:  
**--method**    Extract the Values from RSEM results; # expected_count, TPM, FPKM
**--prefix**    the prefix of the result files

### **option**:  
**--norm**  
1. cross-samples normalization to TPM values using TMM (trimmed mean of M-values) in edgeR;  
2. square root normalization.  

### **Usage**: my result pwd (/media/HDD/white_island/paired/RSEM_result)  
```bash
RNAnorm --method TPM --norm --prefix White_island *isoforms.results
RNAnorm --method FPKM --prefix White_island *isoforms.results
```
**Example**:  
Input: B10.isoforms.results (an output result file by RSEM)  
```
transcript_id   gene_id length  effective_length    expected_count  TPM FPKM    IsoPct
OG0000007   OG0000007   5094    4788.76 3796.59 19.02   24.62   100.00
OG0000012   OG0000012   339 58.13   3322.00 1371.18 1774.81 100.00
OG0000019   OG0000019   1380    1074.76 340.00  7.59    9.82    100.00
```

*********
*********
## [ChangeHeader](#The-Manual)
This script is used to change the header of your read nb matrix according to you command  

### Usage: 
ChangeHeader --raw all_species_raw_nb_matrix.xls --rename rename.txt > all_species_raw_nb_rename.matrix.xls  

**Example**:
1. --rename: rename.txt  
```
B36  Common_Cn_1
B37  Common_Cn_2
B38  Common_Cn_3
B39  Common_Cn_4
B40  Common_Cn_5
```

2. --raw: all_species_raw_nb_matrix.xls  
```
     B36  B37  B38  B39  B40  B6   B7   B8   B9   B10  B31  B32  B33  B34  B35  B1
OG0038649 1974 3000 2376 2194 2773 2573 2427 2451 2573 2264 2374 2288 2152 2436 2120 2556
```

## [extract_gene_expression_plot](#The-Manual)
This script is used to print the data for expression pattern plot  

**Usage**:  
```bash
extract_gene_expression_plot --matrix all_species_raw_nb_rename_ordered.matrix.xls \
--sample coldata_rename_trait.txt \
--gene gene.txt \
--col1 Species --col2 Site_1 \
--order1 Common Yaldwyn Blue_eyed Blenny \
--order2 Cs Cn Vs Vn
```

**Input files**:
1. --matrix all_species_raw_nb_rename_ordered.matrix.xls  
```
    B61 B62 B63 B64 B65 B66 B67 B68 B69 B71 B72 B73 B74 B75 B76 B77 B78 B79
OG0038649   430 218 222 486 402 612 266 159 278 334 365 190 614 464 346 543 477 490
OG0039547   0   1   0   0   0   0   0   0   0   0   0   3   0   0   0   0   0   0
```

2. --sample coldata_rename_trait.txt  
```
    Site_1  Site_2  Species Site_3  Date    pH_Meth pH_Mett Salinity    Sea_condition   Length  Gender
Blenny_Cn_1 Cn  Control Blenny  Control 2019/1/15   NA  8.1 31.8    big_swell   6.2 Female
Blenny_Cn_2 Cn  Control Blenny  Control 2019/1/15   NA  8.1 33.7    big_swell   4.8 Female
Blenny_Cs_1 Cs  Control Blenny  Control 2019/1/15   NA  8.12    32.9    big_swell   4.2 NA
```

3. && 4. the column to be reordered in the samples file (coldata_rename_trait.txt)  
5. Order in the first column  
6. Order in the second column  
