use strict;
use warnings;
use Bio::SeqIO;

# Read in 2  fastq files that are paired and randomly choose a sub percentage of the sequences, while maintaining their pairing.
# 

my $fName1= $ARGV[0] or die "Pair Finder 1 \nI need A fastq file that is paired\n";
my $percent= $ARGV[1] or die " Need a percent also (1-99) of how many sequences we wish to retain\n";

my $filename1 = $fName1."-".$percent.".percent.fastq";
open (FILE1, ">$filename1") or die $!; 

#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fastq');

my %hash1;
my %hash2;
my %sqls;
my $count1 = 0;
my $count2 = 0;
my $idHolder = "null";
my $seqHolder;

while (my $seq = $file1->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	#my @head = split('\/',$sid);
	$hash1{$sid}=$sequence;

}
$count1 = keys %hash1; 
my @allkeys = keys %hash1;

my $num2retrieve = $percent/100*$count1;

my $calc = 0;
while($calc < $num2retrieve)
{
	my $randomkey = $allkeys[rand @allkeys];
	print FILE1 ">",$randomkey,"\n",$hash1{$randomkey},"\n";
	
	$calc++;
	@allkeys = keys %hash1;
}

print "Num of sequences:",$count1," Num2retrieve",$num2retrieve,"\n\n";

print "All Done, Count is ", $count1,"\n"; 

close(FILE1);
exit;


