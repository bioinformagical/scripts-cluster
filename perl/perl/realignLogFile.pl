#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#######           Read in table and re write each line so that it looks like:
#  
#			p2ep marker name  |  Allan Marker name  |  Chromosome  | coordinates
#			
#			But tabs instead of pipes.

my $input= $ARGV[0] or die "\nI need A marker file \n";
#my $secondfile = $ARGV[1] or die "\nI need A fasta file \n";
#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;

#print "Please enter filename (without extension): ";
#$input = <>;

my $fileotu = "/group/p2ep/brassica/marker/p2ep-position/p2ep2brown-markers.txt";
open (OUT, ">$fileotu") or die $!;
print OUT "P2EP marker\tABrown Marker\tChrosmome\tPosition\tposition-500K\tPOsition+500K\n";
 open (INFILE, "$input") or die "Cannot open infile!";
 #open (SECONDFILE, "$secondfile") or die "Cannot open infile!";
#my @markray;
my @titleray;
my %mhash;
while (my $line = <INFILE>)
{
        chomp $line;
	my @ray=split("\t",$line);
	my $abmark=shift(@ray);
	shift(@ray);
	my $p2epmark=shift(@ray);
	
	my @pos = split("-",$abmark);
	my $chromo=$pos[1];
	my $position=$pos[2];
	$position=~ s/\D//g;
	my $posminus=$position-500000;
	my $posplus=$position+500000;	
	#$mhash{$id}=$str;
	#print "My AB  is $abmark and the p2ep marker is $p2epmark\n";
	print OUT "$p2epmark\t$abmark\t$chromo\t$position\t$posminus\t$posplus\n";

}

#my @charray;
#<SECONDFILE>;
#while (my $line = <SECONDFILE>)
#{
#	chomp $line;
#	my @ray=split("\t",$line);
#	my $id=shift(@ray);
#	my $str=join("", @ray);
#	#### Find if 10 mers in this string have a great match to strings in the hash
#	my $bestscore=0;
#	my $bestmark;
#	foreach my $key (keys %mhash)
#	{ 
#		my $score=0;
#		for (my $i=0;$i <126;$i++)
#		{
#			my $subby=substr($str,$i,20);
#			#print "substring is $subby\n";
#			if (index($mhash{$key}, $subby) != -1) { $score++; }		
#		}
#		if ($score > $bestscore) { $bestscore=$score; $bestmark=$key; print "New best score of $bestscore for $bestmark\n";}
#	}
#
#	print OUT "$bestmark\t$bestscore\t$id\t$str\n";
	

	
#close (SECONDFILE);
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

