use strict;
use warnings;
use Bio::SeqIO;

## This will filter sequences shorter than 20 NT long.....

my $refFile01= shift or die $!;
my $refSeq01 = new Bio::SeqIO (-file=>$refFile01, -format=>'fasta');
open (OUTFILE, ">"."$refFile01"."-chomped.fasta") or die "Cannot open outfile!";

my %sqs;
my %sqls;

while (my $seq = $refSeq01->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	print $sid,"\n";
	my $len = $seq->length;
	if ($len > 19)
	{
		print OUTFILE ">", $sid, "\n",$seq->seq,"\n";
	}
}

close OUTFILE;
exit;


