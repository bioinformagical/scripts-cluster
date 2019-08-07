#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#######           Reads in  Newbler sequence IDs, then Newbler fasta and makes fasta file from the Sequence IDs. 
#

my $input= $ARGV[0] or die "\nI need A newbler seq ID file \n";
my $fastafile = $ARGV[1] or die "\nI need A newbler fasta file \n";
#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;



#print "Please enter filename (without extension): ";
#$input = <>;
chomp ($input);


my $fileotu = $input."-filtered.fna";
open (OUT, ">$fileotu") or die $!;

 open (INFILE, "$input") or die "Cannot open infile!";

my %markhash;
while (my $line = <INFILE>)
{
        chomp $line;
	my @splitty = split("\t",$line);
	my $id = $splitty[0];
	$markhash{$id}=1;
}
my $sizeofhash = keys %markhash;
print " The size of the hash should be 341 and is now :  $sizeofhash\n";

my $file1 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');
while (my $seq = $file1->next_seq)
{
	my $sid = $seq->display_id;
	my $sequence = $seq->seq;
	my @splitty = split(/ /,$sid);
	if (exists $markhash{$splitty[0]})
	{
		$sequence = substr($sequence, 15);
		#print length($sequence),"\n";
		print OUT ">Tetraploid_$splitty[0]\n$sequence\n";
		delete $markhash{$splitty[0]};
	}
	else{next;}
}	

$sizeofhash = keys %markhash;
print " The size of the hash should be zero and is now :  $sizeofhash\n";

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

