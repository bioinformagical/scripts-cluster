#!/usr/bin/perl
use warnings;
use strict;
use Bio::Search::Result::BlastResult;
use Bio::SearchIO;
use Bio::SeqIO;

# This reads in Blast XML result, and generate the tabbed reults .......

my $xmlfile= $ARGV[0] or die "BLAST XML PARSER \n I need An xml file from a blast output (-5 output) \n";
#my $fastafile=$ARGV[1] or die "BLAST XML PARSER \n I need A fasta file of the query \n";

my $hitcount = 0;
my $misscount=0;
my $fastacount=0;
										
#Read in Fasta file to hash.
my %fastahash;
#dist hash for holding each escore for each fasta query.
my %disthash;

#Parsing the xml file and filling the filling hithash with tasty data.
my $file2 = new Bio::SearchIO (-file=>$xmlfile, -format=>'blastxml');

my $outfile = $xmlfile.".tabbed";
open (OUTFILE, ">$outfile") or die $!;
print OUTFILE "Query Name \t Hit Name \t Description \t score \t Escore\n";

#my $outfilehsp = $xmlfile.".hsps";
# my $alnIO = Bio::AlignIO->new(-format =>"fasta", -file =>">$outfilehsp");
#open (OUTFILE2, ">>$outfilehsp") or die $!;

my @lines;
my %deschash;

while( my $result = $file2->next_result ) 
{
  ## $result is a Bio::Search::Result::ResultI compliant object
  #print " We are in the loop \n";
  while( my $hit = $result->next_hit ) 
	{
		my $score = $hit->significance;
		my $queryname = $result->query_description;
		my @temp = split(' ',$queryname);
		my $id = $temp[0];
		print $id,"\n";
		my $match = $hit->name;
		my $length = $hit->length;
		my $rawscore = $hit->raw_score;
		my $algorithm = $hit->algorithm;
		my $desc = $hit->description;

		if ($score < 100)
		{
			print OUTFILE $queryname,"\t",$match,"\t",$desc,"\t",$rawscore,"\t",$score,"\n";
			#print OUTFILE $fastahash{$id},"\n";
			#print "Euereka !~! Just found ",$id,"\n";
		}
		else
		{
			print "score too high\n";
		}
  	}
} #DONE SEARCHING blast results
#die "we made it past hashmaking";
print "All Done, we made it to the end.\n"; 

close(OUTFILE);
#close(OUTFILE2);
exit;





