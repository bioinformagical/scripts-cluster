#!/usr/bin/perl
#
#This reads in 2 tables from Cote MS tophat/ cufflink results.
#  Read in table 1. Make it a hash. geneID---> line
#	Read in table 2. fetch hash.
#	Write out results to new table .
#	Write out results if found in only 1 table.

use strict;
use warnings;
use Bio::SeqIO;


my $numargs = $#ARGV + 1;
if ($numargs != 2)
{
	        die("We did not can haz proper arguments, season1file and season2file \n");
}


my $season1file= $ARGV[0] or die "Phenotype Map Filterer Parser \n I need a season1 file. \n";
open(HTSEQ, $season1file) or die "can't read coord file";

my $season2file= $ARGV[1] or die "NUCMER COORD Parser \n I need a transcript file. \n";
open(GENEXP, $season2file) or die "can't read ts file";

#my $ts = new Bio::SeqIO (-file=>$tsfile, -format=>'fasta');

#####  FILL HASH WITH SEASON 1 #####
my %htseq;
#my $header = <SEASON1>;
#my $header2 =<GENEXP>;
#my $header1 =<HTSEQ>;
#chomp $header1;chomp $header2;

while (my $line = <HTSEQ>)
{
	chomp $line;
	my @entry = split("\t",$line);
	my $geneid = $entry[0];
	$htseq{$geneid}=$entry[2];
}

### Our outfiles
my $outfile1 = $season2file."-merged.txt";

open (OUT, ">$outfile1");
#print OUT $header2,"\t",$header1,"\n";


######  READ IN TABLE 2. CHECK for matches to table 1 and 
while (my $line = <GENEXP>)
{
        chomp $line;
        my @entry = split("\t",$line);
	my $geneid = $entry[0];
        if (length($geneid) < 1){ die "Eeeeek, too short\n";}
        
	if (exists  $htseq{$geneid})
	{
		print OUT $line,"\t",$htseq{$geneid},"\n";
	}
	else
	{
		die " We failed to find a partner in the hash for $geneid \n";
	}
} 

print "C'est fin\n";
close(OUT);
close(HTSEQ);
close(GENEXP);
exit;
