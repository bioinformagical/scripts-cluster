#!/usr/bin/perl
use warnings;
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

#my $outfile = $xmlfile.".tabbed";
#open (OUTFILE, ">$outfile") or die $!;
#print OUTFILE "Query Name \t Hit Name \t Escore \t Raw score \t Length of Hit(nt) \t Algorithm\n";

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

		#print " A hit ",$queryname," and match was ",$match,"\n";
		
		#while( my $hsp = $hit->next_hsp ) 
		#{
		#	print OUTFILE2 $queryname,"\t",$match,"\t",$score,"\n";
		#        use Bio::AlignIO;
		#		my $aln = $hsp->get_aln;

			 #changed msf to fasta and hsp.msf to hsp.fas, output is now a fasta file 
			 #my $alnIO = Bio::AlignIO->new(-format =>"fasta", -file =>">>hsp.fas"); 
			 #	$alnIO->write_aln($aln);
			 #}
		if ($score < 100)
		{
			my $entry = $queryname."\t".$match."\t".$desc."\t".$score."\t".$length;
			push(@lines,$entry);
			#print $entry,"\n";

			if (exists $deschash{$match})
			{
				my $tmp = $deschash{$match};
				$tmp++;
				$deschash{$match} = $tmp;
			}
			else
			{
				$deschash{$match} = 1;
			}

			#print OUTFILE $queryname,"\t",$match,"\t",$desc,"\t",$score,"\t",$length,"\n";
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

####
#
#	Find most commonly occuring match 
#
###
#my $biggesthit = 0;
#my $bigmatch;

#for my $key(keys %deschash)
#{
#	if ($deschash{$key} > $biggesthit)
#	{
#		$biggesthit = $deschash{$key};
#		$bigmatch = $key;
#	}
#}


####
##
##       Find each taxa that is bext fit for bigmatch.  
#	Check by escore and then by length.
#
##
####
print " START THE TRIALS !!!\n";

for my $key(keys %deschash)
{
	my @gimess = split(/\|/,$key);
	print $gimess[3]," was gimess\n";
	my $outfile = $xmlfile.".tabbed";
  	open (OUTFILE, ">$outfile") or die $!;
	
	foreach (@lines)
	{
	 	my @splitty = split("\t",$_);
		if ($splitty[1] eq $key)
		{
			my $tmp = $_;
			print OUTFILE $tmp,"\n";
		}
	}
	print "Ending the trial of ",$key,"\n";
	close OUTFILE;
}


	print "# of sequences in original fasta file (Homo) =\t",$fastacount,"\n";
        print "All Done, we made it to the end.\n"; 

close(OUTFILE);
#close(OUTFILE2);
#close(FILE1);
#close(READNUM);
#close(FASTA1);
exit;





