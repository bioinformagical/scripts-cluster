#!/usr/bin/perl

use Bio::Search::Result::BlastResult;
use Bio::SearchIO;
use Bio::SeqIO;



my $xmlfile= $ARGV[0] or die "BLAST XML PARSER \n I need An xml file from a blast output (-5 output) \n";
my $readnumfile=$ARGV[1] or die "BLAST XML PARSER \n I need A file with the  number of reads per transcript from ace2fastaRob (tm) \n";;

my $filename1 = $xmlfile.".parsed.table";
open (FILE1, ">$filename1") or die $!; 


#A hash that holds the hits from blastx
my %hithash ;




#my $xmlfile= shift or die $!;
my $file1 = new Bio::SearchIO (-file=>$xmlfile, -format=>'blastxml');


while( my $result = $file1->next_result ) 
{
  ## $result is a Bio::Search::Result::ResultI compliant object
  print " We are in the loop \n";
  while( my $hit = $result->next_hit ) 
	{
		my $score = $hit->significance;
		my $queryname = $result->query_name;
		if ($score < 1)
		{
			my $hitname = $hit->name;
			my $desc = $hit->description;
			print  $queryname, "\t", $hitname,"\t", $desc, "\n";
			#print  FILE1 $queryname, "\t", $hitname,"\t", $desc "\n";
		}
		

		## $hit is a Bio::Search::Hit::HitI compliant object
    		#while( my $hsp = $hit->next_hsp ) 
		{
      			## $hsp is a Bio::Search::HSP::HSPI compliant object
          	#	print "Query=",   $result->query_name,
            	#		" Hit=",        $hit->name,
		}    		  
  	}
}


        print "All Done, we made it to the end.\n"; 

close(FILE1);
exit;





