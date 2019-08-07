#!/usr/bin/perl
use strict;
use warnings;

# Script to read refseq fasta aa and get entrez accession number and produce a new text file of entrez IDs.  
#
# Command  line arguments
my $fastafile = $ARGV[0];
my $liltablefile =  $ARGV[1];
open(FASTA, "$fastafile") or die "can't read file, $fastafile";

my @lil = split("-pos",$liltablefile);
my $liltablename = $lil[0];


my $count=0;
my %lilhash;

 open(INPUT2FILE, "$liltablefile") or die "can't read file, $liltablefile";


while (my $line=<FASTA>) 
{
	if ($line =~/^>/) 
	{ 
		my @splitty=split(/\|/,$line);
		my $gi=$splitty[1];
		my $acc=$splitty[3];
		print " GI is $gi and acc is $acc\n";

	}
}





print "OUr line count was ", $count, "\n";
#print "OUr GOOD count was ", $goodcount, "\n";

# Close opened files
close(FASTA);
close(INPUT2FILE);
exit;


