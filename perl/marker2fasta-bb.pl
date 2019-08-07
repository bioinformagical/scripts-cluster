#! /usr/bin/perl

use strict;
use warnings;

#######           Reads in marker sequence table  curently makes sub fasta files 



my $input= $ARGV[0] or die "\nI need A marker file \n";

#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;



#print "Please enter filename (without extension): ";
#$input = <>;
chomp ($input);


my $fileotu = $input."-remade.fna";
open (OUT, ">$fileotu") or die $!;

 open (INFILE, "$input") or die "Cannot open infile!";


while (my $line = <INFILE>)
{
        chomp $line;
	my @splitty = split("\t",$line);
	my $id = $splitty[0];
	my $seq1 =  $splitty[2];
	my $seq2 =  $splitty[4];

	print " Line is: $id \t $seq1 \t $seq2 \n";
	print OUT ">$id\n$seq1\n>$id-reverse\n$seq2\n";


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

