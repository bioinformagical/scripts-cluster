#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# This reads in a transdecoder longest.orf.pep file and rename it so that is friendly with orthomcl.  go from m.5736 to BJ43|aa5736   .
# Then write a new fasta file and log file.
#

my $numargs = $#ARGV + 1;
if ($numargs != 2)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $idname= $ARGV[0] or die "echino parser \n I need a file species ID (BJ43) ..s. \n";
my $fastafile= $ARGV[1] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $count = 0;
my %tshash;
my @conan;

open(LOGFILE, ">$idname.logfile.txt") or die "can't open log file.";
open(OUTFILE, ">$idname.faa") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	#$tshash{$sid}= $seq->seq;
	my @temp=split("\|",$sid);
	my $newname = $idname."|aa".$count;
	print $newname,"\n";
	
	print LOGFILE $newname,"\t",$sid,"\t",$seq->desc,"\n";
	print OUTFILE ">",$newname,"\n";
	print OUTFILE $seq->seq,"\n"; 
	
	$count++;

}

#die("we made Ts hash...");


# READ IN  Table and find all appropriate matches to REfseqID
#open(LOGFILE, $idname) or die "can't read refseq list file.";
#my @temp=split("\t",$idname);
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

close(LOGFILE);
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


