#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in a tabbed marker file and  hunts for non unique sequencee..
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $idfile= $ARGV[0] or die "echino parser \n I need a blast tab file..s. \n";
#my $fastafile= $ARGV[1] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $count = 0;
my %tshash;
my @conan;
my $outfile = $idfile."-v3.txt";
open(OUTFILE, ">$outfile") or die "can't write outfile";


#die("we made Ts hash...");


# READ IN  Table and find all appropriate matches to REfseqID
open(BLASTFILE, "$idfile.txt") or die "can't read blast tabbed  file.";
my $header = <BLASTFILE>;



my %hash;
while (my $line = <BLASTFILE>)
{
       	chomp $line;
        my @array = split("\t",$line);
        my $second = $array[0];
	chomp $second;
	my $seq = $array[2];
	if ( exists $hash{$seq})
	{
		#print "FOR $second , IN HASH: $hash{$second}"," and just found $seq\n";  
		if (! $hash{$seq} eq $second) {print "FOR $second , IN HASH: $hash{$second}"," and just found $seq\n"; }
	}
	else
	{
		$hash{$seq}=$second;
	}

	#print OUTFILE ">",$second,"\n",$seq,"\n";
}

foreach my $key (sort keys %hash)
{
	print OUTFILE $key,"\t",$hash{$key},"\n";
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

close(BLASTFILE);
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


