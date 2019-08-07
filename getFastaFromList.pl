use strict;
use warnings;
use Bio::SeqIO;

# Read in f fasta file and text files containing SeqID names in a list.
# # Create hash from read list, Then iterate through fasta file for matches.
# # write out a fasta file containing fasta seqeunces from list
#
 my $fName1= $ARGV[0] or die "Need paired Fasta file,  \nand I need A text file containing the reads\n";
 my $reads = $ARGV[1] or die " I need A text file containing the reads\n";
 # $fName2= $ARGV[1] or die "Need fasta pair 2\nI need 2 fasta input files that are pairs\n";
 #my $singlesName= $ARGV[2] or die "I need output name for singles\n";

 my $output = $fName1.".extracted.fasta";

 
 open (FILE2, "$reads") or die $!;


 #my $fName1= shift or die $!;
 my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

 my %hash;
 my %sqls;
 my $count = 0;

my $outfile = $reads.".fasta";
open (FILE3, ">".$outfile) or die $!; 
while (<FILE2>)  
{           
	my $id = $_;           
	chomp $id;           
	
	$hash{$id}="true";
	#print $id," was one of the scaffolds \n";           
}



 while (my $seq = $file1->next_seq)
 {
        my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	chomp $sid;
	#print "SID =", $sid,"\t";
	#$hash{$sid}=$sequence;
	#my $sid2 = $file1->next_seq->display_id;
        if (($count%50000) == 0)
        {
        	print "Round 1: ",$sid, "\n";
        }
	
	if (exists $hash{$sid})
	{
		die " We found ", $sid;
	}
        $count++;
}


#my $outfile = $reads.".fasta";
#open (FILE3, ">".$outfile) or die $!;
# while (<FILE2>)
#  {
#           my $id = $_;
#           chomp $id;
	   #print $id," was one of the scaffolds \n";
#	   if (exists $hash{$id})
#	   {
#		print "Found a match !~!",$id," \n";
#		print FILE3 ">", $id,"\n",$hash{$id},"\n";
#	   }	
# }
			     


#write remaining singles to singles file.
print "End of our fin  Writing \n";
close(FILE2);
close(FILE3);
exit;

                                                                                 
