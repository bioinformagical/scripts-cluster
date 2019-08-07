#!/usr/bin/perl
use strict;
use warnings;

#
######		This will read in 2 fasta files (scaffold file and primer file) and a contributer source and output a text file of the primer matches.
#

## read in the line arguments from command line

my $primerfile= $ARGV[0] or die "Did not have an arguments to read in the 2 fasta files. \n";
my $scaffoldfile=$ARGV[1] or die "Need a seconf fasta file to search against.\n"; 


#########  Read in Primers  and throw them into a hash

#thehash
my %primehash;

# Open in and out files
open (INFILE, "$primerfile") or die "Cannot open infile, ",$primerfile;
open (OUT, ">"."$primerfile"."-hits.txt") or die "Cannot open outfile!";

## Printing headings in the outfile.....
print OUT "Contributer \t Primer \t Primer sequence \t Scaffold name \t Scaffold size\n";

# peruse the in file and load the hash

my $header;
while (my $line=<INFILE>) 
{ 
	if ($line=~/>/) 
	{
		$header = $line;	
		#	print  "Primer is $line \n";
	}
	else 
	{
		chomp ($line);
		chomp ($header);
		my $sequence = uc($line);   ## This is a neat feature !!  (uc  makes the string all  upper case letters)
		
		$primehash{$header}=$sequence;
	}
}

#--------------------------------------------------------------------------------
#  Now that hash is filled, loop through scaffold file and find matches and print them.  
#              
#--------------------------------------------------------------------------------

open (SCAFFILE, "$scaffoldfile") or die "Cannot open scaffold fasta file!";

while ( my $line=<SCAFFILE>) 
{
	if ($line=~/>/) 
	{
		$header = $line;
		chomp $header;
	}
	else
	{
		#search through primer space so find matches....
		my $seq = uc($line);
		chomp $seq;
		foreach my $key (keys %primehash)
		{
			### Time to see if there is a match in the scaffold and if so print a line to file
			if (index($seq, $primehash{$key}) != -1)
			{
				my $lengthofseq = length($seq);
				print OUT  "SOMECONTRIBUTER \t",$key,"\t",$primehash{$key},"\t",$header,"\t",$lengthofseq,"\n";
				
			}
		}	
	}
}
print " The End, c'est finis. \n ";

close INFILE;
close SCAFFILE;
close OUT;
exit;
