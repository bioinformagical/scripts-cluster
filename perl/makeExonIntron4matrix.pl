#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# Script to create 2 fasta files   for purposes of a matrix for genemark.
#	Files will look like many exons (coding sequences) and introns (much non coding sequence) 
#
#	Reads in text file of gff lines that have coordinates for CDS.
#	Grab between coordinates for exon related fasta file.
#	Grab outside of that region for introns.
#	
#	CUrrently assumes only 1 sequence in FASTA FILE !!!!!!!

# Command  line arguments
my $gfffile = $ARGV[0];
my $fastafile =  $ARGV[1];
open(INPUTFILE, "$gfffile") or die "can't read file, $gfffile";

my $count=0;
my $sequence;
my $prevstop = 0;

###open to the outfiles now
open EXONFILE, ">/lustre/groups/p2ep/strawberry/fromGDR/temp/$gfffile-exon.fna" or die "No open outfile" ;
open INTRONFILE, ">/lustre/groups/p2ep/strawberry/fromGDR/temp/$gfffile-intron.fna"or die "No open outfile" ;
#########   Read in fasta and write out results in taxaseq.file format.    ##############

my $file1 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $file1->next_seq)
{
                my $sid = $seq->display_id;# print "ref ", $sid, "\n";
                $sequence = $seq->seq;
		
	#	print OUTFILE $lilhash{$num},":bj",$num,"|$lastbit\n";
		
}

 ######   Read in taxa table to hash taxa,bj#  ########
while ( my $line = <INPUTFILE> )
{
	if ($count > 1000) {next;} ### Only grabbing the first 1000.    

    # Scans each line to fill hash
        chomp $line;
        my @ray = split("\t",$line);   
        my $start = $ray[3];
        my $stop = $ray[4];   
        #print "Our start was ",$start," and the stop is ",$stop,"\n";
	my $offset = $stop-$start;
	my $exonsub=substr($sequence,$start,$offset);
	print EXONFILE ">",$ray[0],":",$start,"-",$stop,"\n", $exonsub,"\n";
	$offset = $start-$prevstop;
	my $intronsub=substr($sequence,$prevstop,$offset);
	if (! $prevstop ==0) {
		print INTRONFILE ">",$ray[1],":",$prevstop,"-",$start,"\n",$intronsub,"\n";
	}
	$count++;
	$prevstop=$stop;
}
close (INPUTFILE);


	
	$count++;
	


print "OUr line count was ", $count, "\nFIN\n";
#print "OUr GOOD count was ", $goodcount, "\n";

# Close opened files
close(EXONFILE);
close(INTRONFILE);
exit;


