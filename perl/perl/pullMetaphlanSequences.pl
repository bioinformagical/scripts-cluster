#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

#
######		This will read in a fasta and a text file and produce a produce a new fasta file containing each of the lines from the text file.
#

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the 2 fasta files. \n";
my $sfile=$ARGV[1] or die "Need a second file to search against.\n"; 


#########  Read in Primers  and throw them into a hash

#thehash
my %fastahash;

# Open in and out files
open (INFILE, "$fastafile") or die "Cannot open infile, ";
open (OUT, ">"."$sfile"."-metaphlanhits.fna") or die "Cannot open outfile!";


# peruse the in file and load the hash

my $header;
#while (my $line=<INFILE>) 
my $file1 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');
 
while (my $seq = $file1->next_seq)
{ 
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
        my $length = length($sequence);
 	#print OUT $sid, "\t", $length,"\n";
        $fastahash{$sid}=$sequence;
	
	### metaphan markers are > 100 so let's check and ensure that is true.   ###
	if (length $sequence < 101) {die "we are too short of a sequence:",$sequence,"\n";}	
}

#--------------------------------------------------------------------------------
#  Now that hash is filled, loop through bowtie2 uniq file and find matches and print them.  
#             Ignore column 1, need column 2. 
#--------------------------------------------------------------------------------

open (BOWTIEFILE, "$sfile") or die "Cannot open scaffold fasta file!";

while ( my $line=<BOWTIEFILE>) 
{
		my @splitty = split(' ',$line);
		
		$header = $splitty[1];
		chomp $header;
		print  OUT ">",$header,"\n";
		print  OUT $fastahash{$header},"\n";
}



print " The End, c'est finis. \n ";

close INFILE;
close BOWTIEFILE;
close OUT;
exit;
