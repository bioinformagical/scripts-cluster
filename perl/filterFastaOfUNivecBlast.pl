use strict;
use warnings;
#use Bio::SeqIO;

# 	Read in a fasta and read in blast tabbed output of htat fasta VERSUS UNIVEC vectors.
# 	Remove the hits to UNIVEC. 
#	Write a new fasta file  blah-univecked.fna
# 

my $blastfile= $ARGV[0] or die "Choose some blast output file  \n ";
my $fastafile= $ARGV[1] or die "Feed me fasta file.";

 open(INFILE, $fastafile."-renamed.fsa") || die("no such map file");
 open(BLAST, $blastfile) || die("no such linkage file");

my $fileout = $fastafile."-univecked.fsa";
open (FILEOTU, ">$fileout") or die $!; 

my %hash;
my$header; my $seq;
my $species;
print "STARTING Loading reference DB into a HASH\n";
while (my $line=<INFILE>)
{
        if ($line=~/>/)
        {
   		if ($seq) 
		{
			my @splitty=split(' ',$header);
			
			$hash{$splitty[0]} = $seq; 
			$species = $splitty[1];
			#print "Header = $header\n";
		}            
		$header = $line;
		$header =~ s/^>//; # remove ">"
	        $header =~ s/\s+$//; # remove trailing whitespace
		$seq="";
	}
        else
        {
                chomp ($line);
		$seq .=$line;
        }
}
if ($seq) { # handle last sequence
$hash{$header} = $seq;}
#die "Size is :",scalar keys( %hash );
print " LET'S GO FIND SOME Blast HITS and get their sequence.\n"; 

while (my $line = <BLAST>)
{
	my @blast=split("\t",$line);
	my $query=$blast[0];
	my $iunivec=$blast[1];
	
	if (exists $hash{$query})
	{
		delete $hash{$query};
	}

#	my $start=$blast[8];
#	my $stop=$blast[9];
#	if ($blast[8] > $blast[9]) { $start=$blast[9]; $stop=$blast[8];}     ### check to see which is higher, and reverse em !
#	my $offset=1+$stop-$start;
#	my $seq=$hash{$chromo};
#	my $subseq=substr($seq, $start, $offset);

	#print $subseq," is blast sequence coord result for $chromo.\n";
#	print FILEOTU ">",$query,"-$chromo:$start-$stop\n";
#	print FILEOTU $subseq,"\n";
	#chomp $gene;
	
}

foreach  my $key (keys %hash)
{
	print FILEOTU ">$key $species]\n$hash{$key}\n";
}

print "C'est Fin\n";

close(FILEOTU);
close(BLAST);
close(INFILE);
exit;

