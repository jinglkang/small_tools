use strict;
use warnings;
use Getopt::Long 'HelpMessage';

my $usage=<<_EOH_;;
------------------------------------------------------------------------------------
# this script is used for the quality control of raw reads by fastqc and Trimmomatic
Example:
perl quality_control.pl --input data_list.txt --raw_dir ./raw_data --trim_dir ~/software/Trimmomatic-0.39

# 1. The fisrt time quality control
# provide a list for the raw file including its path and the name after Trimmomatic

# Input: (data_list.txt)
Original_name	Changed_name
B71_S70_R1_001.fastq.gz	B71_R1.fq.gz
B71_S70_R2_001.fastq.gz	B71_R2.fq.gz
B72_S71_R1_001.fastq.gz	B72_R1.fq.gz
B72_S71_R2_001.fastq.gz	B72_R2.fq.gz

# Directory of raw fastq files: \$raw_dir

# Directory of Trimmomatic: \$trim_dir

------------------------------------------------------------------------------------
_EOH_
;

GetOptions('input:s', \ my $input,	# the list for raw fastq files and the new file with changed name
	'raw_dir:s', \ my $raw_dir,	# Directory of raw fastq files
	'trim_dir:s', \ my $trim_dir,	# Directory of Trimmomatic
	'help', \ my $help
	);

if ($help || (! $input) || (! $raw_dir) || (! $trim_dir) ) {
	die $usage; # all of these options are mandatory requirements
}

my $pwd=`pwd`;
chomp($pwd);

# FastQC first time
my $fastqc1=$pwd."/fastqc1";
mkdir $fastqc1 unless -d $fastqc1;
open INPUT, "$pwd/$input" or die "$!\n";
chdir $raw_dir;
while (<INPUT>) {
	chomp;
	my @a=split;
	`mv $a[0] $a[1]`;
	`fastqc $a[1] -o $fastqc1 -t 32`;
}
chdir $pwd;

&over_seq();

# Trimmomatic
my $adaptor="$trim_dir/adapters/TruSeq2-PE.fa";
`cat $adaptor Overrep_seq.txt >$pwd/TruSeq2-PE-final.fa`;
mkdir "Trimmomatic/paired/" unless -d "Trimmomatic/paired/";
mkdir "Trimmomatic/unpaired/" unless -d "Trimmomatic/unpaired/";
my @fq_R1=<$raw_dir/*_R1.fq.gz>;
foreach my $R1 (@fq_R1) {
	my ($name)=$R1=~/(.*)\_R1\.fq\.gz/;
	my $R2=$name."_R2.fq.gz";
	my $R1_clean=$name."_R1.clean.fq.gz";
	my $R2_clean=$name."_R2.clean.fq.gz";
	my $R1_unpaired=$name."_R1.unpaired.fq.gz";
	my $R2_unpaired=$name."_R2.unpaired.fq.gz";
	my $cmd="java -jar $trim_dir/trimmomatic-0.39.jar ";
	$cmd.="PE $R1 $R2 ";
	$cmd.="Trimmomatic/paired/$R1_clean Trimmomatic/unpaired/$R1_unpaired ";
	$cmd.="Trimmomatic/paired/$R2_clean Trimmomatic/unpaired/$R2_unpaired ";
	$cmd.="ILLUMINACLIP:$pwd/TruSeq2-PE-final.fa:2:30:10 LEADING:4 ";
	$cmd.="TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:40 -threads 32";
	`$cmd`;
}

# FastQC second time
my $fastqc2=$pwd."/fastqc2";
mkdir $fastqc2 unless -d $fastqc2;
my @fq_clean=<Trimmomatic/paired/*.fq.gz>;
foreach my $fq (@fq_clean) {
	`fastqc $fq -o $fastqc2 -t 32`;
}

# multiqc
`multiqc ./fastqc1 -o ./fastqc1_multiqc`;
`multiqc ./fastqc2 -o ./fastqc2_multiqc`;

sub over_seq {
	open REP, ">>$pwd/Overrep_seq.txt" or die "$!\n";
	my @a=<$fastqc1/*_fastqc/fastqc_data.txt>;
	my %hash;
	foreach my $a (@a) {
		open FIL, "$a" or die "$!\n";
		while (<FIL>) {
			chomp;
			if (/>>overrepresented/i) {
				while (<FIL>) {
					chomp;
					my @a=split;
					if (/^#{1}/) {
						next;
					} elsif (/^>>/) {
						last;
					} else {
						$hash{$a[0]}++;
					}
				}
			}
		}
	}
	foreach my $key (keys %hash) {
		print REP "$key\n";
	}
}
