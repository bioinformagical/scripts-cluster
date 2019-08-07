#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in a fasta file ..
#Change the sequence header to include an @ 
#Print a new fasta file with a shorter name
#

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 1 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $fastafile= $ARGV[0] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

#my $count = 0;
#y %tshash;
#my @conan;

print $fastafile,"\n";
#die ("die");
my @bigname = split("-",$fastafile);
my $shortname = $bigname[2];
my @shorty = split(".t",$shortname);
print "This is shorty",$shorty[0];
#die ("die");
open(OUTFILE, ">$shorty[0].fasta") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	my @sidname = split("-",$sid);
	print OUTFILE $sidname[0],"@",$sidname[1],"\n";
	#$tshash{$sid}= $seq->seq;
	#print LOGFILE $idfile,"-aa",$count,"\t",$seq->desc,"\n";
	#print OUTFILE ">",$idfile,"-aa",$count,"\n";
	print OUTFILE $seq->seq,"\n"; 
	#print $refid,"\t sid=",$sid,"\n";
	#$count++;

}

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


#close(OUTFILE);
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


