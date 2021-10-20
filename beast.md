# BESAT
-----
## Specifying the site model
### Four models of nucleotide evolution
Transition: a point mutation that change a purine nucleotide to another purine (A <-> G), or a pyrimidine nucleotide to another pyrimidine (C <-> T).   
Transversion: a point mutation that change a purine to primidine, or change a primidine to purine.    
subsitution rate: the number of substitution per site per year.    
1. **JC69**: the simplest evolutionary model. All the substitutions are assumed to happen at the same rate and all the bases are assumed to have identical frequencies (0.25).  
2. **HKY** : the rate of transitions is allowed to be different from the rate of transversions. The frequency of each base can be either "Estimated", "Empirical" or "All Equal".   

|**Base Frequency**|**Description**|
|:---:|:---:|
|**Estimated**|the frequency of each base will be co-estimated as a parameter during the BEAST run|
|**Empirical**|the frequency of each base will be estimated based on the alignment|
|**All Equal**|the frequency of each base will be 0.25|

3. **TN93**: allow for different rate of transitions.   
4. **GTR** : the most general reversible model and allows for different subsititution rates between each pair of nucleotides as well as different base frequencies, resulting in a total of 9 free parameters.    
### Assume all the sites to have been subject to the same substitution rate, or allow for the possibility that some sites are evolving faster than others
set **Gamma Category Count**: if we choose to split the Gamma distribution into 4 categories, we will have 4 possible scalings that will be applied to the substitution rate. The probablity of a substitution at each site will be calculated under each scaled substitution rate and averaged over 4 outcomes.     
**Shape**: select "estimate" (this is generally recommended, unless one is sure that the Gamma distribution with the shape parameter equal to 1 captures exactly the rate variation in the given dataset).      
**Notice**: fix the substitution rate fixed to 1.0 and do not estimate it. In fact, the overall substitution rate is the product of the clock rate and the substitution rate, and thus fixing one to 1.0 and estimating the other one allows for estimation of the overall rate of substitutuib. We will therefore use the clock rate to estimate the number of substitutions per site per year.    
**Model select**: https://taming-the-beast.org/tutorials/Substitution-model-averaging/    
***
## Specifying the clock model
### Four different clock models
1. strict clock: default model, which assumes a single fixed substitution rate across the whole tree.
2. relaxed clock log normal : the substitution rate associated with each branch to be independently drawn from a single, discretized log normal distribution.    
3. relaxed clock exponential: the substitution rate associated with each branch to be independently drawn from a exponential distribution.     
4. random local clock: average over all possible local clock models.     
default: strict clock, number of discrete rates (-1, means that the number of bins that the distribution is divided into the equal number of branches).     
***
## Specifying priors
### Tree prior
### add the time of calibration for some 
Priors: "+ Add Prior" --> "MRCA prior" --> select the branch you wanted and give a name (and also select "monophyletic", and then select the distribution), change the M (mean) and S (standard deviation) to make sure that 95%HPD of possible shape parameters
***
## Analysing the results: Tracer  
First thing yu may notice is that most of the parameters do have low ESS (effective sample size below 200) marked in red. This is because our chain did not run long enough
