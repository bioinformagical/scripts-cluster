#! /usr/bin/perl

use strict;
use warnings;

#
##
#######		Read in the DEG name list into a hash.
#######           Reads in FPKM  table and checks if each unigene was deemed to be a DEG. If so, print it. 
##
#

my $input= $ARGV[0] or die "\nI need A DEG list \n";
my $secondfile = $ARGV[1] or die "\nI need A FPKM table \n";
my $filename1 = "$input-refSeq4GAGE.txt";
open (OUT, ">$filename1") or die $!;

#print "Please enter filename (without extension): ";
#$input = <>;


open (INFILE, "$input") or die "Cannot open infile!";
open (SECONDFILE, "$secondfile") or die "Cannot open infile!";


my %hash;
while (my $line = <INFILE>)
{
        chomp $line;
	$hash{$line}=1;
}

my $header = <SECONDFILE>;
print OUT $header;
while (my $line = <SECONDFILE>)
{
	chomp $line;
	my @splitty = split("\t",$line);
	my @refseq = split('\.',$splitty[0]);
	my $ref = $refseq[0];
	my $id = $splitty[1];
	chomp $id;
	shift(@splitty); shift(@splitty); 
	if (exists $hash{$id})
	{
		print OUT "$ref\t$id";
		foreach (@splitty)
		{
			print OUT "\t$_";
		}
		print OUT "\n";
	}
	
}

close (SECONDFILE);
close (OUT);
close (INFILE);
exit;


#--------------------------------------------------------------------------------
# chomp_fasta: Merges all the sequence lines in a fasta file into one line, so
#              each sequence in the fasta file will have one header line and 
#              one sequence line only
#--------------------------------------------------------------------------------

sub chomp_fasta {

open (INFILE, "$input") or die "Cannot open infile, ",$input;
open (OUT, ">"."$input"."_chomped.fasta") or die "Cannot open outfile!";

while (my $line=<INFILE>) { # Please remove the spaces

if ($line=~/>/) {
print OUT "\n$line";
}

else {
chomp ($line);
print OUT "$line";
}

}
close OUT;
}

