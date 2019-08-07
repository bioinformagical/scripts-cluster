#!/usr/local/bin/perl
# genemark2artemis process GeneMark output to Artemis EMBL feature format
#
# Written by: James D. White, University of Oklahoma, Advanced Center for
#             Genome Technology
#
# Date Written: Oct 14, 1999
#
# Date Last Modified: Oct 15, 1999

if ($#ARGV < 1)
	{
	print("\nUSAGE: $0 GeneMark_file Artemis_feature_file\n\n");
	exit;
	}
open(GENEMARK, $ARGV[0]) || die("Can't open GeneMark output file as input: '$ARGV[0]'\n");

$found_data = -2;
while ($line = <GENEMARK>)
	{
	if ($line =~ /^;/)
		{
		last if ($found_data >= 0);
		$found_data++;
		if ($found_data == -1)
			{
			&bad_input_file if $line !~ /^;\s+GENEMARK OUTPUT/;
			next;
			}
		if ($found_data == 0)
			{
			&bad_input_file if $line !~ /^; (Nucleotide|Protein) sequences (transcribed|translated) from /;
			open(ARTEMIS, ">".$ARGV[1]) || die("Can't create Artemis feature file: '$ARGV[1]'\n");
			next;
			}
		} # end if ($line =~ /^;/)
	if ($line =~ /^>/)
		{
		&bad_input_file if $found_data < 0;
		die("Invalid feature format:\n  ($line)\n") if $line !~ /^>(\w+)\s+\((\w+) ?, (\d+) - (\d+)\)/;
		$feature = $1;
		$sequence = $2;
		$start = $3;
		$end = $4;
		$found_data++;
		if ($start <= $end)
			{
			print ARTEMIS "FT   exon            ${start}..${end}\n";
			}
		else
			{
			print ARTEMIS "FT   exon            complement(${end}..${start})\n";
			}
		print ARTEMIS "FT                   /note=\"[${sequence}.${feature}]\"\n";
#		print ARTEMIS "FT                   /colour=$colour\n" if $colour;
		} # end if ($line =~ /^>/)
	} # end while ...
close(GENEMARK);
&bad_input_file if $found_data < 0;
close(ARTEMIS);
print("$found_data feature(s) found\n");

sub bad_input_file {
	die("Input file is not a valid GeneMark output file\n");
} # bad_input_file
