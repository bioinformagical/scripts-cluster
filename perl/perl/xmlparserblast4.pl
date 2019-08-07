#!/usr/bin/perl

use Bio::Search::Result::BlastResult;
use Bio::SearchIO;
use Bio::SeqIO;

# This reads in blast xml result and a paired file (from afg, with matching ids to fasta used for blast) and creates
# a parsed table.

my $xmlfile= $ARGV[0] or die "BLAST XML PARSER \n I need An xml file from a blast output (-5 output) \n";

my $filename1 = $xmlfile.".parsed.table";
open (FILE1, ">$filename1") or die $!; 

#Parsing the xml file and filling the filling hithash with tasty data.
my $file1 = new Bio::SearchIO (-file=>$xmlfile, -format=>'blastxml');


while( my $result = $file1->next_result ) 
{
  ## $result is a Bio::Search::Result::ResultI compliant object
  #print " We are in the loop \n";
  while( my $hit = $result->next_hit ) 
	{
		my $score = $hit->significance;
		my $queryname = $result->query_description;
		if ($score < 1e-80)
		{
			my $hitname = $hit->name;
			my $desc = $hit->description;
			my $read = $readhash{$queryname};
			print  FILE1 $queryname, "\t", $hitname,"\t", $desc, "\t", $read, "\n";
			#print  FILE1 $queryname, "\t", $hitname,"\t", $desc "\n";

		}
		else
		{
			print "score too high\n";
		}

		## $hit is a Bio::Search::Hit::HitI compliant object
    		#while( my $hsp = $hit->next_hsp ) 
		{
      			## $hsp is a Bio::Search::HSP::HSPI compliant object
          	#	print "Query=",   $result->query_name,
            	#		" Hit=",        $hit->name,
		}    		  
  	}
} #DONE SEARCHING blast results

        print "All Done, we made it to the end.\n"; 

close(FILE1);
exit;





