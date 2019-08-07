#!/usr/bin/perl
use strict;
use warnings;


# This reads in blasted and parsed xml table results and makes the RPKM values and makes a new table.

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 1 argument, All YOUR BASE ARE BELONG TO US\#");
}


my $readtable= $ARGV[0] or die "Bowtie parser \n I need an XML parsed table file..s. \n";


#READ IN READS repeat FILE and make some fasta babies 
open(READS, $readtable) or die "can't read reads file";
open(OUTFILE, ">$readtable".".fasta");

while (my $line = <READS>)
{       
      chomp $line;
      my @fields = split('\t', $line);
      #$totalreads = $tddotalreads + $fields[1];
      print " id is  now ",$fields[0]," and seq is ",$fields[2],"\n";
      print OUTFILE ">",$fields[0],"\n",$fields[2],"\n";
}

die(" we read ts hash and total reads");

	

#	print OUTFILE $rpkm,"\n";     
		
#
#Print out the hash of array table now.
##

 print "All Done, we made it to the end.\n"; 

close(READS);
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


