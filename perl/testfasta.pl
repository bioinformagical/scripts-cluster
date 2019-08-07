#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# This reads in a fasta list  and makes new fasta file.. (removing some white spaces
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 1 argument, All YOUR BASE ARE BELONG TO US\#");
}


my $fastafile= $ARGV[0] or die "Feed me transcript file ...";

open(OUTFILE, ">$fastafile.header.fasta") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	#$tshash{$sid}= $seq->seq;
	print OUTFILE ">",$sid,"\n";
	print OUTFILE $seq->seq,"\n"; 
	#print $refid,"\t sid=",$sid,"\n";
}
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


