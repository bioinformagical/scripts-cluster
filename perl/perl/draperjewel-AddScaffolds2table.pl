#!/usr/bin/perl -w

use strict;

#######      Read in GFF file and read in the draper jewel table write a new table file with scaffold results inserted into the table.  #########
#######		First read in GFF as a hash with the jaimedraperjewelmarker as the key, and the scaffold as the element.
#######			Then punch out table using hash.
my $fName1= $ARGV[0] or die "GFF from allmarkers thing 1 \nI need A GFF file as input.\n";
my $fName2= $ARGV[1] or die "The position markers table plz.\n";
my $filename2 = $fName2."-addedScaffolds.txt";
open (FILE2, ">$filename2") or die $!;

open(GFFINPUT, $fName1);
open(MARKERSINPUT, $fName2);

my %markerhash;
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
	my $markerid = $idarray[1];
	if (exists $markerhash{$markerid})
	{
		#$scafhash{$scaffold} .= "$seq_id\t";
		die "no expect a 2nd marker, truth be told\n";
	}
	else
	{
		$markerhash{$markerid} = $scaffold;
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

my $header = <MARKERSINPUT>;
print FILE2 $header,"\n";
while (<MARKERSINPUT>)
{
	my ($line) = $_;
	my @idarray = split('\t', $line);
	my $markerid = $idarray[0];
	my $lgid = $idarray[1];
	my $CMid = $idarray[2];
	my $parentid = $idarray[3];
	my $origpos = $idarray[4];
	my $sequence = $idarray[5];

	print FILE2 $markerid,"\t";
	if (exists $markerhash{$markerid})
	{
		print FILE2 $markerhash{$markerid},"\t";
	}
	else
	{
		print FILE2 "-\t";
	}
	print  FILE2 $lgid,"\t",$CMid,"\t",$parentid,"\t",$origpos,"\t",$sequence;
}	

#foreach my $key (keys %scafhash)
#{
#	print FILE2 $key,"\t$scafhash{$key}\n";

#}

close(GFFINPUT);
close(FILE2);
