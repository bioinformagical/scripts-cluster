#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in a tabbed blast file and a fasta list  and makes a new fasta file..
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 2)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $idfile= $ARGV[0] or die "echino parser \n I need a blast tab file..s. \n";
my $fastafile= $ARGV[1] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $count = 0;
my %tshash;
my @conan;
my $outfile = $idfile.".fasta";
open(OUTFILE, ">$outfile") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	$tshash{$sid}= $seq->seq;
	#print BLASTFILE $idfile,"-aa",$count,"\t",$seq->desc,"\n";
	#print OUTFILE ">",$idfile,"-aa",$count,"\n";
	#print OUTFILE $seq->seq,"\n"; 
	#print "sid=",$sid,"\n";
	$count++;

}

#die("we made Ts hash...");


# READ IN  Table and find all appropriate matches to REfseqID
open(BLASTFILE, $idfile) or die "can't read blast tabbed  file.";
my $header = <BLASTFILE>;
while (my $line = <BLASTFILE>)
{
       	chomp $line;
        my @array = split("\t",$line);
        my $second = $array[1];
	chomp $second;
	my $seq = $tshash{$second};
	if (exists $tshash{$second}) 
	{
		print OUTFILE ">",$second,"\n",$seq,"\n";
	}
	else
	{
		die "We could not find seq for $second ";
	}
}

#my @temp=split("\t",$idfile);
#my @speciesTemp=split('\.',$temp[3]);
#my $speciesID=$speciesTemp[0];
#print "The temp[3] is ", $temp[3],"\n";
#print "The speciesID is ", $speciesID,"\n";
#my $header = $speciesID."-".$refseqID;
#chomp $header;
#print "The header is ", $header,"\n";

#
#
#
 print "All Done, we made it to the end.\n"; 

#close(BLASTFILE);
close(OUTFILE);
exit;


sub calcrpkm
{
	if (@_ != 3) {die ("Wrong number of args for RPKM calulator method");}
	#	print " We are in RPKM !!\n";
	my $read = $_[0];
	 my $tslength = $_[1]/1000;
	 my $totalreads = $_[2]/1000000;
	
	 my $a = $read/$tslength;
	 my $b = $a/$totalreads;
	 $b;
	# my $a = (10**9*$read)/($tslength*$totalreads);
}


