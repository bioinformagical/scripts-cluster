use strict;
use warnings;
use Bio::SeqIO;

# Read in file used for metaphlan .
# Identify each sequence as either chimera OR OTU and write 2 new fasta files
# accordingly
# 

my $file= $ARGV[0] or die "Choose some metaphlan file s \n ";
my $outfile= $ARGV[1] or die "feed me out file as argument 2.";

open(PHLANFILE, $file) || die("no such map file");

open (OUTFILE, ">$outfile") or die $!; 

my $cutoff = 1;
my $goodrow = 0;
while (my $line = <PHLANFILE>)
{
	my @col = split("\t",$line);
	if ($col[1] > $cutoff)
	{
		print OUTFILE $line,"\n";
		$goodrow++;
	}
	
}

print " Number of good rows markers is ",$goodrow,"\n";
close(OUTFILE);
close(PHLANFILE);
exit;


