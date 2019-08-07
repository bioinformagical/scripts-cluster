use strict;
use warnings;
use Bio::SeqIO;

# Read in interproscan result file and making an .annot file that is suitable for Blast2Go feeding.
# 	We need 
# 	ID	GOTERMS		Description
#			Go terms need to be separated by a column.
my $fName1= $ARGV[0] or die "Need  \nI need A interpro file\n";

my $fileout1 = "$fName1.annot";
open (FILE1, ">>$fileout1") or die $!; 
print FILE1 $fName1,"\t";


#my $fname2= $ARGV[1] or die "Need Fasta pair 2 \nI need A 2nd fasta file\n";
#my $fileout2 = $fName1."-reversematch.fasta";
#open (FILE2, ">$fileout2") or die $!;







my $inter = $ARGV[0] or die "\nI need Annotaion interprofile\n";
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
	my $desc = $spli[5];
	my $go;
	for my $i (0 .. $#spli)
	{		
      		if ($spli[$i] =~ m/GO:/)
		{
			$go=$spli[$i];
			#print "Out GO term = $go\n";
			$go=~s/\|/,/g;
		}
	}
	$pfamhash{$pfamid}=$line;
	print FILE1 "$aa\t$go\t$desc\n";
	#my @aasplit= split("@",$aa);
	
	#$aa=lc($aasplit[0])."-".$aasplit[1];
	#print "$aa is from table.\n";	
	#if (exists $aahash{$aa})
	#{
		#print " we are in loop, for $aa\n";die; 
	#$hash{$aa}=$line;
	#	if (exists $pfamhash{$aa})
	#	{
	#		my $cnt=$pfamhash{$aa};
	#		$cnt++;
	#		$hash{$aa}=$cnt;
	#		if ($cnt > $topcount) { $topcount=$cnt; $topkey=$pfamid;}  
	#	}
	#3	else
	#	{
	#		$pfamhash{$aa}=1;
	#	}
	#}
}



	#print FILE1  $pfamhash{$topkey},"\t$topkey\n";



print "Fin\n";
close(FILE1);
close(INTER);
exit;
