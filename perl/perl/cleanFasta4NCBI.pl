use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file and make a clean header.
# 
# write to new fasta file.

my $fName1= $ARGV[0] or die "Need Fasta pair 1 \nI need A fasta file\n";
my $inputfile="BJ$fName1.fsa";
my $samples= $ARGV[1] or die "I need A sample text file with species names\n";
open (INFILE, "$samples")or die "Cannot open infile, ";

#my $filename1 = $fName1."-header.fasta";
my $filename1 = "BJ$fName1-renamed.fsa";
open (FILE1, ">$filename1") or die $!; 

######  Read in Species tabel and HASH it   ######
my $taxa;
<INFILE>; # throwa away header
while (my $line=<INFILE>)
{
	chomp $line;
	my @splitty = split("\t",$line);
	my $genus= $splitty[0];
	my $species= $splitty[1];
	my $bj= $splitty[-1];
	print "$genus $species \t $bj\n";
	if ($bj == $fName1) { $taxa = "$genus $species"; }
}


if (length $taxa == 0){ die "We found no taxa from table";}

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
	my $newhead = "$sid  [organism=$taxa]";	
	#print $splitty[0],"\t",$splitty[1],$splitty[2],"\n";
	print FILE1  ">",$newhead,"\n",$sequence,"\n";
}
print "Fin\n";
close(FILE1);
exit;
