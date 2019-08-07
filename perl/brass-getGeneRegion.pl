#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

#
######		This will read in a brassica fasta, a GFF file and a table of start and end positions.
#		We write out the gene region.
#		We write the GFF for that region.
#		We write out the 5' and 3' flamnking regions of each gene to a new fasta file.
#				
#
#

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the  fasta files. \n";
my $gfffile=$ARGV[1] or die " we also need a 2nd gff file\n";
my $positionfile=$ARGV[2] or die " we also need a marker file with just the names of the original marker \n";
#########  Read in Primers  and throw them into a hash

#thehash
my %primehash;

# Open in and out files
open (INFILE, "$gfffile") or die "Cannot open infile, ";
open (REGIONOUT, ">"."$positionfile"."-region.fna") or die "Cannot open outfile!";
open (OUT, ">"."$positionfile"."-flanking.fna") or die "Cannot open outfile!";
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
open (POSFILE, "$positionfile") or die "Cannot open marker file to write!";


my %scafhash;
my $name;
while ( my $line=<POSFILE>)
{               
                my $header = $line;
                chomp $header;
		my @splitty = split("\t",$header);
                $name = $splitty[0];
		my $chromosome = $splitty[1];
		my $seq = $seqhash{$chromosome};
		my $regionstart = $splitty[2];
		my $regionstop = $splitty[3];
		#print "logfile:\t\t$allanmarker in line $header\n";

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
					my $stop=$bits[4];
					my $dist=$stop - $start;
					my $flankdist = $start + $dist + 2000;
					my $flankstart = $start - 1000;
					if (($start > $regionstart) && ($start < $regionstop) )
					{
						print GFFOUT "$_\n";
					#	print OUT ">FLANKED:$bits[0]\t$bits[2]\t$bits[3]\t$bits[4]\t$bits[8]\n";
					#	print OUT substr($seq,$flankstart,$flankdist);
					}
				}
			}
			
			chomp $chromosome;	
	if (exists $seqhash{$chromosome})
	{
			#	my $seq=$seqhash{$chromosome};
			#	my $seqlength=length($seq);
			#	if ($after > $seqlength) {$after = $seqlength-1;}
		print REGIONOUT ">$name-regionof-$chromosome\n";
		my $distance=$regionstop-$regionstart+1;
		my $region=substr($seq,$regionstart,$distance);
		print REGIONOUT "$region\n";

		print OUT ">$name-Flanking 2K on each side of $regionstart-$regionstop :$chromosome\n";
		my $s1 = $regionstart - 2000;
		my $s2 = $distance + 4000;
		print OUT substr($seq,$s1,$s2);		
	}
	else
	{
		die "We failed to find $chromosome in the sequence hash\n";
	}
		
}


#-----------------------------------------------------------------

print " The End, c'est finis. \n ";

close INFILE;
close REGIONOUT;
close POSFILE;
close OUT;
close GFFOUT;
exit;
