#!/usr/bin/perl

use strict;
use warnings;

# Script to pull all the kmers from a FastQC file and make a new file in a format friendly to fastx Trimmer (or cutradapt)
#
#		Did this on command line using
#		for file in $(find . -type f -name "fastqc_data.txt");do  grep "^[ATCG]" $file | awk  '{ print $1 }' >> allkmer.txt;done
#

# Variables for holding command line arguments
my $file = $ARGV[0];
print $file,"\n";
open(INPUTFILE, $file) or die "can't read file";

my $outfile = $file."-kmers.txt";
open OUTFILE, ">$outfile" or die "No open outfile" ;

my $check = 0;

# Loads file, look for >>Kmer Content line
while ( my $line = <INPUTFILE> ) 
{
# Scans for lines beginning with >>Kmer Content
	chomp $line;
	if ($check == 0) 
	{
		if ($line ~= m/>>Kmer Content/)
		{
			print "Eureka, we found kmer line\n";
			$check = 1;
		}
		next;
	}
	elsif ($check == 1)
	{
		if ($line ~= m/^>>/) {next;}
		my @ray = split ("\t", $line);
		my $seq = $ray[0];
	}
	else
	{
		die "WTF, check was $check\n";
	}
}

# Prints the final built VCFoutput in the .txt file format  
#print OUTFILE "$VCFoutput";

# Close opened files
close(INPUTFILE);
close(OUTFILE);
exit;


