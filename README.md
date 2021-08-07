# The Manual
1. extract_gene_functions
2. prepare_input_paml.pl
3. codeml.pl
## 1. extract_gene_functions    
### run extract_gene_functions  

chmod +x extract_gene_functions   

**Example**: 
extract_gene_functions -i Enrichment/\*\_enrichment.txt -a Orthogroup-uniprot.gene.name --gene_column 1 --func_column 3 --functions functions_txt/pH_functions.txt --output 1

will print the overal functional enrichment results of all \*\_enrichment.txt provided,
and all genes of these files underlying the functions provided by functions_txt/pH_functions.txt (the target functions).  

### usage:    
Options:

	--input,-i		your input enrichment files: could be many files (such as *_enrichment.txt) or a single file
	--anotation,-a 		your anotation files to the genes under the functions file
	--gene_column,-g 	which column is your gene_id in your anotation files
	--func_column 		which column is your function name in your enrichment files
	--functions 		your target functions need to be extracted
	--output,-o 		the prefix of the output results
	--help,-h 		Print this help

## 2. prepare_input_paml.pl  

This script is used to prepare the input for PAML  
### Usage:  
	perl prepare_input_paml.pl --input ortho_list.txt --seq_dir . --cor_list correlation.txt --output .  

**Example**:  
1. --input:  
the first column is the protein sequence id of reference, the other columns are the nucleotide sequences of each species  
```
\# orth_id	reference_protein	spe1_nuc	spe2_nuc	spe3_nuc	spe4_nuc	spe5_nuc	spe6_nuc  
OG0000014	sp|O62714|CASR_PIG	Apoly_6299	Padel_40993	Daru_99354	Acura_116661	Ocomp_39102	Pmol_166022  
OG0000021	sp|Q9JHX4|CASP8_RAT	Apoly_3749	Padel_10792	Daru_24893	Acura_7918	Ocomp_30861	Pmol_46346  
OG0000035	sp|O14936|CSKP_HUMAN	Apoly_14462	Padel_8374	Daru_143421	Acura_125242	Ocomp_155787	Pmol_97813  
OG0000047	sp|P30568|GSTA_PLEPL	Apoly_17254	Padel_33286	Daru_13087	Acura_32119	Ocomp_171369	Pmol_47987  
```

2. --seq_dir: directory of sequences  

3. --cor_list:  
Example table:
```
refer 	reference_protein.fasta		# the first row of cor_list (the column 1 of input) are the id of reference protein sequences  
spe1 	spe1.fasta					# the second row of cor_list (the column 2 of input) are the nucleotide sequences of spe1  
spe2 	spe2.fasta					# the third row of cor_list (the column 3 of input) are the nucleotide sequences of spe2  
... 	...							...
```

**Options**:  
```
	--input			the list of orthologous genes, which should include the reference protein sequences id  
					and the nucleotide sequences per species  
	--seq_dir		the directory of nucleotide sequences and reference protein sequences  
	--cor_list		the corresponding list between species and sequence fasta file  
	--output,-o 	the directory of the output results  
	--help,-h 		Print this help  
```

## 3. **codeml.pl**  
This script is used to run codel per gene  

### Usage:  
**branch model**  
```
perl codeml.pl --input final_orth_input_paml.txt --model branch --dir . --output_suf Apoly --tree PNG_species_Apoly.tre --icode 0 --omega 1.2  
```

**free-ratio model**: notice the tree should not have the foreground marker in the phylogeny tree  
```
perl codeml.pl --input final_orth_input_paml.txt --model free-ratio --dir . --tree PNG_species.tre --icode 0 --omega 1.2  
```

**Example**:  
1. --input:  
OG0000035  
OG0000047  
OG0000055  
OG0000059  
OG0000063  
OG0000083  

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
