#!/usr/bin/perl -w

use strict;

#######      Read in GFF file and write a new file with scaffold: markers 1, marker 2, etc.  #########
#	scaffold	Tetraploid     JimsMarkers     YingFeb2015 Florida-GBS Cranberry SusanMarkers YangMarkers JeanniesMarkersDec2014 JaimeDraperJewel

my $fName1= $ARGV[0] or die "GFF to BED converter 1 \nI need A GFF file as input.\n";
my $filename2 = $fName1."-nolngth.gff";
open (FILE2, ">$filename2") or die $!;

open(GFFINPUT, $fName1);

my %scafhash;
while (<GFFINPUT>) 
{
     	my ($line) = $_;

	#print $line,"\n";
	
	my @gffarray = split('\t', $line);
	print $gffarray[3], "\t",$gffarray[7],"\n";
    	my $start = $gffarray[3] ;
	my $stop = $gffarray[4];
	my $seq_id = $gffarray[0];
	my $scaffold = $gffarray[2];
	my @idarray = split('_', $seq_id);
	my $markergenre = $idarray[0];
	if (exists $scafhash{$scaffold})
	{
		$scafhash{$scaffold} .= "$seq_id\t";
	}
	else
	{
		$scafhash{$scaffold} = "$seq_id\t";
	}

	#print $endbit."\n";
	#my @endarray = split('-', $endbit);
	#my $endbit = "$idarray[0]-$endarray[1]";
	# output
	#my $len = scalar(@gffarray);
    	#print $idarray[0],"\t";
	#for (my $i = 1; $i < $len; $i++) {
#		print FILE2 $gffarray[$i],"\t";
#	}
#	print FILE2 "\n";
}

foreach my $key (keys %scafhash)
{
	print FILE2 $key,"\t$scafhash{$key}\n";

}

close(GFFINPUT);
close(FILE2);
