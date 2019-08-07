#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

#
######		This will read in a brassica fasta and a table of markers whose names contain the chr # and position.
#		Get + - 1 million sequences on either side of the marker position. produce a new fasta file containing each of the lines from the text file.
#

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the 2 fasta files. \n";
my $logfile=$ARGV[1] or die "Need a second file to search against.\n"; 
my $gfffile=$ARGV[2] or die " we also need a 3rd gff file\n";
my $markerfile=$ARGV[3] or die " we also need a marker file with just the names of the original marker \n";
#########  Read in Primers  and throw them into a hash

#thehash
my %primehash;

# Open in and out files
open (INFILE, "$gfffile") or die "Cannot open infile, ";
open (OUT, ">"."$markerfile"."-mahkas.fna") or die "Cannot open outfile!";
open (GFFOUT, ">"."$markerfile"."-subsection.gff") or die "Cannot open outfile!";
#Load gff into an array
my @gffray;
chomp(@gffray = <INFILE>);

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
		$header =~ s/Scaffold/S/;
                $seq="";
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
open (MARKERFILE, "$markerfile") or die "Cannot open marker file to write!";
my %markerhash;
while ( my $line=<MARKERFILE>)
{
	chomp $line;
	my $marker = $line;
	$markerhash{$marker} = 1;
	print "The marker to hunt for is :$marker:\n";
}




# peruse the in marker log file and load the hash so we can get to those coords !
open (LOGFILE, "$logfile") or die "Cannot open scaffold fasta file!";

my %scafhash;
<LOGFILE>;
while ( my $line=<LOGFILE>)
{               
                my $header = $line;
                chomp $header;
		my @splitty = split("\t",$header);
                my $allanmarker = $splitty[0];
		print "logfile:\t\t$allanmarker in line $header\n";
		if (exists  $markerhash{$allanmarker})
		{
			print "$allanmarker has been found\n"; 
			
 
			$scafhash{$splitty[3]}=$header;
			my $chromosome=$splitty[2];
		print "Chromosome = $chromosome\n";
                #print OUT $primehash{$header},"\n";
			my $before= $splitty[3]-500000;
			if ($before < 0) { $before = 0;}
			my $after = $splitty[3]+500000;

		#####  Iterate through gff file and save any that faill between the before and after range !@@@   ############
		#
		#
			foreach (@gffray)
			{
      				my @bits = split("\t",$_);
				my $seqname=$bits[0];
				if ($seqname eq $chromosome) 
				{
					my $start=$bits[3];
					if (($start > $before) && ($start < $after))
					{
						print GFFOUT "$_\n";
					}
				}
			}
			
			chomp $chromosome;	
			if (exists $seqhash{$chromosome})
			{
				my $seq=$seqhash{$chromosome};
				my $seqlength=length($seq);
				if ($after > $seqlength) {$after = $seqlength-1;}
				print OUT ">$header -plusminus500K\n";
				my $distance=$after-$before;
				my $region=substr($seq,$before,$distance);
				print OUT "$region\n";		
			}
			else
			{
				die "We failed to find $chromosome in the sequence hash\n";
			}
		}
}


#-----------------------------------------------------------------

print " The End, c'est finis. \n ";

close INFILE;
close LOGFILE;
close MARKERFILE;
close OUT;
close GFFOUT;
exit;
