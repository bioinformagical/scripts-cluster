use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file that is paired and interleaved via sff_extract.
# Check each line to see if it has a pair, and write it to new pair file
# 

my $fName1= $ARGV[0] or die "Pair Finder 1 \nI need 2 fasta files that are paired and interleaved from sff_extract\n";
my $fName2= $ARGV[1] or die "Pair Finder 1 \n Where is my 2nd file ?\n";

my $filename1 = $fName1.".trimmed";
open (FILE1, ">$filename1") or die $!; 

my $filename2 = $fName2.".trimmed";
open (FILE2, ">$filename2") or die $!;



#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');
my $file2 = new Bio::SeqIO (-file=>$fName2, -format=>'fasta');


my %hash;
my %sqls;
my $count = 0;
my $idHolder = "null";
my $seqHolder;

while (my $seq = $file1->next_seq) 
{
my $seq2 = $file2->next_seq;

	my $sid1 = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence1 = $seq->seq;
	my @head = split('\/',$sid1);
	#print $sid1,"\t",$sequence1,"\n";
	#print $head[0],"\t",$head[1],"\n";
	my $id = $head[0];

	my $sid2 = $seq2->display_id;# print "ref ", $sid, "\n";
	my $sequence2 = $seq2->seq;
	my @head2 = split('\/',$sid2);
	my $id2 = $head2[0];

	if ( $id2 eq $id)
	{
		#if ($count%20000 == 0){ print "MATCH # ",$count, "\t", $sid1, "\t",$sid2 , "\n";}
		$count++;

		my $len1 = length($sequence1);
		my $len2 = length($sequence2);
		if ($len2 > 75 && $len1 > 75)
		{
			print FILE1 ">",$sid1,"\n",$sequence1,"\n";
			print FILE2 ">",$sid2,"\n",$sequence2,"\n";
			$count++;
		}
		else
		{
			print " We are short:",$len2,"\t",$len1,"\n";
		}	
		#my $temp2 = ">".$idHolder.".r\n".$seqHolder."\n".">".$sid1. "\n".$sequence."\n";
		#	print FILE1 $temp2;
		#	print $temp2;
	#	print FILE1 ">",$idHolder,".r\n",$seqHolder,"\n";
	#	print FILE1 ">",$sid, "\n",$sequence,"\n";
#	print ">",$idHolder,".r\n",$seqHolder,"\n";
	# print ">",$sid2, "\n",$sequence2,"\n";
	
	}
		
	#$idHolder = $head[0];
	#$seqHolder = $sequence;	
}

	print "All Done, Count is ", $count,"\n"; 

close(FILE1);
close(FILE2);
exit;


