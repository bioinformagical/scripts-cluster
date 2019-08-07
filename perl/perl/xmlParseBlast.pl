#!/usr/bin/perl

use Bio::Search::Result::BlastResult;
use Bio::SearchIO;
use Bio::SeqIO;



my $fName1= $ARGV[0] or die "Pair Finder 1 \nI need A fasta file that is paired and interleaved from sff_extract\n";

my $filename1 = $fName1.".output";
open (FILE1, ">$filename1") or die $!; 


#my $fName1= shift or die $!;
my $file1 = new Bio::SearchIO (-file=>$fName1, -format=>'blastxml');


while( my $result = $file1->next_result ) 
{
  ## $result is a Bio::Search::Result::ResultI compliant object
  while( my $hit = $result->next_hit ) 
	{
		my $score = $hit->significance;
		if ($score < 1)
		{
			print "Query=",   $result->query_name,
                                "\t Hit=", $hit->name,"\t",$hit->description,"\n";
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





