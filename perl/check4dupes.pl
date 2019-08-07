#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in a fasta list  and checks headers for duplicates.
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 1 arguments, All YOUR BASE ARE BELONG TO US\#");
}


#my $idfile= $ARGV[0] or die "echino parser \n I need an acc file..s. \n";
my $fastafile= $ARGV[0] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $count = 0;
my %tshash;
my @conan;

#open(LOGFILE, ">$idfile.logfile.txt") or die "can't open log file.";
open(OUTFILE, ">$fastafile.dupes") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	if (exists $tshash{$sid})
	{
		print OUTFILE $sid,"\n";
	}
	else
	{
		$tshash{$sid}= $seq->seq;
		#print OUTFILE ">",$idfile,"-aa",$count,"\n";
	}
	$count++;
}

my $hashsize = keys %tshash;
print " after dupe check, totaL COUNT WAS ",$count, " and hash count was ",$hashsize,".\n";

#die("we made Ts hash...");


# READ IN  Table and find all appropriate matches to REfseqID
#open(LOGFILE, $idfile) or die "can't read refseq list file.";
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


