#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#######           Reads in tetraploid marker sequence table  curently makes fasta file 
#			Read in marker list and print only those from that list that are tetraploid, ie contain "TP".
#

my $input= $ARGV[0] or die "\nI need A marker file \n";
my $secondfile = $ARGV[1] or die "\nI need A fasta file \n";
#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;

#print "Please enter filename (without extension): ";
#$input = <>;

my $fileotu = $input."-converted.txt";
open (OUT, ">$fileotu") or die $!;

 open (INFILE, "$input") or die "Cannot open infile!";
 open (SECONDFILE, "$secondfile") or die "Cannot open infile!";
my @markray;
my @titleray;
push(@titleray, "OrderGenotype");
while (my $line = <INFILE>)
{
        chomp $line;
	push(@markray, $line);
}

my @charray;
while (my $line = <SECONDFILE>)
{
	chomp $line;
	push(@titleray,$line);
	my $line1=<SECONDFILE>;
	#my $line2=<SECONDFILE>;
	#my $line3=<SECONDFILE>;
	#my $id = <SECONDFILE>;
	#my @splitty = split("\t",$id);
	#$id = $splitty[0];
	chomp $line1;
	#chomp $line2; chomp $line3;  
	#my $realline="temp";
	#print $line1.$line2.$line3;
	print "$line\n$line1\n";
	my @tmpray; my $convert;
	my @ray= split("", $line1);
	foreach my $n (@ray) 
	{
		if ($n eq 'a'){ $n=0;}
		elsif ($n eq 'b'){ $n=2;}
		elsif ($n eq 'h'){ $n=1;}
		elsif ($n eq '-'){ $n=".";} 
		#push(@tmpray,$n);
		$convert=$convert.$n;
	}	
	push(@charray,$convert);
}
print " The size of char ray =". scalar @charray."\n";
print " The size of title ray =". scalar @titleray."\n";
print " The size of mark ray =". scalar @markray."\n";

####  Print header
print OUT "Marker\t";
for (my $i = 0; $i < scalar @titleray; $i++)
{
	print OUT "$titleray[$i]\t"; 
}
print OUT "\n";

### Iterate through names and print out a char 5085 times for each line  ###
#foreach my $n (@ray)
for (my $i = 0; $i < scalar @markray; $i++) 
{
	print OUT  "$markray[$i]\t";
	foreach my $n (@charray)
	{
		print OUT substr($n, $i, 1);
		print OUT "\t"; 
	}
	print OUT "\n";
	#die"testbed\n";
}

	
close (SECONDFILE);
close (OUT);
close (INFILE);
exit;


#--------------------------------------------------------------------------------
# chomp_fasta: Merges all the sequence lines in a fasta file into one line, so
#              each sequence in the fasta file will have one header line and 
#              one sequence line only
#--------------------------------------------------------------------------------

sub chomp_fasta {

open (INFILE, "$input") or die "Cannot open infile, ",$input;
open (OUT, ">"."$input"."_chomped.fasta") or die "Cannot open outfile!";

while (my $line=<INFILE>) { # Please remove the spaces

if ($line=~/>/) {
print OUT "\n$line";
}

else {
chomp ($line);
print OUT "$line";
}

}
close OUT;
}

