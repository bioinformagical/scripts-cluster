#! /usr/bin/perl

use strict;
use warnings;

#
##
#######		Read in the DEG name list into a hash (blast hits to a redseq, this will be just the refseqs, already extracted from the blast table).
###		Strip off the .1  off of each refseq ID.
##		Going to make false data 10 10 10 0 0 0 for each one.
#		write a new file

my $input= $ARGV[0] or die "\nI need A DEG list \n";
my $filename1 = "$input-FPKM4GAGE.txt";
open (OUT, ">$filename1") or die $!;

#print "Please enter filename (without extension): ";
#$input = <>;


open (INFILE, "$input") or die "Cannot open infile!";
#open (SECONDFILE, "$secondfile") or die "Cannot open infile!";


my %hash;
#### Make a header
print OUT "refseq\tfakeup1\tfakeup2\tfakeup3\tfakedown1\tfakedown2\tfakedown3\n";
while (my $line = <INFILE>)
{
        chomp $line;
	 my @splitty = split('\.',$line);
	my $refseq = $splitty[0];
	my $x100 = 100 + int(rand(15));
	my $x200 = 100 + int(rand(15));
	my $x300 = 100 + int(rand(15));
	my $x1 = 1 + int(rand(10));
	 my $x2 = 1 + int(rand(10));
	 my $x3 = 1 + int(rand(10));
	print OUT "$refseq\t$x100\t$x200\t$x300\t$x1\t$x2\t$x3\n";    ### This is to avoid / 0 arguments when log transmormed later
}



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

