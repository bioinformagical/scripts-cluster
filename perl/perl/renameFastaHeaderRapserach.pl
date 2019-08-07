#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# This reads in an id and a fasta list  and makes new headers for the fasta file..
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 2)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $idfile= $ARGV[0] or die "echino parser \n I need an acc file..s. \n";
my $fastafile= $ARGV[1] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $count = 0;
my %tshash;
my @conan;

open(OUTFILE, ">$idfile.header.faa") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	
	my @splitty = split(" ",$sid);
	#print " Split was: ",$splitty[0],"\n";
	print OUTFILE ">",$splitty[0],"\n";
	print OUTFILE $seq->seq,"\n"; 
	#print $refid,"\t sid=",$sid,"\n";
	$count++;

}
#die("we made Ts hash...");
 print "All Done, we made it to the end.\n"; 

close(OUTFILE);
exit;


