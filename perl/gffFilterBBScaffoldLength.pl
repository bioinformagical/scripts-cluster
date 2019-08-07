#!/usr/bin/perl -w

use strict;

#######      Read in GFF file and filter off the  |length=XXXXXX part of the scaffold (This is all specific to take6 BB assembly      ###########


my $fName1= $ARGV[0] or die "GFF to BED converter 1 \nI need A GFF file as input.\n";
my $filename2 = $fName1."-nolngth.gff";
open (FILE2, ">$filename2") or die $!;

open(GFFINPUT, $fName1);

while (<GFFINPUT>) 
{
     	my ($line) = $_;

	#print $line,"\n";
	
	my @gffarray = split('\t', $line);
	print $gffarray[3], "\t",$gffarray[7],"\n";
    	my $start = $gffarray[3] ;
	my $stop = $gffarray[4];
	my $seq_id = $gffarray[0];
	my $endbit = $gffarray[8];
	my @idarray = split('\|', $seq_id);
	#print $endbit."\n";
	my @endarray = split('-', $endbit);
	my $endbit = "$idarray[0]-$endarray[1]";
	# output
    	print FILE2 $idarray[0],"\t",$gffarray[1],"\t",$gffarray[2],"\t",$gffarray[3],"\t",$gffarray[4],"\t",$gffarray[5],"\t",$gffarray[6],"\t",$gffarray[7],$endbit,"\n";
}
close(GFFINPUT);
close(FILE2);
