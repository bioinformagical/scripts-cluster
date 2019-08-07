use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file used for uchime and read in uchime readmap.uc.
# Identify each sequence as either chimera OR OTU and write 2 new fasta files
# accordingly
# 

my $fName1= $ARGV[0] or die "Choose some sequences \n  Feed me a fasta file.";
my $readmapfile= $ARGV[1] or die "Feed me a Uchime readmap file.";

my $fileotu = $fName1.".otus.fna";
open (FILEOTU, ">$fileotu") or die $!; 

my $filechimera = $fName1.".chimeras.fna";
open (FILECHI, ">$filechimera") or die $!;


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

my %hash;
my %sqls;
my $count = 0;
my $idHolder = "null";
my $seqHolder;

while (my $seq = $file1->next_seq) 
{
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
	my $sequence = $seq->seq;
	my @splitter = split("\;",$sid);
	$hash{$splitter[0]}=$sequence;


	#print "bad one  ! \t",$sequence," and we are at count:", $count, "\n";
	#	print FILE1 ">",$sid,"\n",$sequence,"\n";
	#print "All Done, Count is ", $count,"\n"; 
}

#read in UC file
open(READMAP, $readmapfile) || die("no such readmap file");
while (my $line = <READMAP>)
{
	chomp $line;
	if ( $line =~ /^#/)
	{
		next;
	}
	elsif ($line =~ /^[HN]/)
	{	
		my @entry = split("\t",$line);
		#print $entry[8],"\t",$hash{$entry[8]},"\n";
		if ($entry[9] =~ m/CHIMERA_\d+/)
		{
			print FILECHI ">",$entry[8],"\n",$hash{$entry[8]},"\n";
		}
		elsif ($entry[9] =~ m/OTU_\d+/)
		{
			 print FILEOTU ">",$entry[8],"\n",$hash{$entry[8]},"\n";

		}
	}
}


close(FILEOTU);
close(FILECHI);
close(READMAP);
exit;


