#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

# Script to read in loci.txt and write out a new fasta for each line in loci.txt. 

# Variables for holding command line arguments
my $locifile = $ARGV[0];
my $reffile = $ARGV[1];

open(LOCIFILE, $locifile) or die "can't read file";
#open(REFFILE, $reffile) or die "can't read ref file";

my $outfile = $locifile.".fasta";
open OUTFILE, ">$outfile" or die "No open outfile" ;

my %hash;

my $foo = new Bio::SeqIO (-file=>$reffile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	$hash{$sid}= $seq->seq;
#	print "Adding to new hash! :",$sid,"\t",$seq->seq,"\n";
}
print "hash filled, with this many:", scalar keys %hash,"\n";
#die;

#
#####   READ IN Loci.txt check hash for a match and report the results #####
#
my $zerocount=0;
my $onecount=0;
my $goodcount=0;
my $fourcount=0;
my $headthing=<LOCIFILE>;

while ( my $line = <LOCIFILE> )     
{
	chomp $line;
	my @splity= split("\t", $line);
	my $marker= $splity[1];
	chomp $marker;
	
	my $signal=1;
	if (exists $hash{$marker})
	{
		print OUTFILE ">",$marker,"\n",$hash{$marker},"\n";
		$zerocount++;
	}
	else
	{
		die "Marker did not exist, Screwed !   :",$marker;
	}

}
$fourcount=$fourcount+$zerocount;
print "\n\nMarkers found = ",$zerocount,"\n";
# print "Markers with less than 4 hits = ",$fourcount,"\n";
#print "Markers with less than 20 hits = ",$onecount,"\n";
#print "Markers with 20 or greater hits = ",$goodcount,"\n";


# Close opened files
close(LOCIFILE);
close(OUTFILE);
exit;


