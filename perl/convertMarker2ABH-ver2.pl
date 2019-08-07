#!/usr/bin/perl
use strict;
use warnings;

#	Read in marker file (each value is  nucleotides, etc
#	Change NT to presence / absence and then convert to A B H or NA
#	####  We will do this later :  Also transpose into other direction.....!!!! 
#
# Command  line arguments
my $bigtablefile = $ARGV[0];
my $liltablefile =  $ARGV[1];
open(INPUTFILE, "$bigtablefile") or die "can't read file, $bigtablefile";
open(OUT, ">$bigtablefile-converted2ABH.txt");


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
	my @ray = split(",",$line);
	my $marker = $ray[0];
	my @allele = split(/\//,$ray[1]);
	#print  $marker,"\t",$allele[0],"\tNumber allele 2=\t",$allele[1],"\n";
	#$newline=$marker."\t";
	my $a =$allele[0];
	my $b=$allele[1];
	my $h=&fetchNT($a,$b);
	for (my $i=2; $i < 126; $i++) 
	{
		#print "$ray[$i]\t";die;
		#my @splity=split(/\|/,$ray[$i]);
		#print "$a\t$b\t";die;
		if ($a =~ $ray[$i])
		{
			#print OUT "H\t";
			$newline=$newline."A\t";
			$count++;
		}
		elsif ($b =~ $ray[$i])
		{
			#print OUT "A\t";
			$newline=$newline."B\t";
			$count++;
		}
		 elsif ($h =~ $ray[$i])
                {
                        #print OUT "B\t";
			$newline=$newline."H\t";
			$count++;
                }
		else { #print OUT "NA\t";}
		$newline=$newline."NA\t";
		print "Our NA value was $ray[$i] for $marker \n";
		}
	}
	print OUT "$marker\t$ray[1]","\t$newline\n";$linecount++;
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

sub fetchNT
{
	my $nt;
	my $x= $_[0];
	my $y=$_[1];
	if (($x =~ "A" && $y =~ "C") || $x =~ "C" && $y =~ "A") {$nt="M";} 	
	elsif (($x =~ "A" && $y =~ "G") || $x =~ "G" && $y =~ "A") {$nt="R";}
	elsif (($x =~ "A" && $y =~ "T") || $x =~ "T" && $y =~ "A") {$nt="W";}
	elsif (($x =~ "C" && $y =~ "G") || $x =~ "G" && $y =~ "C") {$nt="S";}
        elsif (($x =~ "C" && $y =~ "T") || $x =~ "T" && $y =~ "C") {$nt="Y";}
        elsif (($x =~ "G" && $y =~ "T") || $x =~ "T" && $y =~ "G") {$nt="K";}
	return $nt;
}
