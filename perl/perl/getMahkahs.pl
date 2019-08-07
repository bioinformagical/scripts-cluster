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
open (OUT, ">"."$sfile"."-mahkas.fna") or die "Cannot open outfile!";


# peruse the in file and load the hash

open (SCAFFILE, "$sfile") or die "Cannot open scaffold fasta file!";

my %hash;
while ( my $line=<SCAFFILE>)
{               
                my $header = $line;
                chomp $header;
                $hash{$header}=1;
		#print OUT $header,"\n";
                #print OUT $primehash{$header},"\n";
}

my $header; my $sequence;my $id;
while (my $line=<INFILE>) 
{ 
	if ($line=~/>/) 
	{
		$header = $line;	
		chomp $header;
		my @splitty = split("_",$header);
		my @splitty2 =split(">",$splitty[0]);
		#print  "Primer is $splitty2[1] \n";
		$id=$splitty2[1];
	}
	else 
	{
		chomp ($line);
		chomp ($header);
		$sequence = uc($line);   ## This is a neat feature !!  (uc  makes the string all  upper case letters)
		
		#$primehash{$header}=$sequence;
	}
	foreach my $key (keys %hash)
	{  
		if ($id eq $key) 
		{	
			print OUT "$header\n$sequence\n"; 
			delete $hash{$key};
		}
	}
}

#--------------------------------------------------------------------------------
#  Now that hash is filled, loop10. t0hrough file and find matches and print them.  
#              0
#---------------..


#-----------------------------------------------------------------


print " The End, c'est finis. \n ";

close INFILE;
close SCAFFILE;
close OUT;
exit;
