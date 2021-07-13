#######################
## 1. extract_gene_functions    
#######################
### run extract_gene_functions  
chmod +x extract_gene_functions
Example: 
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
