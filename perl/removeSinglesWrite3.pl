use strict;
use warnings;
use Bio::SeqIO;

# Read in file 1 to map
# Check each line from file 2 to see if map has it
# write 3 files, the 2 pair files, and a singles file.

my $fName1= $ARGV[0] or die "Need Fasta pair 1 \nI need A fasta file\n";
my $fName2= $ARGV[1] or die "Need fasta pair 2\nI need 2 fasta input files that are pairs\n";
#my $singlesName= $ARGV[2] or die "I need output name for singles\n";

my $filename1 = $fName1.".final3";
my $filename2 = $fName2.".final3";
open (FILE1, ">$filename1") or die $!; 
open (FILE2, ">$filename2") or die $!; 


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

my %hash;
my %sqls;
my $count = 0;


while (my $seq = $file1->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	$sid = substr($sid,0,-1).2;
	if (($count%500000) == 0)
	{
		print "Round 1: ",$sid, "\t Map size = ", scalar(keys %hash) , "\n";
	}
	$hash{$sid}=$sequence;
	$count++;
}


$count = 0; 
my $file2 = new Bio::SeqIO (-file=>$fName2, -format=>'fasta');
print "Now working on ",$fName2,"\n";
while (my $seq = $file2->next_seq)
{
	 my $sid = $seq->display_id;# print "ref ", $sid, "\n";
         my $sequence = $seq->seq;
	 if (exists $hash{$sid})	
	 {
		$count++;
		#if (($count%500000) == 0)
       		{
                	if (($count%500000) == 0)
			{
				print "Round 2: ",$sid, "\t Map size = ", scalar(keys %hash) , "\n";
			}
			
			my $line = ">".substr($sid,0,-1).1;
			print FILE1 $line,"\n",$hash{$sid},"\n";
			print FILE2 ">",$sid,"\n",$sequence,"\n";

       		}
		
	 	delete $hash{$sid};
	 }
 	 else
	 {
		$hash{$sid}=$sequence;
	 }
	
}

#write remaining singles to singles file.
print "Starting Single reads Writing";
my $filename3 = $fName2."singles3";
open (FILE3, ">$filename3") or die $!;
foreach my $key (keys %hash) 
{
	print FILE3 ">",$key,"\n",$hash{$key},"\n"; 
}
close(FILE1);
close(FILE2);
close(FILE3);
exit;


