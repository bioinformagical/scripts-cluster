#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in a sequence file and  makes a new fasta file..
#    Will remove the 1st 15 NT from sequences because they look like adapter or are lighly repetitive.
#    Will give an arbitrary ID based on order in the file.

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $idfile= $ARGV[0] or die " line parser \n I need a sequnces file..s. \n";
#my $fastafile= $ARGV[1] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $outfile = $idfile."-chopped20.fna";
open(OUTFILE, ">$outfile") or die "can't write outfile";


#die("we made Ts hash...");


# READ IN  Table and find all appropriate matches to REfseqID
open(BLASTFILE, "$idfile") or die "can't read blast tabbed  file.";
my $header = <BLASTFILE>;



my %hash;
my $count=1;
while (my $line = <BLASTFILE>)
{
       	chomp $line;
	my $seq = substr($line, 20);
	my $id = ">tetra-$count";
	print OUTFILE ">",$id,"\n",$seq,"\n";
	$count++;	
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


