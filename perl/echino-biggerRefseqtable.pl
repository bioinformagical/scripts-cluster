#!/usr/bin/perl
use strict;
use warnings;

# Script to read refseq log and the orthomcl log table to make  refseq table  and print a table with refseq names.  
#
#		OUTPUT:
#		orthoclusterID	refseqSpurp|aa40        gi|47550925|ref|NP_999636.1|    	cortical granule serine protease 1 precursor		 #ofspecimensINCLuster
# Command  line arguments
my $bigtablefile = $ARGV[0];
my $reftablefile =  $ARGV[1];
open(INPUTFILE, "$bigtablefile") or die "can't read file, $bigtablefile";

my @lil = split("-pos",$liltablefile);
my $liltablename = $lil[0];


my $count=0;
my %lilhash;

 open(INPUT2FILE, "$reftablefile") or die "can't read file, $reftablefile";

######   Read in lil table to hash seqpos,genotype  ########
while ( my $line = <INPUT2FILE> ) 
{
	# Scans each line to fill hash
	chomp $line;
	my @ray = split("\t",$line);
	my @ray2 = split(/\|/,$ray[0]);
	my $refseq = $ray2[1];
	my $refname = $ray[2];
	$lilhash{$refseq}=$line;
	print "Our refseq was ",$refseq," and the name is ",$refname,"\n";
}
close (INPUT2FILE);
#die " made it through loading of little table";

###open to the outfiles now
open OUTFILE, ">$bigtablefile.tmp" or die "No open outfile" ;

#########   Read in big table, line by line and append matches in little hash.    ##############
open(INPUTFILE, "$bigtablefile") or die "can't read file, $bigtablefile";

while ( my $line = <INPUTFILE> )
{
	chomp $line;
        my @ray = split("\t",$line);
	my @ray2 = split(/\|/,$ray[0]);
	my $id = $ray2[1];
	
	if (exists $lilhash{$id})
	{
		
		my $tmp = $lilhash{$id};
		print OUTFILE $id,"\t",$lilhash{$id},"\n";
	}
	else
	{
		die " we didn't find a mtach for ",$id, " in line ",$line,"\n";
	}
	$count++;
}	


print "OUr line count was ", $count, "\n";
#print "OUr GOOD count was ", $goodcount, "\n";

# Close opened files
close(INPUTFILE);
close(OUTFILE);
exit;


