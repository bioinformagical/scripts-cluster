#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#######           Read in jewel tetraploid marker sequence list (580 TP's).  
#			Read in entire tetraploid2sspace SAm file and get all hits from list above. 
#

my $input= $ARGV[0] or die "\nI need A marker file \n";
my $fastafile = $ARGV[1] or die "\nI need A sam file of markers aligned to assembly \n";
#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;



#print "Please enter filename (without extension): ";
#$input = <>;
chomp ($input);


my $fileotu = $input."-jewelHits.txt";
open (OUT, ">$fileotu") or die $!;

 open (INFILE, "$input") or die "Cannot open infile!";

my %markhash;
while (my $line = <INFILE>)
{
        chomp $line;
	my @splitty = split("\t",$line);
	my $id = $splitty[0];
	if ($id =~ /TP/)
	{
		$markhash{$id}=1;
	}
}

open (SAMFILE, "$fastafile") or die "Cannot open infile!";

while (my $line = <SAMFILE>)
{
	chomp $line;
 	if ($line =~ /^@/) {next;}	
	my @splitty = split( "\t",$line);
	my $tp = $splitty[0];
	$tp =~ s/tetraploid_//g;
	if (exists $markhash{$tp})
	{
		#$sequence = substr($sequence, 15);
		#print length($sequence),"\n";
		print OUT "$line\n";
		#delete $markhash{$splitty[0]};
	}
	#else{die " We could not find $tp\n";}

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

