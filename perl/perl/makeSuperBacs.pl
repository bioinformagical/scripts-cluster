use strict;
use warnings;
use Bio::SeqIO;

# Read in 2 fasta files, forwarD AND REVERSe,  and make a make a long bac sequence, filled with N's (109,000).
# Need to reverse complement the reverse.
# write to new fasta file.

my $fName1= $ARGV[0] or die "Need Fasta pair 1 \nI need A fasta file\n";

my $fileout1 = $fName1."-100kBAC.fasta";
open (FILE1, ">$fileout1") or die $!; 


#my $fname2= $ARGV[1] or die "Need Fasta pair 2 \nI need A 2nd fasta file\n";
#my $fileout2 = $fName1."-reversematch.fasta";
#open (FILE2, ">$fileout2") or die $!;

#my $singles = $fName1."-singles.fasta";
#open (SINGLES, ">$singles") or die $!;

my $f1= "$fName1-forwardmatch.fasta";
my $file1 = new Bio::SeqIO (-file=>$f1, -format=>'fasta');

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

#print "$sid\n";
	my $splitty=(split "-f",$sid )[0];	
       print $splitty,"\n";
	chomp $splitty;	
	$hash{$splitty}=$sequence;
}
#die;


my $f2="$fName1-reversematch.fasta";
my $file2 = new Bio::SeqIO (-file=>$f2, -format=>'fasta');
while (my $seq = $file2->next_seq) 
{
	print " We are starting 2nd file.\n";
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	my $revcomp = &revdnacomp($sequence);
	 my $splitty=(split "-r",$sid )[0];
	my $test;
	if (exists $hash{$splitty}) 
	{
  		#print 'match';
		#$splitty =~ s/_RP-1_/_T7_/;
		#$splitty =~ s/_R.trimmed.seq/_F.trimmed.seq/;
		print FILE1 ">$splitty\n$hash{$splitty}";
		for (my $i = 0; $i < 109000; $i++) 
		{
			print FILE1 "N";
		}
		print FILE1 "$revcomp\n";
#		print FILE2 ">$splitty-r\n$sequence\n";
#		delete $hash{$splitty}; 
	}
	else
	{
		die("We have no forward ID");
		#print SINGLES ">$splitty\n$sequence\n";
	}
	#my @splitty=split("^A",$sid);
	
	#print $splitty[0],"\t",$splitty[1],$splitty[2],"\n";
	#print FILE1  ">",$sid,"\n",$sequence,"\n";
}

#foreach my $key (keys %hash)
#{ 
#	print SINGLES ">$key\n$hash{$key}\n";
#


print "Fin\n";
close(FILE1);
close(FILE2);
#close(SINGLES);
exit;

sub revdnacomp 
{
  # my $dna = @_;  
  # the above means $dna gets the number of 
  # arguments in @_, since it's a scalar context!
  
  my $dna = shift; # or   my $dna = shift @_;
  print "We are in reverseComp sub function with $dna \n";
  # ah, scalar context of scalar gives expected results.
  # my ($dna) = @_; # would work, too

  my $revcomp = reverse($dna);
  $revcomp =~ tr/ACGTacgt/TGCAtgca/;
  return $revcomp;
}

