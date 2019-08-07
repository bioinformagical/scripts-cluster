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

open (FILE2, ">$output") or die $!; 


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

my %hash;
my %sqls;
my $count = 0;


while (my $seq = $file1->next_seq) 
{
	my $sid1 = $seq->display_id;# print "ref ", $sid, "\n";

	my @temp1 = split(/\./,$sid1);
        my $name1 = $temp1[0]   ;
	if ($temp1[1] ne "r")
	{
		
		print $name1,"\n";
		next;
	}
	my $seq2 = $file1->next_seq;
	my $sid2 = $seq2->display_id;
#		print "Round 1: ",$sid1, "\t and #2 = ", $sid2, "\n";
	
#	print  lc($name1), "\n";
	my @temp2 = split(/\./,$sid2);   
	my $name2 = $temp2[0]   ;

	if ($name1 eq  $name2)
	{
			print FILE2 $sid1,"\t",$sid2,"\n";
		#		print $sid1, "\t and #2 = ", $sid2, "\n";
	}
}


#write remaining singles to singles file.
print "Starting Single reads Writing";
close(FILE2);
exit;


