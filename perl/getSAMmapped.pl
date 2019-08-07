#!/usr/bin/perl

use strict;
use warnings;

# Script to  parse a samtools flagstat stat file and write 1 line to "mappedSummary.txt". 
#    



# Variables for holding command line arguments
my $flagstatfile = $ARGV[0];


open(INPUTFILE, "$flagstatfile.stat") or die "can't read file";

my $outfile = "/lustre/groups/p2ep/oat/badassay/bwa/mappedSummary.txt";
open OUTFILE, ">>$outfile" or die "No open mappedsummary outfile" ;

# Loads one key at a time
my $total = <INPUTFILE>; 
my @totally = split(' ',$total);
print OUTFILE $flagstatfile,"\t",$totally[0],"\t";

### get # mapped ands # of duplicate reads
my @dup =  split(' ',<INPUTFILE>);
my $duppy = $dup[0];

my @mapped =  split(' ',<INPUTFILE>);
my $mappy = $mapped[0];

my $percentbit = $mapped[4];
my @perc = split(/[(%]/,$percentbit);
my $perccy = $perc[1];

print OUTFILE $mappy,"\t",$perccy,"\t",$duppy,"\n";

print "FIN";

# Close opened files
close(INPUTFILE);
close(OUTFILE);
exit;


