#!/usr/bin/perl

use Bio::Search::Result::BlastResult;
use Bio::SearchIO;
use Bio::SeqIO;
use File::Basename;

# This reads in blast xml result and a paired file (from afg, with matching ids to fasta used for blast) and creates
# a parsed table.

my $xmlfile= $ARGV[0] or die "BLAST XML PARSER \n I need An xml file from a blast output (-5 output) \n";
my $readnumfile=$ARGV[1] or die "BLAST XML PARSER \n I need A file with the  number of reads per transcript from ace2fastaRob (tm) \n";
my $uniprotfile=$ARGV[2] or die " Pfffft, Where are those Uniprot photos I ordered Parker !!!";
open(READNUM, $readnumfile) || die("no such reads file");
open(READUNI, $uniprotfile) || die("No such Uniprot txt file");

my $outfile = $ARGV[4] || die("Feed me an output file too.... outfile file");
open (FILE1, ">$outfile") or die $!; 
#print FILE1 "Hit ID \t Hit Description	\t TranscriptID \t Number of Reads \t Hit Length \n";

print $outfile,"\n\n";
#die( "file name out checker");



# A hash to hold the number of reads for each Ts  {transcript, #ofreads}
my $readshash ;
while (my $line = <READNUM>)
{
	chomp $line;
	
	my @fields = split(' ', $line);
	if (defined $fields[0] and  defined $fields[1])
	{
		$readhash{$fields[0]} = $fields[1];
		# print  $fields[0], "\t", $fields[1], "\n";	
	}	
	else {  die("Our read number file, lacked the id / read number combo"); }
}
#my $size = scalar(keys %readhash);
#print "Size of hash1 is ", $size;
#die("Car wash");;

my %uniprothash; 
while (my $line = <READUNI>)
{       
      chomp $line;
     $uniprothash{$line}='0';
     print $line,"\t",$uniprothash{$line},"\n";
}
#die("Car wash 2, electric Boogaloo.");;


my $tsfile=$ARGV[3] or die " Pfffft, Ou est la ts file ?";
my $file1 = new Bio::SeqIO (-file=>$tsfile, -format=>'fasta');

my %tshash;
while (my $seq = $file1->next_seq) 
{
	my $sid1 = $seq->display_id;
	my $seq1 =  $seq->seq;
	$tshash{$sid1} = $seq1 ;
}

open(TSFILE, $tsfile) || die("no such ts file");

#                 die("Car wash 3, the deathly hallows of suds");





#A hash that holds the hits from blastx
my %hithash ;

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
		my $hitlength = $hit->length;
		if (length($hitlength) == 0)
		{
			die ("hit length was 0 for ", $queryname);
		}
		#if ($score < 1e-50)
		if ($score < 0.01)
		{
			my $hitname = $hit->name;
			#print "\nBefore splitting, hitname =",$hitname;
			my @hitnameArray = split('\|',$hitname);
			$hitname = $hitnameArray[1];
			#print "\nAfter splitting, hitname =",$hitname;
			my $desc = $hit->description;
			my $read = $readhash{$queryname};
			my $sequence = $tshash{$queryname};
			#print  $queryname, "\t", $hitname,"\t", $desc, "\t", $read,"\t The length of the hit is: ",$hitlength, "\n";
			#print  FILE1 $queryname, "\t", $hitname,"\t", $desc "\n";

			if (exists $hithash{$hitname})
			{
				my @fields = split('\t', $hithash{$hitname});
				my $oldCount = $fields[3];
				my $newcount = $oldCount + $read;
				
				my $bigline = $hitname."\t".$desc."\t".$queryname."\t".$newcount."\t".$hitlength;
				$hithash{$hitname} = $bigline;
				#print "Fields:",$fields[0],"\t",$fields[2],"\t",$fields[3],"\n";
				#print $bigline,"\n";
				#print "old count = ",$oldCount, " and new = ",$newcount,"\n";
				#my $size = scalar(keys %hithash);
				#print "\nSize of hash1 is ", $size,"\n";
				
			}	
			else 
			{
				my $bigline = $hitname."\t".$desc."\t".$queryname."\t".$read."\t".$hitlength;  
				$hithash{$hitname} = $bigline;
				#print $bigline,"\n";
				#my $size = scalar(keys %hithash);
				#print "\nNEWLINE added: Size of hash1 is ", $size,"\n";
			}

			if (exists($uniprothash{$hitname}))
			{
				print "Eureka ! We found a uniprot hit: ",$hitname,"\n";
				print FILE1 ">Uniprot=",$hitname,"_tsid=",$queryname,"_length=",$hitlength,"\n";
				print FILE1 $sequence,"\n";

				my $count = $uniprothash{$hitname};
				$count++;
				$uniprothash{$hitname}=$count;

			}

		}
		else
		{
			my $hitname = $hit->name;
			print "\nBefore splitting, hitname =",$hitname;
					       
			my @hitnameArray = split('\|',$hitname);
			$hitname = $hitnameArray[1];
												
			print "OMG, WE FOUND A POOR SCORER and his name is:",$hitname;
			if (exists($uniprothash{$hitname}))
		        {
				# print "Eureka ! We found a uniprot hit: ",$hitname,"\n";
				#print FILE1 ">Uniprot=",$hitname,"_tsid=",$queryname,"_length=",$hitlength,"\n";
				#print FILE1 $sequence,"\n";
				my $count = $uniprothash{$hitname};
				$count++;
				$uniprothash{$hitname}=$count;
			}

			#	print "score too high\n";
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

#print out hithash
foreach my $key (keys(%uniprothash)) 
{
	print "Final Uniprot hash size:\t", $key,"\t",$uniprothash{$key},"\n";
	#print FILE1 $pline,"\n";     
}
	    


        print "All Done, we made it to the end.\n"; 

close(FILE1);
close(READNUM);
exit;





