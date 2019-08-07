use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file that is paired and interleaved via sff_extract.
# Check each line to see if it has a pair, and write it to new pair file
# 

my $fName1= $ARGV[0] or die "Pair Finder 1 \nI need A fasta file that is paired and interleaved from sff_extract\n";

my $filename1 = $fName1.".paired";
open (FILE1, ">$filename1") or die $!; 


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

my %hash;
my %sqls;
my $count = 0;
my $idHolder = "null";
my $seqHolder;

while (my $seq = $file1->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	my @head = split('\.',$sid);
#	print $sid,"\t",$sequence,"\n";
#	print $sid,"\t",$head[0],"\t",$head[1],"\n";
	my $end = $head[1];

	if ($head[0] eq $idHolder)
	{
		if ($count%20000 == 0){ print "MATCH # ",$count, "\t", $sid, "\t",$idHolder , "\n";}
		$count++;
		my $temp2 = ">".$idHolder.".r\n".$seqHolder."\n".">".$sid. "\n".$sequence."\n";
		print FILE1 $temp2;
		print $temp2;
	#	print FILE1 ">",$idHolder,".r\n",$seqHolder,"\n";
	#	print FILE1 ">",$sid, "\n",$sequence,"\n";
#	print ">",$idHolder,".r\n",$seqHolder,"\n";
#        print ">",$sid, "\n",$sequence,"\n";
	
	}
		
	$idHolder = $head[0];
	$seqHolder = $sequence;	
}

	print "All Done, Count is ", $count,"\n"; 

close(FILE1);
exit;


