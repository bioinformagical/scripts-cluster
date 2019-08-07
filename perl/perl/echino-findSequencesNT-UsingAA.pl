#!/usr/bin/perl
use strict;
use warnings;

#
######		This will read in the echino NT fasta and a AA text file, and read in the aa to nt log file.
#		Idetify the NT ID. Use that to get the fasta file.
# 		Produce a new fasta file containing each of the lines from the text file.
#

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the fasta file. \n";
my $sfile=$ARGV[1] or die "Need a second file to search against.\n"; 
my $logfile=$ARGV[2] or die "Need log file search against.\n";

#########  Read in Primers  and throw them into a hash

#thehash
my %primehash;

# Open in and out files
open (INFILE, "$fastafile") or die "Cannot open infile, ";
open (OUT, ">"."$sfile"."-NThits.fna") or die "Cannot open outfile!";


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
		#$header = uc($header);
		my $sequence = uc($line);   ## This is a neat feature !!  (uc  makes the string all  upper case letters)
		
		$primehash{$header}=$sequence;
	}
}

##############       Read in log file and make new hash aaID  -- sequence
my %nthash;
my %loghash;
open (LOG, "$logfile") or die "Cannot open log file!";
while ( my $line=<LOG>)
{
	my @splitty= split("\t",$line);
	


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
		#$header = uc($header);
		print OUT $header,"\n";
		print OUT $primehash{$header},"\n";
}



print " The End, c'est finis. \n ";

close INFILE;
close SCAFFILE;
close OUT;
exit;
