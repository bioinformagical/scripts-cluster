use strict;
use warnings;
use Bio::SeqIO;


# This will read in a Chimera Slayer .unique.slayer.chimera file
# #   Parse out all the header names and whether or 2ND COLUMN DEFINES IT AS chimera.
# #   read in Fasta file and and assign it to either chimera or normal file.
#
# 

my $fName1= $ARGV[0] or die "Choose some sequences \n  Feed me a fasta file.";
my $readmapfile= $ARGV[1] or die "Feed me a Chimera Slayer chimera file.";

my $fileotu = $readmapfile.".otus.fna";
open (FILEOTU, ">$fileotu") or die $!; 

my $filechimera = $readmapfile.".chimeras.fna";
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
	if ( $line =~ /^Name/)
	{
		next;
	}
	elsif ($line =~ /^[G]/)
	{	
		my @entry = split("\t",$line);
		#print $entry[8],"\t",$hash{$entry[8]},"\n";
		if ($entry[1] =~ m/no/)
		{
			print FILEOTU ">",$entry[0],"\n",$hash{$entry[0]},"\n";
			#print ">",$entry[0],"\n",$hash{$entry[0]},"\n";
		}
		else 
		{
			print FILECHI ">",$entry[0],"\n",$hash{$entry[0]},"\n";
		}
	}
}


close(FILEOTU);
close(FILECHI);
close(READMAP);
exit;


