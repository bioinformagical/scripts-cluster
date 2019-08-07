#!/usr/bin/perl
#
#This reads in 2 tables from Allan Brown's joint map results.
#  Read in table 1. Filter out any entries with fail to meet filter criteria.
#	Read in table 2. Filter out by criteria.
#	Write out results to new table if results are found in both tables.
#	Write out results if found in only 1 table.
		
#

use strict;
use warnings;
use Bio::SeqIO;


my $numargs = $#ARGV + 1;
if ($numargs != 2)
{
	        die("We did not can haz proper arguments, season1file and season2file \n");
}


my $season1file= $ARGV[0] or die "Phenotype Map Filterer Parser \n I need a season1 file. \n";
open(SEASON1, $season1file) or die "can't read coord file";

my $season2file= $ARGV[1] or die "NUCMER COORD Parser \n I need a transcript file. \n";
open(SEASON2, $season2file) or die "can't read ts file";

#my $ts = new Bio::SeqIO (-file=>$tsfile, -format=>'fasta');

#####  FILL HASH WITH SEASON 1 #####
my %s1;
my $header = <SEASON1>;
my $header2 =<SEASON2>;

while (my $line = <SEASON1>)
{
	chomp $line;
	my @entry = split("\t",$line);
	my $nr = $entry[0];
	my $position = $entry[2];
	my $locus = $entry[3];
	my $nrinf = $entry[7];
	my $signif = $entry[6];
	if (length($signif) < 3){ next;}
	if ($nrinf < 80) {next;} 	
	if (exists  $s1{$locus})
        {
		die "We should not have had a duplicate";
	}
	
	$s1{$locus}=$line;
}

### Our outfiles
my $outfile1 = $season1file."-singles.txt";
my $outfile2 = $season1file."-merged.txt";

open (SINGLE, ">$outfile1");
open (MERGED, ">$outfile2");
print MERGED "S1-GROUP\tS2-GROUP\tPOSITION\tLOCUS\tS1-K-score\tS1-Significance\tS1-NR-INF\tS2-K-score\tS2-Significance\tS2-NR-INF\n";
print SINGLE "S1-GROUP\tS2-GROUP\tPOSITION\tLOCUS\tS1-K-score\tS1-Significance\tS1-NR-INF\tS2-K-score\tS2-Significance\tS2-NR-INF\n";



######  READ IN TABLE 2. CHECK for matches to table 1 and 
while (my $line = <SEASON2>)
{
        chomp $line;
        my @entry = split("\t",$line);
	my $nr = $entry[0];
        my $group = $entry[1];
	my $position = $entry[2];
        my $locus = $entry[3];
        my $k2 = $entry[4];
	my $nrinf = $entry[7];
        my $signif = $entry[6]; 
        if (length($signif) < 3){ next;}
        if ($nrinf < 80) {next;}
        
	if (exists  $s1{$locus})
	{
		my @s1array = split("\t",$s1{$locus});
		my $k1 = $s1array[4];
		my $group1 = $s1array[1];
		my $sig1 = $s1array[6];
		my $nrinf1 = $s1array[7];

		print MERGED "$group1\t$group\t$position\t$locus\t$k1\t$sig1\t$nrinf1\t$k2\t$signif\t$nrinf\n";
		delete($s1{$locus});
	}
	else
	{
		print SINGLE "NA\t$group\t$position\t$locus\tNA\tNA\tNA\t$k2\t$signif\t$nrinf\n";
	}

} 

foreach my $key ( keys %s1 )
{
	my @entry = split("\t",$s1{$key});
        my $group = $entry[1];
        my $position = $entry[2];
        my $locus = $entry[3];
        my $nrinf = $entry[7];
        my $signif = $entry[6];	
	my $kscore = $entry[4];

	print SINGLE "$group\tNA\t$position\t$locus\t$kscore\t$signif\t$nrinf\tNA\tNA\tNA\n";
}

print "C'est fin\n";
close(SEASON1);
close(SEASON2);
close(MERGED);
close(SINGLE);
exit;
