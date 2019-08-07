#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in blasted and parsed xml table results and makes the RPKM values and makes a new table.

my $numargs = $#ARGV + 1;
if ($numargs != 3)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $xmltablefile= $ARGV[0] or die "Bowtie parser \n I need an XML parsed table file..s. \n";
my $transcriptfile= $ARGV[1] or die "Feed me transcript file ...";
my $readsfile= $ARGV[2] or die "Feed me reads file so I can figure out Total reads ...";


#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $totalreads = 0;
my %tshash;
my @conan;

my $foo = new Bio::SeqIO (-file=>$transcriptfile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	
	my $sid = $seq->display_id;
	my $sequence = $seq->seq;
	my $length = length($sequence);
	$tshash{$sid}= $length;
	#print $sid,"\t",$tshash{$sid},"\n";
}

#die("we made Ts hash...");


#READ IN READS FILE and get total sum of reads
open(READS, $readsfile) or die "can't read reads file";

while (my $line = <READS>)
{       
      chomp $line;
      my @fields = split('\t', $line);
      $totalreads = $totalreads + $fields[1];
      #  print " Total reads is now ",$totalreads," after adding ",$fields[1],"\n";
}

#die(" we read ts hash and total reads");


#READ IN BOWTIE RESULTS
#	FILTER TOO SHORT READS
#	DEFINE BOUNDARIES OF THE ALIGNED READ
#	DETERMINE HOW MANY SNPs FALL INTO THAT RANGE
#	CHECK THAT EITHER SIDE IS A CORRECT MATCH
#	UPDATE THE SNP HASH ACCORDINGLY
#print "Reading in lines from alignment file:  ",$xmltablefile,"\n";

#my $filename1 = $xmltablefile.".master.table".$column;
#open (OUTFILE, ">>xmltablefile"."SNPcounted.txt") or die $!; 

open(MASTER, $xmltablefile) or die "can't read xml parsed table.";

open (OUTFILE, ">$xmltablefile".".rpkm"); 
my $header = <MASTER>;
chomp $header;
print OUTFILE $header,"\t","RPKM","\n";

while (my $line = <MASTER>)
{
	chomp $line;
	
	my @fields = split('\t', $line);
	if (defined $fields[0] and  defined $fields[4])
	{
		my $id = $fields[0];
		my $desc = $fields[1];
		my $ts = $fields[2];
		my $reads = $fields[3];
		my $exonlength = $fields[4]; 	

		my $rpkm = &calcrpkm($reads, $exonlength, $totalreads);
		$rpkm = int(0.5+$rpkm);
		print $rpkm," is our rpkm !! \n";	
	
		for (my $x=0;$x<5;$x++)# (@tshash{$_})
		{       
			print OUTFILE $fields[$x],"\t";
		}

		print OUTFILE $rpkm,"\n";     
		
	}	
	else {  die("Our parsed xml table file, lacked the 4 columns needed !",@fields); }
}
#die (" we made it past the xml parsing step");

#
#
#Print out the hash of array table now.
##

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


