#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

#
######		This will read in a brassica protein fasta, a GFF file and a table of chr, start and end positions.
#		We write out the gene region GFFs to file.
#		We write out the protein sequence of matching GFF to a new fasta file.
#				
#
#

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the  fasta files. \n";
my $gfffile=$ARGV[1] or die " we also need a gff file\n";
my $positionfile=$ARGV[2] or die " we also need a marker file with positions / coordinates of interest  \n";
#########  Read in Primers  and throw them into a hash

#thehash
my %primehash;

# Open in and out files
#open (INFILE, "$gfffile") or die "Cannot open infile, ";
open (PROTEINOUT, ">"."$positionfile"."-proteinHits.faa") or die "Cannot open outfile!";
#open (OUT, ">"."$positionfile"."-flanking.fna") or die "Cannot open outfile!";
open (GFFOUT, ">"."$positionfile"."-subsection.gff") or die "Cannot open outfile!";
#Load gff into an array
my @gffray;
chomp(@gffray = <INFILE>);

##   Read in genome sequences to hash
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
		my @heady = split(' ',$header);
		my $protid = $heady[0];
		$header = $protid;
		print "$header \n";
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
#die;

######  Now read GFF file and keep only lines that have a gene. Make Hash with protein ID as the key.
my %gffhash;
open (GFFFILE, "$gfffile") or die "Cannot open marker file to write!";

while ( my $line=<GFFFILE>)
{
	my $header = $line;
        chomp $header;
	my @splitty = split("\t",$header);
	if ($splitty[2] =~ m/mRNA/)
	{
		my $blah = $splitty[8];
		my  @boomy = split(/[;=]/,$blah);
		my $id = $boomy[1];
		#print " Our isolated ID is $id \n";
		$gffhash{$id} = $line
	}

}
#die;

#######  Now open the marker file that contains the marker that we want regions from   #########
open (POSFILE, "$positionfile") or die "Cannot open marker file to write!";


my %scafhash;
my $name;
while ( my $line=<POSFILE>)
{               
                my $header = $line;
                chomp $header;
		my @splitty = split("\t",$header);
		my $chromosome = $splitty[0];
		my $regionstart = $splitty[1];
		my $regionstop = $splitty[2];
		#print "logfile:\t\t$allanmarker in line $header\n";

		#####  Iterate through gff file and save any that faill between the before and after range !@@@   ############
		#
		#
		foreach my $key (keys %gffhash)
		{
			my @bits = split("\t",$gffhash{$key});
			my $seqname=$bits[0];
			if ($seqname eq $chromosome) 
			{
				my $start=$bits[3];
				my $stop=$bits[4];
				my $dist=$stop - $start;
				my $flankdist = $start + $dist + 500000;
				my $flankstart = $start - 500000;
				if (($start > $regionstart) && ($start < $regionstop) )
				{
					print GFFOUT "$gffhash{$key}\n";
					print PROTEINOUT ">$key\n$seqhash{$key}\n";
				#	print OUT substr($seq,$flankstart,$flankdist);
				}
			}
		}
}


#-----------------------------------------------------------------

print " The End, c'est finis. \n ";

close INFILE;
close PROTEINOUT;
close POSFILE;
close OUT;
close GFFOUT;
close GFFFILE;
exit;
