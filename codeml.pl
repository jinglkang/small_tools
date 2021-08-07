use strict;
use warnings;
use File::Basename;
use Getopt::Long 'HelpMessage';

my $usage=<<_EOH_;;
----------------------------------------------------------------------------------------
This script is used to run codel per gene
Usage: 
# branch
perl codeml.pl --input final_orth_input_paml.txt --model branch --dir . --output_suf Apoly --tree PNG_species_Apoly.tre --icode 0 --omega 1.2
# free-ratio: notice the tree should not have the foreground marker in the phylogeny tree
perl codeml.pl --input final_orth_input_paml.txt --model free-ratio --dir . --tree PNG_species.tre --icode 0 --omega 1.2

Example:
1. --input:
OG0000035
OG0000047
OG0000055
OG0000059
OG0000063
OG0000083

2. --model: pairwise (pairwise-null, pairwise-alt); 
			free-ratio;
			branch (branch-null, branch-alt);
			branch-site (branch-site-null, branch-site-alt);

3. --output_suf: optional

4. --0mega:

5. --dir: the directory to save the result

6. --tree:

7. --icode: 0 (the codons are universal) or mt. code (1)

# output file header:
feg (the file will be in "fast_evolving_genes/" of current directory): 
orth	null_lnL	alt_lnL	range	back_w	fore_w	p

psg (the file will be in "positively_selected_genes/" of current directory): 
orth	null_lnL	alt_lnL	range	p

free-ratio (the file will be in "free-ratio/" of current directory): 
orth	tag	len	branch	t	N	S	dN/dS	dN	dS	N*dN	S*dS

																			Kang 2021-8-03
------------------------------------------------------------------------------------------
_EOH_
;

GetOptions('input:s', \ my $input,	# the orthologous list
	'model:s', \ my $model,	# the selected model
	'dir:s', \ my $dir,	# output directory
	'omega:f', \ my $omega,
	'output_suf:s', \ my $output_suf,	# the suffix name of model result file
	'tree:s', \ my $tree,
	'icode:i', \ my $icode,
	'help', \ my $help
	);

if ($help || (! $input) || (! $dir) || (! $model) ) {
	die $usage; # all of these options are mandatory requirements
}

my $pwd=`pwd`;
chomp($pwd);

open ORTH_LIST, "$input" or die "we can not open $input\n";
while (<ORTH_LIST>) {
	chomp;
	my $orth=$_;
	my $target_dir=$pwd."/$dir/$orth";
	chdir $target_dir;
	if ($model eq "branch") {
		&run_branch("branch-null");
		&run_branch("branch-alt");
		my $null=$output_suf."-branch-null-result.txt";
		my $alt=$output_suf."-branch-alt-result.txt";
		&get_branch_feg($null, $alt, $orth);
	} elsif ($model eq "branch-site") {
		&run_branch_site("branch-site-null");
		&run_branch_site("branch-site-alt");
		my $null=$output_suf."-branch-site-null-result.txt";
		my $alt=$output_suf."-branch-site-alt-result.txt";
		&get_branch_site_psg($null, $alt, $orth);
	} elsif ($model eq "pairwise") {
		&run_pairwise("pairwise-null");
		&run_pairwise("pairwise-alt");
	} elsif ($model eq "free-ratio") {
		&run_free_ratio();
		my $free="free-ratio-result.txt";
		&get_free_ratio($free, $orth);
	} else {die "the model you selected is not correct\n"} 
	chdir $pwd;
}

=head1 creat control file based on selected model

=cut

=over 4

=item &run_branch()

B<Parameters:> &run_branch($model)

=back

=cut

sub run_branch {
	my ($model)=@_;
	die "the model is wrong in the run_branch" if (($model ne "branch-null") && ($model ne "branch-alt"));
	my $ctr_file=$output_suf."-".$model.".ctr" or die "You should have a suffix name (--output_suf) for the branch model\n";
	&print_fixed_para($ctr_file);
	&print_branch($ctr_file, $model, $omega);
	&left_para($ctr_file, $model, $tree, $icode);
	`cp $pwd/$tree ./`;
	`codeml $ctr_file`;
}

=over 4

=item &run_branch_site()

B<Parameters:> &run_branch_site($model)

=back

=cut

sub run_branch_site {
	my ($model)=@_;
	die "the model is wrong in the run_branch_site" if (($model ne "branch-site-null") && ($model ne "branch-site-alt"));
	my $ctr_file=$output_suf."-".$model.".ctr" or die "You should have a suffix name (--output_suf) for the branch-site model\n";
	&print_fixed_para($ctr_file);
	&print_branch_site($ctr_file, $model, $omega);
	&left_para($ctr_file, $model, $tree, $icode);
	`cp $pwd/$tree ./`;
	`codeml $ctr_file`;
}

=over 4

=item &run_free_ratio()

B<Parameters:> &run_free_ratio() # no parameter

=back

=cut

sub run_free_ratio {
	my $ctr_file="free-ratio.ctr";
	&print_fixed_para($ctr_file);
	&print_free_ratio($ctr_file, $omega);
	&left_para($ctr_file, "free-ratio", $tree, $icode);
	`cp $pwd/$tree ./`;
	`codeml $ctr_file`;
}

=over 4

=item &run_pairwise()

=back

=cut

sub run_pairwise {
	my ($model)=@_;
	die "the model is wrong in the run_pairwise" if (($model ne "pairwise-null") && ($model ne "pairwise-alt"));
	my $ctr_file=$model.".ctr";
	&print_fixed_para($ctr_file);
	&print_pairwise($ctr_file, $model, $omega);
	&left_para($ctr_file, $model, $tree, $icode);
	`codeml $ctr_file`;
}

=over 4

=item &print_fixed_para($file)

the fixed parameters in any model

B<Description:>

================================================
seqfile = final_alignment.phy # sequence data file name
CodonFreq = 0 # codon frequencies are assumed to be equal
clock = 0 # no clock
aaDist = 0 # amino acid distances are assumed to be equal
noisy = 0 # concise print in the screen
Mgene = 0 # no partition
RateAncestor = 0 
fix_alpha = 1
alpha = 0
verbose = 1 # 1: detailed output, 0: concise output
seqtype = 1
aaRatefile = /home/Kang/software/paml4.9j/dat/jones.dat # change it according to your PAML install directory
fix_kappa = 0
kappa = 2
Malpha = 0
ncatG = 3
fix_rho = 1
rho = 0.
getSE = 0
Small_Diff = .5e-6
cleandata = 0
fix_blength = 0
method = 0
================================================

B<Parameters:> the file to be printed

=back

=cut

sub print_fixed_para {
	my ($output)=@_; # get the output file
	open OUTPUT, ">$output" or die "can not open $output\n";
	print OUTPUT "seqfile = final_alignment.phy\n";
	print OUTPUT "CodonFreq = 0\n";
	print OUTPUT "clock = 0\n";
	print OUTPUT "aaDist = 0\n";
	print OUTPUT "noisy = 0\n";
	print OUTPUT "Mgene = 0\n";
	print OUTPUT "RateAncestor = 0\n";
	print OUTPUT "fix_alpha = 1\n";
	print OUTPUT "alpha = 0\n";
	print OUTPUT "verbose = 1\n";
	print OUTPUT "seqtype = 1\n";
	print OUTPUT "aaRatefile = /home/Kang/software/paml4.9j/dat/jones.dat\n";
	print OUTPUT "fix_kappa = 0\n";
	print OUTPUT "kappa = 2\n";
	print OUTPUT "Malpha = 0\n";
	print OUTPUT "ncatG = 3\n";
	print OUTPUT "fix_rho = 1\n";
	print OUTPUT "rho = 0.\n";
	print OUTPUT "getSE = 0\n";
	print OUTPUT "Small_Diff = .5e-6\n";
	print OUTPUT "cleandata = 0\n";
	print OUTPUT "fix_blength = 0\n";
	print OUTPUT "method = 0\n";
}

=over 4

=item &print_branch($file, $model, $omega)

B<Description:> print the parameter if branch model is selected

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Fast evolving genes: Branch model 					        	 +
--------------------------------- 					        	 +
null model: runmode = 0, model = 2, NSsites = 0, fix_omega = 1, omega = 1; +
alt. model: runmode = 0, model = 2, NSsites = 0, fix_omega = 0, omega = 1; +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

B<Parameters:> 

1. the file to be printed 
2. the selected model
3. $omega

=back

=cut

sub print_branch {
	my ($output, $model, $omega)=@_;
	open OUTPUT, ">>$output" or die "can not open $output\n";
	print OUTPUT "runmode = 0\n";
	print OUTPUT "model = 2\n";
	print OUTPUT "NSsites = 0\n";
	if ($model eq "branch-null") {
		print OUTPUT "fix_omega = 1\n";
		print OUTPUT "omega = $omega\n";
	}
	if ($model eq "branch-alt") {
		print OUTPUT "fix_omega = 0\n";
		print OUTPUT "omega = $omega\n";
	}
}

=over 4

=item &print_branch_site($file, $model, $omega)

B<Description:> print the parameter if branch-site model is selected

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Positively selected genes: Branch-site model 		        	 +
--------------------------------------------		        	 +
null model: runmode = 0, model = 2, NSsites = 2, fix_omega = 1, omega = 1; +
alt. model: runmode = 0, model = 2, NSsites = 2, fix_omega = 0, omega = 1; +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

B<Parameters:> 

1. the file to be printed 
2. the selected model
3. $omega

=back

=cut

sub print_branch_site {
	my ($output, $model, $omega)=@_;
	open OUTPUT, ">>$output" or die "can not open $output\n";
	print OUTPUT "runmode = 0\n";
	print OUTPUT "model = 2\n";
	print OUTPUT "NSsites = 2\n";
	if ($model eq "branch-site-null") {
		print OUTPUT "fix_omega = 1\n";
		print OUTPUT "omega = $omega\n";
	}
	if ($model eq "branch-site-alt") {
		print OUTPUT "fix_omega = 0\n";
		print OUTPUT "omega = $omega\n";
	}
}

=over 4

=item &print_free_ratio($file, $omega)

B<Description:> print the parameter if free-ratio model is selected

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Estimate evolutionary rate each branch: free-ratio model  			  +
----------------------------------------------------------------------+
runmode = 0, model = 1, NSsites = 0, fix_omega = 0, omega = 1; 			 	  +
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

B<Parameters:> 

1. the file to be printed 
2. $omega

=back

=cut

sub print_free_ratio {
	my ($output, $omega)=@_;
	open OUTPUT, ">>$output" or die "can not open $output\n";
	print OUTPUT "runmode = 0\n";
	print OUTPUT "model = 1\n";
	print OUTPUT "NSsites = 0\n";
	print OUTPUT "fix_omega = 0\n";
	print OUTPUT "omega = $omega\n";
}

=over 4

=item &print_pairwise($file, $model, $omega)

B<Description:> print the parameter if pairwisew model is selected

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Pairwise: Estimate dS and dN into the files 2ML.dS and 2ML.dN     +
------------------------------------------------------------------+
null model: runmode=-2, model=0, NSsites=0, fix_omega=1, omega=1; +
alt. model: runmode=-2, model=0, NSsites=0, fix_omega=0, omega=1; +
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

B<Parameters:> 

1. the file to be printed 
2. the selected model
3. $omega

=back

=cut

sub print_pairwise {
	my ($output, $model, $omega)=@_;
	open OUTPUT, ">>$output" or die "can not open $output\n";
	print OUTPUT "runmode = -2\n";
	print OUTPUT "model = 0\n";
	print OUTPUT "NSsites = 0\n";
	if ($model eq "pairwise-null") {
		print OUTPUT "fix_omega = 1\n";
		print OUTPUT "omega = $omega\n";
	}
	if ($model eq "pairwise-alt") {
		print OUTPUT "fix_omega = 0\n";
		print OUTPUT "omega = $omega\n";
	}
}

=over 4

=item &left_para($file, $model, $tree, $icode)

B<Description:> print the left parameters

================================================
outfile = # result file name
treefile = # tree file name
icode = # 0: universal code
		 1: mammalian mt. code
================================================

B<Parameters:> 

1. $outfile: model result file name
2. $tree: the treefile name
3. $icode: the codons are universal (0) or mt. code (1)

=back

=cut

sub left_para {
	my ($output, $model, $tree, $icode)=@_;
	my $outfile;
	$output_suf?($outfile=$output_suf."-".$model."-result.txt"):($outfile=$model."-result.txt");
	open OUTPUT, ">>$output" or die "can not open $output\n";
	print OUTPUT "outfile = $outfile\n";
	print OUTPUT "treefile = $tree\n";
	print OUTPUT "icode = $icode\n";
}

=over 4

=iterm &get_branch_feg($null, $alt, $orth)

B<Parameters:> 
$null: branch-null model result file
$alt: branch-alt model result file
$orth: the orthologous gene id
B<Result:> 
print the restults of fast evolving genes

=back

=cut

sub get_branch_feg {
	my ($null, $alt, $orth)=@_;
	my ($p, $null_lnL, $alt_lnL, $range)=&chi2($null, $alt);
	my @alt_omega;
	open ALT, "$alt" or die "can not open $alt\n";
	while (<ALT>) {
		chomp;
		my @a=split;
		if (/^\s+\d+\.\./ && $a[4]!~/\.\./) {
			push @alt_omega, $a[4];
		}
	}
	my %hash;
	foreach my $omega (@alt_omega) {
		$hash{$omega}++;
	}
	my ($fore_w, $back_w);
	foreach my $key (keys %hash) {
		$fore_w=$key if $hash{$key}==1;
		$back_w=$key if $hash{$key}>1;
	}
	if (($p<=0.05) && ($range > 0) && ($fore_w > $back_w)) {
		my $dir=$pwd."/fast_evolving_genes/";
		mkdir $dir unless -d $dir;
		my $feg=$dir.$output_suf."-feg-"."$orth".".txt";
		open FEG, ">$feg" or die "we can not creat $feg\n";
		print FEG "$orth\t$null_lnL\t$alt_lnL\t$range\t$back_w\t$fore_w\t$p\n"; 
	}
}

=over 4

=iterm &get_branch_site_psg($null, $alt, $orth)

B<Parameters:> 
$null: branch-site-null model result file
$alt: branch-site-alt model result file
$orth: the orthologous gene id
B<Result:> 
print the restults of positively selected genes

=back

=cut

sub get_branch_site_psg {
	my ($null, $alt, $orth)=@_;
	my ($p, $null_lnL, $alt_lnL, $range)=&chi2($null, $alt);
	my %ALT;
	open ALT, "$alt" or die "can not open $alt\n";
	while (<ALT>) {
		chomp;
		if (/Bayes Empirical Bayes \(BEB\)/) {
			while (<ALT>) {
				chomp;
				if (/\*/) {
					$ALT{$orth}++;
					last;
				} else {
					$ALT{$orth}=0;
				}
			}
		}
	}
	if (($p<=0.05) && ($range>0) && ($ALT{$orth}>=1)) {
		my $dir=$pwd."/postively_selected_genes/";
		mkdir $dir unless -d $dir;
		my $psg=$dir.$output_suf."-psg-"."$orth".".txt";
		open PSG, ">$psg" or die "we can not creat $psg\n";
		print PSG "$orth\t$null_lnL\t$alt_lnL\t$range\t$p\n";
	}
}

=over 4

=iterm &chi2($lnL1, $lnL2)

B<Parameters:> 
$null: the first value should be the branch-null model result file
$alt: the second value should be the branch-alt model result file

B<Results:> 
return the p value of two lnL value (copy from Du Kang), 
the lnL of null model,
the lnL of alt. model,
the range value of two lnL value

=back

=cut

sub chi2 {
	my ($null, $alt)=@_;
	my @null=split /\s+/, `grep lnL $null`;
	my $null_lnL=$null[-2];
	my @alt=split /\s+/, `grep lnL $alt`;
	my $alt_lnL=$alt[-2];
	my $range=$alt_lnL-$null_lnL;
	my $d = 2 * abs($null_lnL-$alt_lnL);
	`chi2 1 $d` =~ /prob = (.*?) =/;
	return ($1, $null_lnL, $alt_lnL, $range);
}

=over 4

=iterm &get_free_ratio($free, $orth)

B<Parameters:> 
$free-ratio: the result file of free-ratio model
$orth: the orthologous gene id
B<Result:> 
print the restults of free-ratio with qualified values

=back

=cut

sub get_free_ratio {
	my ($free, $orth)=@_;
	my $i;
	my ($len,$tag);
	my (%spe);
	open FREE, "$free" or die "can not open $free\n";
	my $dir=$pwd."/free-ratio/";
	mkdir $dir unless -d $dir;
	while (<FREE>) {
		chomp;
		$i++;
		my @a=split;
		if ($i==1) {
			$len=$a[-1];
		} elsif (/^#/) {
			$a[0]=~/#(\d+):/;
			my $tag=$1;
			$spe{$tag}=$a[-1];
		}elsif (@a==9 && $a[-1]=~/\d+\.\d+/) {
			my $first=shift @a;
			my ($name1, $name2)=$first=~/(\d+)\.\.(\d+)/;
			my $tag1=$spe{$name1}?$spe{$name1}:$name1;
			my $tag2=$spe{$name2}?$spe{$name2}:$name2;
			my $tag=$tag1."-".$tag2;
			$a[0]=~s/\.\./\_/;
			my $len2=$a[2]+$a[3];
			unless ($a[-3]>1 || $a[2]>$len || $len2>$len+50 || $a[-2]<1 || $a[-1]<1) {
				my $free_t=$dir."free-ratio-qualified-".$orth.".txt";
				open FREE_T, ">>$free_t" or die "can not creat $free_t\n";
				print FREE_T "$orth\t$tag\t$len\t$_\n";
			}
		}
	}
}
