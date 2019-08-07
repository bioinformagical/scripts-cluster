#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#######           Reads in Marker table 1 and marker table 2. Find matching profiles by finding matching segments.  
#			read every 10 chars and see if that exists in a substring elsewhere. Add up how many matches you get. Keep the best score.
#			Print out the highest scoring matches.
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
my %mhash;
while (my $line = <INFILE>)
{
        chomp $line;
	my @ray=split("\t",$line);
	my $id=shift(@ray);
	my $str=join("", @ray);
	$mhash{$id}=$str;
	print "My ID is $id and the string is $str\n";
}

#my @charray;
<SECONDFILE>;
while (my $line = <SECONDFILE>)
{
	chomp $line;
	my @ray=split("\t",$line);
	my $id=shift(@ray);
	my $str=join("", @ray);
	#### Find if 10 mers in this string have a great match to strings in the hash
	my $bestscore=0;
	my $bestmark;
	foreach my $key (keys %mhash)
	{ 
		my $score=0;
		for (my $i=0;$i <126;$i++)
		{
			my $subby=substr($str,$i,20);
			#print "substring is $subby\n";
			if (index($mhash{$key}, $subby) != -1) { $score++; }		
		}
		if ($score > $bestscore) { $bestscore=$score; $bestmark=$key; print "New best score of $bestscore for $bestmark\n";}
	}

	print OUT "$bestmark\t$bestscore\t$id\t$str\n";
	
#	push(@titleray,$line);
#	my $line1=<SECONDFILE>;
	#my $line2=<SECONDFILE>;
	#my $line3=<SECONDFILE>;
	#my $id = <SECONDFILE>;
	#my @splitty = split("\t",$id);
	#$id = $splitty[0];
#	chomp $line1;
	#chomp $line2; chomp $line3;  
	#my $realline="temp";
	#print $line1.$line2.$line3;
#	print "$line\n$line1\n";
#	my @tmpray; my $convert;
#	my @ray= split("", $line1);
#	foreach my $n (@ray) 
#	{
#		if ($n eq 'a'){ $n=0;}
#		elsif ($n eq 'b'){ $n=2;}
#		elsif ($n eq 'h'){ $n=1;}
#		elsif ($n eq '-'){ $n=".";} 
		#push(@tmpray,$n);
#		$convert=$convert.$n;
#	}	
#	push(@charray,$convert);
}
#print " The size of char ray =". scalar @charray."\n";
#print " The size of title ray =". scalar @titleray."\n";
#print " The size of mark ray =". scalar @markray."\n";

####  Print header
#print OUT "Marker\t";
#for (my $i = 0; $i < scalar @titleray; $i++)
#{
#	print OUT "$titleray[$i]\t"; 
#}
#print OUT "\n";

### Iterate through names and print out a char 5085 times for each line  ###
#foreach my $n (@ray)
#for (my $i = 0; $i < scalar @markray; $i++) 
#{
#	print OUT  "$markray[$i]\t";
#	foreach my $n (@charray)
#	{
#		print OUT substr($n, $i, 1);
#		print OUT "\t"; 
#	}
#	print OUT "\n";
	#die"testbed\n";
#}

	
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

