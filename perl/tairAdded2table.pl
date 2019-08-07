#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#######           Reads in blast table and make a hash of bogs and arabid ID hits. 
#			Read in mineral table and add the arabid ID at the proper place.
#

my $input= $ARGV[0] or die "\nI need A marker file \n";
my $secondfile = $ARGV[1] or die "\nI need A fasta file \n";
#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;

#print "Please enter filename (without extension): ";
#$input = <>;

my $fileotu = $secondfile."-taired.txt";
open (OUT, ">$fileotu") or die $!;

 open (INFILE, "$input") or die "Cannot open infile!";
 open (SECONDFILE, "$secondfile") or die "Cannot open infile!";
my %rabidhash;;

while (my $line = <INFILE>)
{
        chomp $line;
	my @splitty = split("\t",$line);
	my @sp = split('\.',$splitty[0]);
        my $bog = $sp[0];
	my @sp2 = split('\.',$splitty[1]);
	my $tair =$sp2[0];
	$rabidhash{$bog}=$splitty[1];
	print "$bog \t \t $splitty[1]\n";
}
#die;

my $header = <SECONDFILE>;
print OUT "$header\n";
while (my $line = <SECONDFILE>)
{
	chomp $line;
	my @splitty = split("\t",$line);
	;
	my $bog = $splitty[6];
	#print "$bog\n";
	my @sp;
	if ($bog =~ /\./)
	{ 
		@sp = split('\.',$bog);
		$bog = $sp[0];
		print " we are in for $bog\n";
	}
	
	my $tair = $rabidhash{$bog};
	print OUT "$splitty[0]\t$splitty[1]\t$splitty[2]\t$splitty[3]\t$splitty[4]\t$splitty[5]\t$splitty[6]\t$tair\t$splitty[8]\t$splitty[9]\t$splitty[10]\t$splitty[11]\n";
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

