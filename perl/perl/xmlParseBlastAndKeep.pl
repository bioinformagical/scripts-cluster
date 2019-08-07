#!/usr/bin/perl

use Bio::Search::Result::BlastResult;
use Bio::SearchIO;
use Bio::SeqIO;
use strict;
use warnings;

# This reads in blast xml result and a paired file (from **Trinity read_asm read files, with matching ids to fasta used for blast) and creates
# a parsed table.
#
#	BUT THEN.... It flags the contig that was hit so that we can identify which contigs fail to get any hits at all.
#	(these contigs then move on to other blast searches.)
#
#		THIS HAS BEEN MODDED TO USE trinity read files for the read counts.
#

my $xmlfile= $ARGV[0] or die "BLAST XML PARSER \n I need An xml file from a blast output (-5 output) \n";
my $readnumfile=$ARGV[1] or die "BLAST XML PARSER \n I need A file with the  number of reads per transcript from \$file.genes.results (tm) \n";;
open(READNUM, $readnumfile) || die("no such reads file");

my $tsfile=$ARGV[2] or die "BLAST XML PARSER \n I need A file with the transcripts from trinity (tm) \n";;
#open(TS, $tsfile) || die("no such transcript file");
my $file1 = new Bio::SeqIO (-file=>$tsfile, -format=>'fasta');


my $filename1 = $xmlfile.".parsed-e10.table";
open (FILE1, ">$filename1") or die $!; 


# A hash to hold the number of reads for each Ts  {transcript, #ofreads}
my %readhash ;
my %remaininghash ;

my $thowawayHeader = <READNUM>;
while (my $line = <READNUM>)
{
	chomp $line;
	
	my @fields = split("\t", $line);
	if (defined $fields[1] and  defined $fields[4])
	{
		if ($fields[1] =~ /\,/)
		{
			my @seqid = split("\,", $fields[1]);
			foreach my $loop (@seqid)
			{
				chomp $loop;
				$readhash{$loop} = $fields[4];
				#print " We found ",$loop, " and ",$fields[4],"\n";
			}
			#print " We found ",$seqid[0], " and ",$seqid[1],"\n";
		}
		else
		{
			chomp $fields[1];
			$readhash{$fields[1]} = $fields[4];
		}
		#$remaininghash{$fields[0]} = $fields[1];
		 #print  $fields[1], "\t", $fields[4], "\n";	
	}	
	else {  die("Our read number file, lacked the id / read number combo"); }
}

my $size = scalar(keys %readhash);
print "Size of read hash is ", $size;
$size = scalar(keys %remaininghash);
 print "\n Size of our remianingHash is ", $size,"\n";
#die("Car wash");

 # A hash for the transcripts.
while (my $seq = $file1->next_seq)
{
	        my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	        my $sequence = $seq->seq;

        	$remaininghash{$sid} = $sequence;
}
#                                                                
$size = scalar(keys %remaininghash);
print "\n Size of our remianingHash is now ", $size,"\n";


#A hash that holds the hits from blastx
my %hithash ;

#Parsing the xml file and filling the filling hithash with tasty data.
my $file2 = new Bio::SearchIO (-file=>$xmlfile, -format=>'blastxml');


while( my $result = $file2->next_result ) 
{
  ## $result is a Bio::Search::Result::ResultI compliant object
  # print " We are in the loop \n";
  while( my $hit = $result->next_hit ) 
	{
		my $score = $hit->significance;
		my $queryname = $result->query_description;
		chomp $queryname;
		if ($score < 1e-10)
		{
			my $hitname = $hit->name;
			my $desc = $hit->description;
			my @getread = split(' ',$queryname);
			my $read = $readhash{$getread[0]};
			if (! defined $read)
			{
				die "We did not find read in the read hash for $queryname";
			}
			#print  $queryname, "\t", $hitname,"\t", $desc, "\t", $read, "\n";
			#print  FILE1 $queryname, "\t", $hitname,"\t", $desc "\n";

			if (exists $hithash{$hitname})
			{
				my @fields = split('\t', $hithash{$hitname});
				my $oldCount = $fields[3];
				my $newcount = $oldCount + $read;
				
				my $bigline = $hitname."\t".$desc."\t".$queryname."\t".$newcount;
				$hithash{$hitname} = $bigline;
				#print "Fields:",$fields[0],"\t",$fields[2],"\t",$fields[3],"\n";
				#print $bigline,"\n";
				#print "old count = ",$oldCount, " and new = ",$newcount,"\n";
				#my $size = scalar(keys %hithash);
				#print "\nSize of hash1 is ", $size,"\n";
				
			}	
			else 
			{
				my $bigline = $hitname."\t".$desc."\t".$getread[0]."\t".$read;  
				#if (! exists 
				$hithash{$hitname} = $bigline;
				
				#this deletes the successful finding of a hit from the remaining contig pool......
				#if (exists $remaininghash{$queryname}) { die "Ok it is here";}
				delete($remaininghash{$getread[0]});
				#print $bigline,"\n";
				$size = scalar(keys %remaininghash);
				#print "\n Size of our remianingHash is ", $size,"\n";
			}
		}
		else
		{
			print "score too bad\n";
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
foreach my $key (keys(%hithash)) 
{
	my $pline = $hithash{$key};
	#print $pline,"\n";
	print FILE1 $pline,"\n";     
}
	   
#print out remaining contig names to a file for subsequent analysis
my $filename2 = $xmlfile.".e10noMatch.fasta";
open (FILE2, ">$filename2") or die $!;



foreach my $key (keys(%remaininghash))
{
	#print $key,"\n";
	print FILE2 ">",$key,"\n",$remaininghash{$key},"\n";
}



        print "All Done, we made it to the end.\n"; 

close(FILE1);
close(FILE2);
close(READNUM);
exit;





