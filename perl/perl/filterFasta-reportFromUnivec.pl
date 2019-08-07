use strict;
use warnings;
#use Bio::SeqIO;

# 	Read in a fasta and read in report tabbed output of htat fasta VERSUS UNIVEC vectors.
# 	Remove the hits to UNIVEC. 
#	Write a new fasta file  blah-univecked.fna
# 

my $reportfile= $ARGV[0] or die "Choose some report output file  \n ";
my $fastafile= $ARGV[1] or die "Feed me fasta file.";

 open(INFILE, $fastafile."-univecked.fsa") || die("no such map file");
 open(REPORT, $reportfile) || die("no such linkage file");

my $fileout = $fastafile."-reportfixed.fsa";
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
print " LET'S GO FIND SOME report HITS and get their sequence.\n"; 

while (my $line = <REPORT>)
{
	chomp $line;
	#print "$line\n";
	my @report=split(' ',$line);
	print "$report[0] \n";
	my $query=$report[0];
	
	if (exists $hash{$query})
	{
		delete $hash{$query};
	}
	else {die " We failed to find a qiery match for $query/n";}

#	my $start=$report[8];
#	my $stop=$report[9];
#	if ($report[8] > $report[9]) { $start=$report[9]; $stop=$report[8];}     ### check to see which is higher, and reverse em !
#	my $offset=1+$stop-$start;
#	my $seq=$hash{$chromo};
#	my $subseq=substr($seq, $start, $offset);

	#print $subseq," is report sequence coord result for $chromo.\n";
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
close(REPORT);
close(INFILE);
exit;

