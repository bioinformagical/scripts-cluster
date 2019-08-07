#!/usr/bin/perl
#
#This reads in a tallymer search result file (for characterizing kmer composition of fasta sequences) 
#
#Read in the file
#	For each sequence (coloumn 1 = fasta sequence designation 0,1,2,3....etc)
#		tally up all the unique kmers.
#		Tally up all kmer hits (column 3) for each of those unique kmers
#
#		print seq#(column 0)	Sum of unique kmers	Sum of talliedKmerHits	LAMBDA
#
#		LAMBDA = log10  C(k,v,s) + 1      /     |mer(k(v)|
#		       =  log10   sumof talliedkmerhits +1       /    Sum of unique kmers	 
#

use strict;
use warnings;


my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	        die("We did not can haz proper arguments, coordfile transcriptfile reffile \n");
}


my $searchfile= $ARGV[0] or die "NUCMER COORD Parser \n I need a nucmer coord file. \n";
open(SEARCH, $searchfile) or die "can't read coord file";

my $filename1 = $searchfile.".lambded";
open (OUT, ">$filename1") or die $!;


#throw away 1st 5 lines
#for (my $i = 0; $i < 5; $i++)
#{
#	my $line = <COORD>;
#	print	$line,"\n";
#}	
my $num = 0;
my $kmerhits = 0;
my %seqhash;

while (my $line = <SEARCH>)
{
	chomp $line;
	#print   $line,"\n";
	 my @entry = split("\t",$line);
	 my $seqid = $entry[0];
	 my $loc = $entry[1];
	 my $numhits = $entry[2];
	 my $kmer = $entry[3];
	
#	print $seqid,"\t",$kmer,"\n";

	if (!($seqid == $num))
	{
		my $size = keys %seqhash;
	
		for (keys %seqhash)
	        {
			$kmerhits = $kmerhits +  $seqhash{$_};		
		}

	
	
	
		my $lambda = calcLambda($kmerhits, $size);		

		
		print OUT  $num,"\t",$size,"\t",$kmerhits,"\t",$lambda,"\n";
		
		#Clear teh numbers for the next sequence
		$num = $seqid;	
		$kmerhits = 0;
		for (keys %seqhash)
		{
			delete $seqhash{$_};
		}
	}	
	
	#$kmerhits = $kmerhits + $numhits;
	

	if (exists $seqhash{$kmer})
	{
		#die ("Duplicates do exist, c'est drole.");
		#print "Dup found for ",$seqid, ", seq was ",$kmer,"\n";
	}
	else
	{
		$seqhash{$kmer}=$numhits;
	}
	#	die ("a horribel death.");	 
}

#print "total number of transcripts that aligned were ",$tshitcount," out of ",$tscount,"\n";
#print "total number of transcripts that aligned were ",$refhitcount," out of ",$refcount,"\n";

close(SEARCH);
close(OUT);
exit;


sub calcLambda
{
	my $kmerhits = $_[0];
	my $size = $_[1];
	my $lambda = $kmerhits + 1;
        $lambda = $lambda / $size;
	$lambda =  log($lambda)/log(10);      
	return $lambda;
}

