#!/usr/bin/perl
use warnings;
use Bio::Search::Result::BlastResult;
use Bio::SearchIO;
use Bio::SeqIO;

# This reads in blueberry 4-4exon's blastx xml result, and generate the tabbed reults .......

my $xmlfile= $ARGV[0] or die "BLAST XML PARSER \n I need An xml file from a blast output (-5 output) \n";
#my $fastafile=$ARGV[1] or die "BLAST XML PARSER \n I need A fasta file of the query \n";

#Outgoing e score distribution table
#my $filename1 = "escoreDistribution.table";
#open (FILE1, ">$filename1") or die $!; 
#outgoing Fasta Table
#my $outfasta = $id.".out.fasta";
#open (FASTA1, ">$outfasta") or die $!;
			
my $hitcount = 0;
my $misscount=0;
my $fastacount=0;
										
#Read in Fasta file to hash.
my %fastahash;
#dist hash for holding each escore for each fasta query.
my %disthash;

#my $file1 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');


#while (my $seq = $file1->next_seq) 
#{
#	        my $sid = $seq->display_id;
		#my @temp = split('\b',$sid);
		#my $id = $temp[0];	
		#print "Faster header is ", $sid, "\n";
#		my $sequence = $seq->seq;
#		$fastahash{$sid}=$sequence;
#		$fastacount++;
#}


#Parsing the xml file and filling the filling hithash with tasty data.
my $file2 = new Bio::SearchIO (-file=>$xmlfile, -format=>'blastxml');

my $outfile = $xmlfile.".tabbed";
open (OUTFILE, ">$outfile") or die $!;
print OUTFILE "Query Name \t Hit Name \t Escore \t Raw score \t Length of Hit(nt) \t Algorithm\n";

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
		my $exon = $hit->name;
		my $length = $hit->length;
		my $rawscore = $hit->raw_score;
		my $algorithm = $hit->algorithm;
		print " A hit ",$queryname," and exon was ",$exon,"\n";
		if ($score < 1e-1)
		{
			print OUTFILE $queryname,"\t",$exon,"\t",$score,"\t",$rawscore,"\t",$length,"\t",$algorithm,"\n";
			#print OUTFILE $fastahash{$id},"\n";
			print "Euereka !~! Just found ",$id,"\n";
		}
		else
		{
			print "score too high\n";

		}
  	}
} #DONE SEARCHING blast results

	print "# of sequences in original fasta file (Homo) =\t",$fastacount,"\n";
        print "All Done, we made it to the end.\n"; 

#close(FILE1);
#close(READNUM);
#close(FASTA1);
exit;





