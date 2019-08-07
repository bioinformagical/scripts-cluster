use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file from Mira output and get all results that have been tagged as repeat in the header.
# 
# write repeats to file file.

my $fName1= $ARGV[0] or die "Need Fasta pair 1 \nI need A fasta file\n";

my $filename1 = $fName1.".justrepeats.fasta";
open (FILE1, ">$filename1") or die $!; 


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

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
#	$sid = substr($sid,0,-1).2;
	if ($sid =~ m/_rep_/)
	{
		$total++;
		if (length($sequence) < 5000)
		{
			$k5total++;
			next;
		}
		my $flag = 0;
		print "Round 1: ",$sid, "\t seq = ", $sequence , "\n";
		if ($sequence =~ m/gaattc/)
		{
			$ecocount++;
			$flag = 1;
		}	
		if ($sequence =~ m/cttaag/)
		{ 
 			$ecocount++;
			$flag =1;
                }
		if ($flag == 0)
		{$count++;}
	}
	
}
print "Final # of ecorI sites in the rep contigs is ",$ecocount,"\n"; 
print "Final # of rep contigs that lack a ecori site is ",$count,"\n";
print "Final # of rep contigs is ",$total,"\n";
close(FILE1);
exit;
