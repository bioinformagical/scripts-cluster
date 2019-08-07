use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file and make a clean header.
# 
# write to new fasta file.

my $fName1= $ARGV[0] or die "Need Fasta pair 1 \nI need A fasta file\n";
my $inputfile="$fName1.fsa";

#my $filename1 = $fName1."-header.fasta";
my $filename1 = $fName1."-renamed.fsa";
open (FILE1, ">$filename1") or die $!; 


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$inputfile, -format=>'fasta');

my %hash;
my %sqls;
my $count = 0;
my $ecocount = 0;
my $total =0;
my $k5total = 0;
while (my $seq = $file1->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	
	#my @splitty=split("^A",$sid);
	my $newhead = "$sid  [organism=foo]";	
	#print $splitty[0],"\t",$splitty[1],$splitty[2],"\n";
	print FILE1  ">",$newhead,"\n",$sequence,"\n";
}
print "Fin\n";
close(FILE1);
exit;
