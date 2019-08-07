#!/usr/bin/perl

use strict;
use warnings;

# Script to iteratively add an individual vcf table to THE BIG Table. 
# Read in little table into a hash  (seq-position is key, genotyping # is value (0,1 or 2 with 0 being extremely unlikely)
# iterate through big table, checking if small table hash has a match. If so, update big table with value. Othereise add 0.
#
# Once big table is exhausted, add remining little table entries as new loci and make all values 0 except for the last 1.
# 
#		BIG TABLE FORMAT
#	oat-marker-sequence	position	Reference-Allelle	alt-allelle	progeny1  progeny2  ..3  ..4   ...last
#	chr344			28		A			T		0	  0	    1    1    1  ....
#


# Variables for holding command line arguments
my $bigtablefile = $ARGV[0];
my $liltablefile =  $ARGV[1];
open(INPUTFILE, "$bigtablefile") or die "can't read file, $bigtablefile";

my @lil = split("-table",$liltablefile);
my $liltablename = $lil[0];

#my $VCFoutput = ''; 
#my $Format = '';

my $count=0;
my $goodcount=0;
# Load Big table into a hash
my $header = <INPUTFILE>;
chomp $header;
$header = $header."\t".$liltablename;
my @tmparray = split("\t",$header); 
my $numofcolumns = @tmparray;
my %bighash;
my %usedhash;  ### This hash will track whether we have updated the bighash and will update any big hash entries not yet updated at the end.
 
while ( my $line = <INPUTFILE> ) 
{
	# Scans each line to fill hash
	chomp $line;
	my @ray = split("\t",$line);
	my $id = $ray[0]."-".$ray[1];
	$bighash{$id}=$line;
	$usedhash{$id}=$line;
}
close (INPUTFILE);
#die " made it through loading of big table";

###open to the outfile now
open OUTFILE, ">$bigtablefile" or die "No open outfile" ;
print OUTFILE $header,"\n";


#########   Read in lil table and start looking for matches in big table.    ##############
my $lilfile = $liltablename."-table.txt";
open(INPUT2FILE, "$lilfile") or die "can't read file, $lilfile";


while ( my $line = <INPUT2FILE> )
{
	chomp $line;
        my @ray = split("\t",$line);
	my $id = $ray[1]."-".$ray[2];
	my $ref = $ray[3];
	my $alt = $ray[4];
	my $geno = $ray[8];
	if (length $geno > 1) {die "our genotype integer was wrong !! for $geno";}

	if (exists $bighash{$id})
	{
		
		my $tmp = $bighash{$id};
		$tmp = $tmp."\t".$geno;
		$bighash{$id}=$tmp;
		if (exists $usedhash{$id})
	        {
			delete $usedhash{$id};
		}
		else { die "usedhash did not exist while bighash did"; }
		print OUTFILE $tmp,"\n";
	}
	else
	{
		my $newentry = $ray[1]."\t".$ray[2]."\t".$ref."\t".$alt."\t";
		my $mycols = $numofcolumns-5; 
		for(my $i =0; $i <$mycols; $i++)
		{
			$newentry = $newentry."0\t";
		}
		$newentry = $newentry.$geno;
		$bighash{$id} = $newentry;
		print OUTFILE $newentry,"\n";
	}	

}	

######### Update all the remaining hash entries in used hash with a 0 and print them.
foreach my $key (keys %usedhash)
{  
	my $tmp = $usedhash{$key};
        $tmp = $tmp."\t0";
	print OUTFILE $tmp,"\n";
}


#print "OUr line count was ", $count, "\n";
#print "OUr GOOD count was ", $goodcount, "\n";
# Prints the final built VCFoutput in the .txt file format  
#print OUTFILE "$VCFoutput";

# Close opened files
close(INPUT2FILE);
close(OUTFILE);
exit;


