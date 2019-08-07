#!/usr/bin/perl

use strict;
use warnings;
use POSIX;

# Script to parse coverage file generated from alignements and variant calls and then iterate through each of the marker headers#  and calculate # of reads for each marker.

# Variables for holding command line arguments
my $coveragefile = $ARGV[0];
my $markerfile = $ARGV[1];

open(COVERFILE, $coveragefile) or die "can't read file";
open(MARKERFILE, $markerfile) or die "can't read marker file";

my $outfile = $coveragefile."-markered.txt";
open OUTFILE, ">$outfile" or die "No open outfile" ;
my $statsfile =  $coveragefile.".stats";
open STATSFILE, ">$statsfile" or die "No open outfile" ;

my %coverhash;
my %Nhash;
my %tallyhash;

while ( my $line = <COVERFILE> ) 
{
	chomp $line;
	my @splity= split("\t", $line);
	my $mark= $splity[0];
	my $reads=$splity[2];
	chomp $reads;

	if (exists $Nhash{$mark})
	{
		my $numreads = $tallyhash{$mark}+$reads;
		$tallyhash{$mark}=$numreads;
		my $temp = $Nhash{$mark}+1;
		$Nhash{$mark}=$temp;
	
		#if ($reads > $coverhash{$mark})
		#{
		#	$coverhash{$mark}=$reads;
		#}
	}
	else
	{
		$tallyhash{$mark}=$reads;
		$Nhash{$mark}=1;
		#$coverhash{$mark}=$reads;
		#print "Adding to new hash! :",$mark,"\t",$reads,"\n";
	}
}
print "hash filled, with this many:", scalar keys %coverhash,"\n";
#die;

### CREATE average REAd count for each marker  ###
foreach my $key (keys(%Nhash))
{
	my $n = $Nhash{$key};
	my $total = $tallyhash{$key};
	my $average=(10*$total/$n);
	$average=floor($average)/10;
	$coverhash{$key}=$average;
	print "N =",$n,"\tTotal =",$total,"\tAverage=",$average."\n";
}
#die "This is fun";


#
#####   READ IN MArkers, check hash for a match and report the results #####
#
my $zerocount=0;
my $onecount=0;
my $goodcount=0;
my $fourcount=0;
while ( my $line = <MARKERFILE> )     
{
	chomp $line;
	my @splity= split("\t", $line);
	my $marker= $splity[0];
	chomp $marker;
	
	my $signal=1;
	if (exists $coverhash{$marker})
	{
		if ($coverhash{$marker} > 9){$signal=2;$goodcount++;}
		if ($signal==1) {$onecount++;}
		#if ($coverhash{$marker} < 2){$fourcount++;}
		print OUTFILE $marker,"\t",$coverhash{$marker},"\t",$signal,"\n";
	}
	else
	{
		$zerocount++;
		print OUTFILE $marker,"\t0\t0","\n";
	}

}
$fourcount=$fourcount+$zerocount;
print STATSFILE $coveragefile,"\n";
print STATSFILE "\n\nMarkers with no hits = ",$zerocount,"\n";
# print "Markers with less than 4 hits = ",$fourcount,"\n";
print STATSFILE "Markers with less than 20 hits = ",$onecount,"\n";
print STATSFILE "Markers with 10 or greater hits = ",$goodcount,"\n";

print "\n\nMarkers with no hits = ",$zerocount,"\n";
# print "Markers with less than 4 hits = ",$fourcount,"\n";
print "Markers with less than 10 hits = ",$onecount,"\n";
print "Markers with 10 or greater hits = ",$goodcount,"\n";

# Close opened files
close(COVERFILE);
close(MARKERFILE);
close(STATSFILE);
close(OUTFILE);
exit;


