use strict;
use warnings;
use Getopt::Long 'HelpMessage';
use File::Path qw( make_path );
use File::Basename;

my $usage=<<_EOH_;;
------------------------------------------------------------------------------------
# this script is used for the quality control of raw reads by fastqc and Trimmomatic
# MUST NOTICE the kraken library
Example: (SNORLAX)
perl quality_control.pl --input data_list.txt --raw_dir ./raw_data \
--trim_dir ~/software/Trimmomatic-0.39 \
--kraken_lib ~/software/kraken2/library \
--fastqc ~/software/FastQC/fastqc

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

# Directory of kraken library: \$kraken_lib:

# Directory of FastQC command: \$fastqc
------------------------------------------------------------------------------------
_EOH_
;

GetOptions('input:s', \ my $input,	# the list for raw fastq files and the new file with changed name
	'raw_dir:s', \ my $raw_dir,	# Directory of raw fastq files
	'trim_dir:s', \ my $trim_dir,	# Directory of Trimmomatic
	'kraken_lib:s', \my $kraken_lib,	# Directory of kraken library
	'fastqc:s', \my $fastqc,	# Directory of FastQC command
	'help', \ my $help
	);

if ($help || (! $input) || (! $raw_dir) || (! $trim_dir) || (! $kraken_lib) ) {
	die $usage; # all of these options are mandatory requirements
}

my $pwd=`pwd`;
chomp($pwd);

main: {
	# FastQC first time
	&fastqc1();
	&over_seq();
	die "Overrep_seq.txt is null" if -z "Overrep_seq.txt";
	# Trimmomatic
	&Trimmomatic();
	# FastQC second time
	&fastqc2();
	# multiqc
	`multiqc ./fastqc1 -o ./fastqc1_multiqc`;
	`multiqc ./fastqc2 -o ./fastqc2_multiqc`;
	# kraken2
	&kraken();
	exit(0);
}

#############################################
sub fastqc1 {
	my $fastqc1=$pwd."/fastqc1";
	mkdir $fastqc1 unless -d $fastqc1;
	open INPUT, "$pwd/$input" or die "$!\n";
	chdir $raw_dir;
	while (<INPUT>) {
		chomp;
		my @a=split;
		`mv $a[0] $a[1]`;
		`$fastqc $a[1] -o $fastqc1 --extract -t 16`;
	}
	chdir $pwd;
}

sub Trimmomatic {
	my $adaptor="$trim_dir/adapters/TruSeq2-PE.fa";
	`cat $adaptor Overrep_seq.txt >$pwd/TruSeq2-PE-final.fa`;
	make_path("Trimmomatic/paired/") unless -d "Trimmomatic/paired/";
	make_path("Trimmomatic/unpaired/") unless -d "Trimmomatic/unpaired/";
	my @fq_R1=<$raw_dir/*_R1.fq.gz>;
	foreach my $R1 (@fq_R1) {
		my ($name)=basename($R1)=~/(.*)\_R1\.fq\.gz/;
		my $R2=$name."_R2.fq.gz";
		my $R1_paired=$name."_R1.paired.fq.gz";
		my $R2_paired=$name."_R2.paired.fq.gz";
		my $R1_unpaired=$name."_R1.unpaired.fq.gz";
		my $R2_unpaired=$name."_R2.unpaired.fq.gz";
		my $cmd="java -jar $trim_dir/trimmomatic-0.39.jar ";
		$cmd.="PE $R1 $raw_dir/$R2 ";
		$cmd.="Trimmomatic/paired/$R1_paired Trimmomatic/unpaired/$R1_unpaired ";
		$cmd.="Trimmomatic/paired/$R2_paired Trimmomatic/unpaired/$R2_unpaired ";
		$cmd.="ILLUMINACLIP:$pwd/TruSeq2-PE-final.fa:2:30:10 LEADING:4 ";
		$cmd.="TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:40 -threads 16";
		`$cmd`;
	}
}

sub fastqc2 {
	my $fastqc2=$pwd."/fastqc2";
	mkdir $fastqc2 unless -d $fastqc2;
	my @fq_clean=<Trimmomatic/paired/*.fq.gz>;
	foreach my $fq (@fq_clean) {
		`$fastqc $fq -o $fastqc2 --extract -t 16`;
	}
}

# kraken filter
sub kraken {
	my @fq_paired=<Trimmomatic/paired/*_R1.paired.fq.gz>;
	die "There is no fastq files in Trimmomatic/paired/" if @fq_paired==0;
	mkdir "$pwd/kraken" unless -d "$pwd/kraken";
	make_path("$pwd/kraken/reports") unless -d "$pwd/kraken/reports";
	foreach my $R1 (@fq_paired) {
		my ($name)=basename($R1)=~/(.*)\_R1\.paired\.fq\.gz/;
		my $report=$name."_kraken_report.txt";
		my $R2=$name."_R2.paired.fq.gz";
		die "There is no $R2" if ! -e "Trimmomatic/paired/$R2";
		my $clean=$name."#.fq";
		my $cmd="kraken2 --db $kraken_lib --paired --threads 16 ";
		$cmd.="--gzip-compressed --unclassified-out $pwd/kraken/$clean $R1 Trimmomatic/paired/$R2 ";
		$cmd.="--report $pwd/kraken/reports/$report --use-names --confidence 0.7";
		`$cmd`;
		my @fq=<$pwd/kraken/*.fq>;
		die "There is no fastq files in $pwd/kraken/" if @fq==0;
		foreach my $fq (@fq) {
			`gzip $fq`;
		}
	}
}

sub over_seq {
	open REP, ">>$pwd/Overrep_seq.txt" or die "$!\n";
	my @a=<$pwd/fastqc1/*_fastqc/fastqc_data.txt>;
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
	my $i;
	foreach my $key (keys %hash) {
		$i++;
		print REP ">Overrep_$i\n$key\n";
	}
}
