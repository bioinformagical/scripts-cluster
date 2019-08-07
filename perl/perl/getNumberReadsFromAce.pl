#!/usr//bin/perl
use strict;
use warnings;

my $cName;
my $ace_file= shift or die "No ace file provided";
open(ACE, $ace_file) || die("no such ace file");

my $filename1 = $ace_file.".readnum.txt";
open (OUT, ">$filename1") or die $!; 


while (my $line = <ACE>)
	{
	chomp $line;
	
	my @fields = split(' ', $line);
	if (defined $fields[0] and  $fields[0] eq "CO")
	{
		$cName= $fields[1];
	       my $numOfreads = $fields[3];
       		print OUT  $cName,"\t", $numOfreads, "\n";	       
	}
	
	if (defined $fields[0] and $fields[0] eq "AF")
	
	{
		
		#print $cName,"\t", $fields[1], "\n";
	}
	
	}

close(ACE);
close(OUT);
exit;

