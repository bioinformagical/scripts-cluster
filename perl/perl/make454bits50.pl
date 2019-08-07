use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file and make a clean header.
#  And then break the sequences up into chucnks of 50 and create smaller sequences (still paired) for using with SSPACE !!
#    We are making 454-on-bits.  Or 454bits. (So 454 data can go into sspace too)
# write to new fasta files.

my $fName1= $ARGV[0] or die "Need Fasta pair 1 \nI need A fasta file\n";

my $fileout1 = $fName1."-forward-454bit.fasta";
open (FILE1, ">$fileout1") or die $!; 


#my $fname2= $ARGV[1] or die "Need Fasta pair 2 \nI need A 2nd fasta file\n";
my $fileout2 = $fName1."-reverse-454bit.fasta";
open (FILE2, ">$fileout2") or die $!;

my $singles = $fName1."-singles.fasta";
open (SINGLES, ">$singles") or die $!;

my $f1= "$fName1"."_1.fasta";
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
	#my $splitty=(split "_T7_",$sid )[0];	
	#chop $sid;
       print $sid,"\n";
	#die;
	#chomp $splitty;	
	$hash{$sid}=$sequence;
}
#die;


my $f2="$fName1"."_2.fasta";
my $file2 = new Bio::SeqIO (-file=>$f2, -format=>'fasta');
while (my $seq = $file2->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	#my $splitty=(split "_RP-1_",$sid )[0];
	#chop $sid;
	if (exists $hash{$sid}) 
	{
  		#print 'match';
		#$splitty =~ s/_RP-1_/_T7_/;
		#$splitty =~ s/_R.trimmed.seq/_F.trimmed.seq/;
		my $size = length($sequence);
		if (length($hash{$sid}) < $size) {$size = length($hash{$sid});}
		#$size=int($size/50);
		my $nowsize = 0;
		while ($nowsize < $size)
		{
			#print FILE1 ">$sid-f-$nowsize\n";
			#print FILE2 ">$sid-r-$nowsize\n";
			my $max= $nowsize+50;
			my $miniseq1; my $miniseq2;
			for ($nowsize; $nowsize < ($max); $nowsize++)
			{
			#	print "Now size is $nowsize of max total size : $size\n";
				$miniseq1=$miniseq1.substr($hash{$sid}, $nowsize, 1);
				$miniseq2=$miniseq2.substr($sequence, $nowsize, 1);

				#print FILE1 substr($hash{$sid}, $nowsize, 1);
				#print FILE2 substr($sequence, $nowsize, 1);	
			}
			if ((length($miniseq1) > 20) && (length($miniseq2) > 20))
			{
				print FILE1 ">$sid-f-$nowsize\n";
				print FILE2 ">$sid-r-$nowsize\n";
				print FILE1 "$miniseq1\n";
				print FILE2 "$miniseq2\n";
			}
		}	

		#print FILE1 ">$splitty-f\n$hash{$splitty}\n";
		#print FILE2 ">$splitty-r\n$sequence\n";
		delete $hash{$sid}; 
	}
	else
	{
		#die("We have no forward ID");
		print SINGLES ">$sid\n$sequence\n";
	}
	#my @splitty=split("^A",$sid);
	
	#print $splitty[0],"\t",$splitty[1],$splitty[2],"\n";
	#print FILE1  ">",$sid,"\n",$sequence,"\n";
}

foreach my $key (keys %hash)
{ 
	print SINGLES ">$key\n$hash{$key}\n";

}


print "Fin\n";
close(FILE1);
close(FILE2);
close(SINGLES);
exit;
