use strict;
use warnings;
use Bio::SeqIO;

my $refFile01= shift or die $!;
my $refSeq01 = new Bio::SeqIO (-file=>$refFile01, -format=>'fasta');

my %sqs;
my %sqls;

while (my $seq = $refSeq01->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $len = $seq->length;
	print $sid, "\t", $len, "\n";
}


exit;


