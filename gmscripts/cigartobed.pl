#!/usr/bin/perl -w

use strict;

my $fName1= $ARGV[0] or die "CIGAR to BED converter 1 \nI need A CIGAR file as input.\n";
my $filename2 = $fName1.".bed";
open (FILE2, ">$filename2") or die $!;

open(GFFINPUT, $fName1);

while (<GFFINPUT>) 
{
     	next if /^#/;
	my ($line) = $_;
	#print $line,"\n";
	
	my @gffarray = split('\t', $line);
	#print $gffarray[3], "\t",$gffarray[4],"\n";
    	my $start = $gffarray[5];
	my $stop = $gffarray[6];
	my $seq_id = $gffarray[4];
	$start = $start--;
	# output
	#print $seq_id,"\t",$start,"\t",$stop,"\n";
    	print FILE2 $seq_id,"\t",$start,"\t",$stop,"\n";
}
close(GFFINPUT);
close(FILE2);