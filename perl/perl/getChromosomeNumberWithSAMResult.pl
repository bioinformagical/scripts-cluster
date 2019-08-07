#!/usr/bin/perl

use strict;
use warnings;

# Script to  parse a sam file  and a mapping file and write the chromosme # to a new text file along with relevant Sam file details.  
#    



# Variables for holding command line arguments
my $mapfile = $ARGV[0];
my $samfile = $ARGV[1];


open(INPUTFILE, "$mapfile") or die "can't read file";

my $outfile = "/lustre/groups/p2ep/trawberry/markers/bowtie2/bowtie2-strah2refWithLG.txt";
open (OUTFILE, ">$samfile.-WITHLG.txt") or die "Cannot open outfile!";


# Loads one key at a time
my %hash;

while ( my $line= <INPUTFILE>)
{
	my @to = split("\t",$line);
	my $tp = $to[0];
	my $chromo=$to[2];
	$hash{$tp}=$chromo;
	print "$tp\t\t $chromo\n";
} 
#die;


open(SAMFILE, "$samfile") or die "can't read file";
while ( my $line= <SAMFILE>)
{
	my @splitty = split("\t",$line);
	my $tptemp=$splitty[0];
	my @split2=split("_",$tptemp);
	my $tp=$split2[0];
	my $refID=$splitty[2];
	my $start=$splitty[3];
	my $match=$splitty[5];
	my $seq=$splitty[9];
	
	my$lg=$hash{$tp};


	print OUTFILE $tp,"\t",$lg,"\t",$refID,"\t",$start,"\t",$match,"\t",$seq,"\n";
}

print "FIN";

# Close opened files
close(SAMFILE);
close(INPUTFILE);
close(OUTFILE);
exit;


