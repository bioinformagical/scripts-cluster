#!/usr/bin/perl
use strict;
use warnings;

#	Read in marker file (each value is   45|0  or 0|0   or 20|3, etc
#	Change numbers to presence / absence and then convert to A B H or NA
#	####  We will do this later :  Also transpose into other direction.....!!!! 
#
# Command  line arguments
my $bigtablefile = $ARGV[0];
my $liltablefile =  $ARGV[1];
open(INPUTFILE, "$bigtablefile") or die "can't read file, $bigtablefile";
open(OUT, ">$bigtablefile.converted2ABH.txt");


my $count=0;
my $linecount=0;
my %lilhash;

my $header=<INPUTFILE>;
print OUT $header;
######   Read in lil table to hash seqpos,genotype  ########
while ( my $line = <INPUTFILE> ) 
{
	# Scans each line to fill hash
	chomp $line;
	my $newline;
	my @ray = split("\t",$line);
	my $marker = $ray[0];
	#print OUT $marker,"\t";
	#$newline=$marker."\t";
	for (my $i=1; $i < 129; $i++) 
	{
		#print "$ray[$i]\t";die;
		my @splity=split(/\|/,$ray[$i]);
		my $a=$splity[0];
		my $b=$splity[1];
		#print "$a\t$b\t";die;
		if ($a>5 && $b>5)
		{
			#print OUT "H\t";
			$newline=$newline."H\t";
			$count++;
		}
		elsif ($a>5)
		{
			#print OUT "A\t";
			$newline=$newline."A\t";
			$count++;
		}
		 elsif ($b>5)
                {
                        #print OUT "B\t";
			$newline=$newline."B\t";
			$count++;
                }
		else { #print OUT "NA\t";}
		$newline=$newline."NA\t";
		}
	}
	my $noms="";
	for (my $i=129; $i < 134; $i++)
	{
		$noms=$noms.$ray[$i]."\t";
	}
	if ($count > 120) {print OUT "$marker\t$noms","$newline\n";$linecount++;}
	$count=0;
}
close (INPUTFILE);
#die " made it through loading of little table";


print "OUr line count was ", $linecount, "\n";
#print "OUr GOOD count was ", $goodcount, "\n";
# Prints the final built VCFoutput in the .txt file format  
#print OUTFILE "$VCFoutput";

# Close opened files
close(INPUTFILE);
close(OUT);
exit;


