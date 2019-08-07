#!/usr//bin/perl
use strict;
use warnings;

my $cName;
my $ace_file= shift or die "No ace file provided";
open(ACE, $ace_file) || die("no such ace file");

my $filename1 = $ace_file.".readnum.txt";
open (OUT, ">$filename1") or die $!; 
my $fasta = $ace_file.".fa";
open (FASTA, ">$fasta") or die $!;


my $flag=0;
my $seqflag=0;
my $seq = "";

while (my $line = <ACE>)
{
	chomp $line;
	if ( $line =~ /^$/)
	{
		if ($flag == 1)
		{
			print FASTA  $seq,"\n";
		}
		$flag=0;
		$seq = "";
		#print "blank line ! \n";
		next;	
	}
	
	 if ($flag == 1)
	 {
		$seq = $seq.$line;
	 }



	my @fields = split(' ', $line);
	if (defined $fields[0] and  $fields[0] eq "CO")
	{
		$cName= $fields[1];
	       my $numOfreads = $fields[3];
       		print OUT  "goleafs",$cName,"\t", $numOfreads, "\n";
 		$flag = 1;
		print FASTA ">","goleafs",$cName,"\n";		
	}
	
}

close(ACE);
close(OUT);
close(FASTA);
exit;

