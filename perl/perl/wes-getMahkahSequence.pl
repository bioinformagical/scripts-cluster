#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

#
######		This will read in a brassica chromsome  fasta and a list of markers whose names contain the chr # and position.
#		Get + - 1 million sequences on either side of the marker position. produce a new fasta file containing each of the lines from the text file.
#

## read in the line arguments from command line

my $fastafile= $ARGV[0] or die "Did not have an arguments to read in the 2 fasta files. \n";
my $sfile=$ARGV[1] or die "Need a second file to search against.\n"; 
my $gfffile=$ARGV[2] or die " we also need a 3rd gff file\n";

#########  Read in Primers  and throw them into a hash

#thehash
my %primehash;

# Open in and out files
open (INFILE, "$gfffile") or die "Cannot open infile, ";
open (OUT, ">"."$sfile"."-mahkas.fna") or die "Cannot open outfile!";
open (GFFOUT, ">"."$sfile"."-subsection.gff") or die "Cannot open outfile!";
#Load gff into an array
my @gffray;
chomp(@gffray = <INFILE>);


# peruse the in file and load the hash
open (SCAFFILE, "$sfile") or die "Cannot open scaffold fasta file!";

my %hash;
while ( my $line=<SCAFFILE>)
{               
                my $header = $line;
                chomp $header;
		my @splitty = split("-p",$header);
                $hash{$splitty[1]}=$header;
		#print ,"\n"plitty[1]
                #print OUT $primehash{$header},"\n";
		my $before= $splitty[1]-1000000;
		my $after = $splitty[1]+1000000;

		#####  Iterate through gff file and save any that faill between the before and after range !@@@   ############
		#
		#
		foreach (@gffray)
		{
      			my @bits = split("\t",$_);
			my $start=$bits[3];
			if (($start > $before) && ($start < $after))
			{
				print GFFOUT "$_\n";
			}
		}

}

my $header; my $sequence;my $id;
my $file2 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');
while (my $seq = $file2->next_seq) 
{ 
	my $sid = $seq->display_id;# print "ref ", $sid, "\n";
        my $sequence = $seq->seq;

	foreach my $key (keys %hash)
	{  
		#if ($sid eq $key) 
		#{	
			print OUT ">$hash{$key} -plusminus1million\n";
			my $before = $key-1000000;
			my $extract = substr($sequence, $before, 2000000);
			#my $after  = length($sequence)+1000000;
			print OUT $extract,"\n";; 
			delete $hash{$key};
		#}
	}
}

#--------------------------------------------------------------------------------
#  Now that hash is filled, loop10. t0hrough file and find matches and print them.  
#              0
#---------------..


#-----------------------------------------------------------------


print " The End, c'est finis. \n ";

close INFILE;
close SCAFFILE;
close OUT;
close GFFOUT;
exit;
