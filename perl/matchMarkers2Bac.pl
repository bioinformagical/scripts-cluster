#!/usr/bin/perl
use strict;
use warnings;

#
######		This will read in a text file of scaffolds found in markers
#               a nucmer ccords file of bacs found in scaffolds. 
#
#		Read scaffolds into hash.
#		Read bac alignments/scaffolds into hash and check if bac is in scaffolds hash.
#		Print out many various results.

## read in the line arguments from command line

my $scaffile= $ARGV[0] or die "Did not have an arguments to read in the 2 files. \n";
my $nucfile=$ARGV[1] or die "Need a second file that is nucmer coords file.\n"; 
my $nucfile2=$ARGV[2] or die "Need a second file that is nucmer coords file.\n";

#########  Read in Primers  and throw them into a hash

#thehash
my %scafhash;

# Open in and out files
open (INFILE, "$scaffile") or die "Cannot open infile, ";
open (OUT, ">"."$nucfile2"."-bac2mark.txt") or die "Cannot open outfile!";


# peruse the in file and load the hash

open (NUCFILE, "$nucfile") or die "Cannot open scaffold fasta file!";

my %hash;
while ( my $line=<INFILE>)
{               
                my $header = $line;
                chomp $header;
                $hash{$header}=0;
		#print OUT $header,"\n";
                #print OUT $scafhash{$header},"\n";
}

my $header; my $sequence;my $id;
my $bacscafcount=0;
my %bachash;
my %perchash;

#throw away nuc header, 5 lines
<NUCFILE>;<NUCFILE>;<NUCFILE>;<NUCFILE>;<NUCFILE>;
#### Load up the bachash with scaffolds
while (my $line=<NUCFILE>)
{
        chomp $line;
        my @splitty = split(" ",$line);
        #print "$line\n";
        my $bac=$splitty[11];
        my $scaf=$splitty[12];
        my $percid=$splitty[9];
	my $position=$splitty[4];
	chomp $bac; chomp $scaf;
	if ($percid > 88)
	{
		$perchash{$bac}=$percid;
		if ((exists $bachash{$bac}) && (exists $hash{$scaf}))
		{
			my $tmpp = $bachash{$bac}." ".$scaf."-".$position;
        		$bachash{$bac}=$tmpp;
		}
		elsif (exists $hash{$scaf})
		{
			$bachash{$bac}=$scaf."-".$position;
		}
	}
}
my $sizefoo=  keys %bachash;
print "$sizefoo\n";

close NUCFILE;

######   
# my $nucfile2=$ARGV[2] or die "Need a second file that is nucmer coords file.\n";
open (NUCFILE, "$nucfile2") or die "Cannot open scaffold fasta file!";
#Check each line to see if $bac reverse read exists in hash
#throw away nuc header, 5 lines
<NUCFILE>;<NUCFILE>;<NUCFILE>;<NUCFILE>;<NUCFILE>; 
while (my $line=<NUCFILE>) 
{ 
	chomp $line;
	my @splitty = split(" ",$line);
	#print "\n $line is the line 2nd time through.\n";
	my $bac=$splitty[11];
	my $scaf=$splitty[12];
	my $percid=$splitty[9];
	my $position=$splitty[4];
		#$bachash{$bac}=$scaf;
	#print "$bac\t$scaf\t$position\n";
	#if (exists $hash{$scaf})
	#{
	chomp $bac; chomp $scaf;
	print $bac,"\n";
	chop $bac;
	#my $other=&fetchother($bac);
	my $other=$bac."f";
	print $other,"\n";
#	if ((exists $bachash{$other}) && (exists $hash{$scaf}))
	if (exists $bachash{$other})
	{
		if ($percid > 85 )
        	{
			print OUT  "$other\t$bachash{$other}\t$perchash{$other}\t$bac","r\t$scaf\t$position\t$percid\n";
		}
	}
	#}
	#else{ next;}
}

foreach my $key (keys %bachash)
{ 
	#my $otherend = &fetchother($key);
	#print "$key\t\t\t$otherend\n";


}


#--------------------------------------------------------------------------------
#  Now that hash is filled, loop10. t0hrough file and find matches and print them.  
#              0
#---------------..


#-----------------------------------------------------------------


print " The End, c'est finis. \n ";

close INFILE;
#close NUCFILE;
close NUCFILE;
close OUT;
exit;


sub fetchother
{
	my $id=$_[0];
	if ($id =~ /_RP-/)
	{
		$id =~ s/RP-1_16DEC14CC_R/T7_26NOV14CC_F/g;
	}
	elsif( $id =~ /_T7_/)
	{
		#print " Id was $id but ";
		$id =~ s/T7_26NOV14CC_F/RP-1_16DEC14CC_R/g;
		#print "ID is now $id \n";
	}
	else { die " We found neither bac to have the right format: $_[0] \n";}	

	return $id;
}
