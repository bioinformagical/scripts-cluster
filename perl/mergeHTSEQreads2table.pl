#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in a read count table from htseq and add the data to a master read table as a new column on the end.

my $numargs = $#ARGV + 1;
if ($numargs != 3)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $masterTablefile= $ARGV[0] or die "Bowtie parser \n I need an XML parsed table file..s. \n";
my $readsfile= $ARGV[1] or die "Feed me transcript file ...";
my $subjectid= $ARGV[2] or die "Need a single subject ID number";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $totalreads = 0;
my %readhash;
my @conan;

#die("we made Ts hash...");


#READ IN READS FILE and get total sum of reads
open(READS, $readsfile) or die "can't read reads file";
my $throwaway=<READS>;
while (my $line = <READS>)
{       
      chomp $line;
      my @fields = split('\t', $line);
      my $geneid=$fields[0];
      my $readnum = $fields[1];
      $readhash{$geneid} = $readnum;
	$totalreads++;
        #print " Total reads is now ",$totalreads," after adding ",$fields[1],"\n";
}

#die(" we read read hash and total reads");


open(MASTER, $masterTablefile) or die "can't read xml parsed table.";
open (OUTFILE, ">$masterTablefile.new");

my $header = <MASTER>;
chomp $header;
my $newdata = "$header\t$subjectid\n";
print OUTFILE "$newdata";

while (my $line = <MASTER>)
{
	chomp $line;
	
	my @fields = split('\t', $line);
	my $geneid = $fields[0];
	#print $geneid," was our gene ID\n";
	if (exists $readhash{$geneid})
	{
		print OUTFILE $line,"\t",$readhash{$geneid},"\n";
	}
	else {  die("failed to geneID  needed !",@fields); }
}
#die (" we made it past the xml parsing step");

#
#

 print "All Done, we made it to the end.\n"; 

close(READS);
close(MASTER);
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


