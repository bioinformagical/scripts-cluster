#!/usr/bin/perl
use strict;
use warnings;

#
######		This will read in a fasta and a text file and produce a produce a new fasta file containing each of the lines from the text file.
#

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the 2 fasta files. \n";
my $sfile=$ARGV[1] or die "Need a second file to search against.\n"; 


#########  Read in Primers  and throw them into a hash

#thehash
my %primehash;

# Open in and out files
open (INFILE, "$fastafile") or die "Cannot open infile, ";
open (OUT, ">"."$sfile"."-hits.faa") or die "Cannot open outfile!";


# peruse the in file and load the hash

my $header;
while (my $line=<INFILE>) 
{ 
	if ($line=~/>/) 
	{
		$header = $line;	
	#		print  "Primer is $line \n";
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
#  Now that hash is filled, loop through file and find matches and print them.  
#              
#--------------------------------------------------------------------------------

open (SCAFFILE, "$sfile") or die "Cannot open scaffold fasta file!";

while ( my $line=<SCAFFILE>) 
{
		$header = ">".$line;
		chomp $header;
		print OUT $header,"\n";
		if (exists $primehash{$header}) {
		print OUT $primehash{$header},"\n";
		}
		else { die " Hash failed to have what we want for $header \n";}
}



print " The End, c'est finis. \n ";

close INFILE;
close SCAFFILE;
close OUT;
exit;
