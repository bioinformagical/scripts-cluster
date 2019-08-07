use strict;
use warnings;
use Bio::SeqIO;

# Read in ortho fasta file and an interpro result .
# 	Figure out which interpro shows up most often
# write a clean annotation result to a new file.

my $fName1= $ARGV[0] or die "Need Fasta pair 1 \nI need A fasta file\n";

my $fileout1 = "/lustre/groups/janieslab/astersLikeFoltz/annot/all703-annot.txt";
open (FILE1, ">>$fileout1") or die $!; 
print FILE1 $fName1,"\t";


#my $fname2= $ARGV[1] or die "Need Fasta pair 2 \nI need A 2nd fasta file\n";
#my $fileout2 = $fName1."-reversematch.fasta";
#open (FILE2, ">$fileout2") or die $!;

my $f1= $fName1;
my $file1 = new Bio::SeqIO (-file=>$f1, -format=>'fasta');

my %aahash;
while (my $seq = $file1->next_seq)
{
        my $sid = $seq->display_id;# print "ref ", $sid, "\n";
        my $sequence = $seq->seq;
	
#print "$sid\n";
        my @splitty=(split /\|/,$sid );
       #print $splitty[0],"\n";
        #chomp $splitty;        
        my $aa=$splitty[0]."-".$splitty[1];
	$aahash{$aa}=1;
}       
#die;








my $inter = $ARGV[1] or die "\nI need Annotaion interprofile\n";
open (INTER,$inter) or die $!;
my %hash; 
my %pfamhash;
my $topkey;
my $topcount=0;

while (my $line = <INTER>)
{
	chomp $line;
	my @spli=split("\t",$line);	
	my $aa = $spli[0];
	my $pfamid = $spli[4];
	$pfamhash{$pfamid}=$line;
	#print "$aa \t $pfamid\n";
	my @aasplit= split("@",$aa);
	
	$aa=lc($aasplit[0])."-".$aasplit[1];
	#print "$aa is from table.\n";	
	if (exists $aahash{$aa})
	{
		#print " we are in loop, for $aa\n";die; 
	#$hash{$aa}=$line;
		if (exists $pfamhash{$aa})
		{
			my $cnt=$pfamhash{$aa};
			$cnt++;
			$hash{$aa}=$cnt;
			if ($cnt > $topcount) { $topcount=$cnt; $topkey=$pfamid;}  
		}
		else
		{
			$pfamhash{$aa}=1;
		}
	}
}



	print FILE1  $pfamhash{$topkey},"\t$topkey\n";



print "Fin\n";
close(FILE1);
close(INTER);
exit;
