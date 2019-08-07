#!/usr/bin/perl
use strict;
use warnings;

# Script to iteratively add an individual vcf "pos" table into a column of 0,1 and 2's that match the big table.. 
#	Read in litle table. Into hash will go the seq__position elements as key and the value = genotype (0,1,2)
# Read in seq__pos.txt for each sequence-postion and check if hash has it. If yes add to that line what ever the hash value is.
#    Otherwiose add a 0.  seq__pos.txt will be 1 column thicker afterwards.
#
#
# Command  line arguments
my $bigtablefile = $ARGV[0];
my $liltablefile =  $ARGV[1];
open(INPUTFILE, "$bigtablefile") or die "can't read file, $bigtablefile";

my @lil = split("-pos",$liltablefile);
my $liltablename = $lil[0];


my $count=0;
my %lilhash;

 my $lilfile = $liltablename."-pos.txt";
 open(INPUT2FILE, "$lilfile") or die "can't read file, $lilfile";

######   Read in lil table to hash seqpos,genotype  ########
while ( my $line = <INPUT2FILE> ) 
{
	# Scans each line to fill hash
	chomp $line;
	my @ray = split("\t",$line);
	my $id = $ray[1];
	my $geno = $ray[7];
	if (length $geno > 1) {die "our genotype integer was wrong !! for $geno";}
	$lilhash{$id}=$geno;
	print "Our seqpos was ",$id," and the genotype is ",$geno,"\n";
}
close (INPUT2FILE);
#die " made it through loading of little table";

###open to the outfiles now
open OUTFILE, ">$bigtablefile.tmp" or die "No open outfile" ;
open COLFILE, ">$liltablename.-col.txt" or die "no open col file";

#########   Read in big table, line by line and append matches in little hash.    ##############
open(INPUTFILE, "$bigtablefile") or die "can't read file, $lilfile";

# Update header to include latest column name
my $header = <INPUTFILE>;
chomp $header;
$header = $header."\t".$liltablename;
print OUTFILE $header,"\n";
print COLFILE $liltablename,"\n";

while ( my $line = <INPUTFILE> )
{
	chomp $line;
        my @ray = split("\t",$line);
	my $id = $ray[0];

	if (exists $lilhash{$id})
	{
		
		my $tmp = $lilhash{$id};
		print OUTFILE $line,"\t",$tmp,"\n";
		print COLFILE $tmp,"\n";
	}
	else
	{
		print OUTFILE $line,"\t0\n";
                print COLFILE "0\n";	
	}
	$count++;
}	


print "OUr line count was ", $count, "\n";
#print "OUr GOOD count was ", $goodcount, "\n";
# Prints the final built VCFoutput in the .txt file format  
#print OUTFILE "$VCFoutput";

# Close opened files
close(INPUTFILE);
close(OUTFILE);
close(COLFILE);
exit;


