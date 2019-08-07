#!/usr/bin/perl

use strict;
use warnings;

# Script to filter the .vcf file to a more readable form, removing all lines that have low quality scores. QUAL score < 10 ( PHRED score meaning 1 in 10 chhance of being a miscalled variant)


# Variables for holding command line arguments
my $file = $ARGV[0];

open(INPUTFILE, "$file.vcf") or die "can't read file, $file";

my $outfile = $file."-table.txt";
open OUTFILE, ">$outfile" or die "No open outfile" ;
my $VCFoutput = ''; 
#my $Format = '';

my $count=0;
my $goodcount=0;
# Loads VCFfile one line at a time
while ( my $VCFfile = <INPUTFILE> ) {
# Scans for lines beginning with chr*
	if ($VCFfile !~ m/^#/g) 
	{
		$count++;
# For lines beginning with chr* split the line into an array based on tab separations
		my @VCFfileArray = split ("\t", $VCFfile);

		my $qual = $VCFfileArray[5];
		if ( $qual >= 30.0 ) { print "Good one at ",$qual,"\n";$goodcount++;}
# Marker of VCFfile line
	    #print "$VCFfile\n\n";
# Marker for 7th column containing PHRED value (no. of occurences)?
	    #print $VCFfileArray[7] . "\n\n";
# Keep only lines with PHRED value above threshold listed below
	my @infoline = split(";",$VCFfileArray[7]);
	#print $infoline[0],"\n";
        my @dp;
	my $dpvalue=-10;
	if ($infoline[0] !~ m/^INDEL/g)
	{
		@dp=split("=",$infoline[0]);
	        if ( $dp[1] >= 4.00 ) 
		{
			$dpvalue=$dp[1];
			#print "OUr DP value is ",$dpvalue,"\n";
		}
	my @gtline = split(":",$VCFfileArray[9]);
	#print "The PL values are",$gtline[1],"\n";
	my $gt="badger";
	my $pl =$gtline[1];
	my $gq =$gtline[2];
	
	
	my @pltemp = split(",",$pl);
	my $plcheck = $pltemp[0];
	my $genotype = "moo";

	if ($gtline[0] eq '0/1'){ $gt=$VCFfileArray[3].$VCFfileArray[4];$genotype=1;}
        elsif ($gtline[0] eq '1/0'){ $gt=$VCFfileArray[4].$VCFfileArray[3]; $genotype=1; }
	elsif ($gtline[0] eq '1/1'){ $gt=$VCFfileArray[4].$VCFfileArray[4];$genotype=2; }	
	else {die ("We didn't get what we needed for GT:",$gtline[0]);}
	
	#print $gtline[0],"\n";
	#print "GT=:",$gt,"\n";
# Test marker for correct calculations
	#print "Entered true: DP >= 10.00\n";
# Set up format for output lines
		if ($dpvalue > 0 && $gq > 15)
		{
			my $Format = "$file\t$VCFfileArray[0]\t$VCFfileArray[1]\t$VCFfileArray[3]\t$VCFfileArray[4]\t$VCFfileArray[5]\t$dpvalue\t$gt\t$genotype\t$pl\t$gq";
			print OUTFILE $Format;
		}
# Test marker for correct format
		#print $Format . "\n\n";
	
# Concatenate lines kept for output
		#$VCFoutput = $VCFoutput . $Format;
	
	}
	else {
# Marker for PHRED reads below 450.00
		print "Likely an INDEL: ",$infoline[0],"\n";
	}
    }
}

print "OUr line count was ", $count, "\n";
print "OUr GOOD count was ", $goodcount, "\n";
# Prints the final built VCFoutput in the .txt file format  
#print OUTFILE "$VCFoutput";

# Close opened files
close(INPUTFILE);
close(OUTFILE);
exit;


