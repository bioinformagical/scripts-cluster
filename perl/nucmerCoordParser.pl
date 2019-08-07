#!/usr/bin/perl
#
#This reads in coord file from nucmer.  Will do various analyses on the alignments.
#

use strict;
use warnings;
use Bio::SeqIO;


my $numargs = $#ARGV + 1;
if ($numargs != 3)
{
	        die("We did not can haz proper arguments, coordfile transcriptfile reffile \n");
}


my $coordfile= $ARGV[0] or die "NUCMER COORD Parser \n I need a nucmer coord file. \n";
open(COORD, $coordfile) or die "can't read coord file";

my $tsfile= $ARGV[1] or die "NUCMER COORD Parser \n I need a transcript file. \n";
#open(TSFILE, $tsfile) or die "can't read ts file";

my $ts = new Bio::SeqIO (-file=>$tsfile, -format=>'fasta');

my %tshash;
my $tscount = 0;

while (my $seq = $ts->next_seq)
{
	$tscount++;
	my $id = $seq->display_id;
	$tshash{$id}=$seq->seq;
}

my $reffile= $ARGV[2] or die "NUCMER COORD Parser \n I need a ref fasta file. \n";
#open(TSFILE, $tsfile) or die "can't read ts file";

my $rf = new Bio::SeqIO (-file=>$reffile, -format=>'fasta');

my %refhash;
my %refflaghash;
my $refcount = 0;

while (my $seq = $rf->next_seq)
{
        $refcount++;
        my $id = $seq->display_id;
        $refhash{$id}=$seq->seq;
	$refflaghash{$id}='0';
}



print " \nThe number of ts hits are: ", $tscount,"\n";
print " \nThe number of ref hits are: ", $refcount,"\n";
#read in coord file, fetch the ts hits.
my $tshitcount = 0;
my $refhitcount = 0;

#throw away 1st 5 lines
for (my $i = 0; $i < 5; $i++)
{
	my $line = <COORD>;
	print	$line,"\n";
}	

while (my $line = <COORD>)
{
	chomp $line;
	#print   $line,"\n";
	 my @entry = split(" ",$line);
	 my $s1 = $entry[0];
	 my $e1 = $entry[1];
	 my $s2 = $entry[3];
	 my $e2 = $entry[4];
	 my $len1 = $entry[6];
	 my $len2 = $entry[7];
	 my $identity = $entry[9];
	 my $seqid1 = $entry[11];
	 my $seqid2 = $entry[12];
	
	print $seqid1,"\t",$e1,"\n";
	$tshitcount++  if exists $tshash{$seqid2};
	if (exists $refhash{$seqid1})
	{
		if($refflaghash{$seqid1} eq '0')
		{
			$refhitcount++;
			$refflaghash{$seqid1} = 1;
		}
	}
	#	die ("a horribel death.");	 
}

print "total number of transcripts that aligned were ",$tshitcount," out of ",$tscount,"\n";
print "total number of transcripts that aligned were ",$refhitcount," out of ",$refcount,"\n";

close(COORD);

