#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# This reads in a fasta list  and makes   new fasta file, hopefully solving why it has issues be read because of new line chars...
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 2)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


#my $idfile= $ARGV[0] or die "echino parser \n I need an acc file..s. \n";
my $fastafile= $ARGV[0] or die "Feed me transcript file ...";
my $idfile=$ARGV[1] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
open (FILE, $idfile) or die $!;

my $count = 0;
my %tshash;
my @conan;

#open(LOGFILE, ">$idfile.logfile.txt") or die "can't open log file.";
open(OUTFILE, ">$idfile-2take6.fna") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	my $len = $seq->seq;
	$tshash{$sid}=$len;
	$count++;
}

while (my $line = <FILE>)
{
	chomp $line;
	if (exists $tshash{$line})
	{
		print OUTFILE ">$line\n($tshash{$line}\n"; 
	}
	else
	{
		die " Not found $line at all\n";
	}


}

print "All Done, we made it to the end.\n"; 

close(FILE);
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


