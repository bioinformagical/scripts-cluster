#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

#
######		This will read in a brassica pep fasta and a table of "Bog IDs" as a file.
#		Will just print out the ones in the file as a new fasta.

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the 2 fasta files. \n";
my $logfile=$ARGV[1] or die "Need a second file to search against.\n"; 

#thehash
my %primehash;

# Open in and out files
open (INFILE, "$logfile") or die "Cannot open text file, ";
open (OUT, ">$logfile".".faa") or die "Cannot open outfile:= $! ";

##   Read in sequences to hash
my %seqhash;
my $file2 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');
open ( INFILE2, "$fastafile") or die " Can't open the fasta file \n";
my$header; my $seq; my %hash;
while (my $line=<INFILE2>)
{
        if ($line=~/>/)
        {
                if ($seq) {$seqhash{$header} = $seq; print "Header = $header\n";}            
                $header = $line;
                $header =~ s/^>//; # remove ">"
                $header =~ s/\s+$//; # remove trailing whitespace
		my @splitty = split('\b',$header);
		print "$splitty[0] \n";
                $header=$splitty[0];
		$seq="";
		chomp $header;
        }
        else
        {
                chomp ($line);
                $seq .=$line;
        }
}
if ($seq) { # handle last sequence
$seqhash{$header} = $seq;}


#######  Now open the marker file that contains the marker that we want regions from   #########
while ( my $line=<INFILE>)
{
	chomp $line;
	my $marker = $line;
	#$seqhash{$marker} = 1;
	print "The  hunt for is :$marker:  and  seq is $seqhash{$marker} \n";
	print OUT ">$marker\n";
	print OUT "$seqhash{$marker}\n";
}




#-----------------------------------------------------------------

print " The End, c'est finis. \n ";

close INFILE;
close OUT;
exit;
