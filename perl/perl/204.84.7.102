use strict;
use warnings;
use Bio::SeqIO;

# Read in f fasta file
# Check each line to see if it has a mate pair (in this cars .r followed by a .f read
# write out the 2 read lines into mated txtpairfile.

my $fName1= $ARGV[0] or die "Need paired Fasta file, with .r and .f endings \nI need A fasta file\n";
# $fName2= $ARGV[1] or die "Need fasta pair 2\nI need 2 fasta input files that are pairs\n";
#my $singlesName= $ARGV[2] or die "I need output name for singles\n";

my $output = $fName1.".PAIRMATE.txt";

open (FILE1, ">$fName1") or die $!; 
open (FILE2, ">$output") or die $!; 


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

my %hash;
my %sqls;
my $count = 0;


while (my $seq = $file1->next_seq) 
{
	my $sid1 = $seq->display_id;# print "ref ", $sid, "\n";
	my $sid2 = $file1->next_seq->display_id;
	if (($count%500000) == 0)
	{
		print "Round 1: ",$sid, "\t and #2 = ", $sid2 "\n";
	}
	
	$count++;
}


#write remaining singles to singles file.
print "Starting Single reads Writing";
close(FILE1);
close(FILE2);
exit;


