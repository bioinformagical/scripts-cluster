#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# This reads in an id and a fasta list  and punches out that id as a new fasta file..
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get correct # of arguments, All YOUR BASE ARE BELONG TO US\#");
}


#my $idfile= $ARGV[0] or die "echino parser \n I need an acc file..s. \n";
my $fastafile= $ARGV[0] or die "Feed me transcript file ...";
my $id="scaffold665";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $count = 0;
my %tshash;
my @conan;

#open(OUTFILE, ">/lustre/groups/p2ep/brassica/annot/split/$id-brass-genome.fna") or die "can't write outfile";
open(OUTFILE, ">./$id-extract.fna") or die "can't write outfile";

my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	#$tshash{$sid}= $seq->seq;
	if ($sid eq $id)
	{
		my $sequence = $seq->seq;
		my $subseq = substr $sequence, 75000, 12000; 
		print OUTFILE ">",$sid,"\n";
		print OUTFILE $sequence,"\n";
		exit; 
	}
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

#close(LOGFILE);
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


