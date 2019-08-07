#!/usr//bin/perl
use strict;
use warnings;

# This will read in an ACE file
# This will take all of the reads from the ACE and put them in a hash.
#      (lines that start with AF	read.f)
#This will read in mates pair file and check each set of mates to see
#if they exist in the ace hash.
#
#If they do, they get written to a new MatesPair File.



my $cName;
my $ace_file= shift or die "No ace file provided";
open(ACE, $ace_file) || die("no such ace file");

my $mates_file= shift or die "No ace file provided";
open(MATES, $mates_file) || die("no such mates file");


my $outfile = $mates_file.".filtered";
open (OUT, ">$outfile") or die $!; 


my %readhash;

my $count=0;
my $seqflag=0;
my $seq = "";

while (my $line = <ACE>)
{
	chomp $line;
	if ( $line =~ /^AF/)
	{
		
		my @entry = split(" ",$line);
		my $id = $entry[1];
		#print "Valid line !!", $id, "\n";
		#next;	
		if (exists $readhash{$id})
		{
			die ("Our hash already had this id",$id);
		}
		$readhash{$id} = "";
		$count++
	}
	
	
}

print "The hash size was  ",$count,"\n";

while (my $line = <MATES>)
{
	        chomp $line;
		if ($line =~ /^library/)
		{
			print OUT $line,"\n";
			next;
		}
		 my @entry = split("\t",$line);
		 my $id1 = $entry[0];
		 my $id2 = $entry[1];

		 if (exists $readhash{$id1})
		{
			if (exists $readhash{$id2})
				{
					print OUT $line,"\n";
				}			
		}
}




close(ACE);
close(OUT);
close(MATES);
exit;

