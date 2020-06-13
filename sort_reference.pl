# sort according species and its label number
open fil, "$ARGV[0]";
while (<fil>) {
	chomp;
	next if /^\s+/;
	@a=split;
	($spe, $num)=$a[0]=~/(.*)(\d+)/;
	$table1{$spe}->{$a[0]}=$_;
	push @{$spe}, $num;
}

foreach $key (sort {$a cmp $b} keys %table1) {
	foreach $num1 (sort {$a <=> $b} @{$key}) {
		$ind=$key.$num1;
		print "$table1{$key}->{$ind}\n";
	}
}
