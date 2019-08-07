#!/usr/bin/perl
use strict;
use warnings;

#
######		This will read in a panther sequencepathway text file and hash it.
#		We feed in a BJ# to make a new file of.
#               And then we pull ourt Panther IDs from our panther file, get teh UniprotKB id and write out the id for every matching BJ line. 
#
## read in the line arguments from command line

my $assocfile= $ARGV[0] or die "Did not have an arguments to read in the 2 files. \n";
#my $bjid=$ARGV[1] or die "Need a second file that is nucmer coords file.\n"; 
my $pantherfile=$ARGV[1] or die "Need a second file that is nucmer coords file.\n";

#########  Read in Primers  and throw them into a hash

#thehash
my %scafhash;

# Open in and out files
open (INFILE, "$assocfile") or die "Cannot open infile, ";
open (OUT, ">"."$pantherfile"."-uniprotkb.txt") or die "Cannot open outfile!";

# peruse the in file and load the hash

open (PANTHERFILE, "$pantherfile") or die "Cannot open panther file!";

my %hash;
while ( my $line=<INFILE>)
{               
                my $header = $line;
                chomp $header;
		my @splitty = split(/\t/,$line);
		my $panther; 
		my $uniprot;
		foreach (@splitty)
		{
		
			my $test = $_;
			#print $test."\n";
			if ($test =~ /PTHR/) {$panther=$test;}
			elsif ($test =~ /UniProtKB=/)
			{
				 my @poof = split("UniProtKB=",$test);				
				$uniprot=$poof[1];
			}
		} 
		$hash{$panther}=$uniprot;
		print " \nWe found a panther ID = $panther and we found a Uniprot id = $uniprot  ";
		#print OUT $header,"\n";
                #print OUT $scafhash{$header},"\n";
}

my $header; my $sequence;my $id;
my $bacscafcount=0;
my %bachash;
my %perchash;


#die;
#### Load up the bachash with scaffolds
while (my $line=<PANTHERFILE>)
{
        chomp $line;
	#if (index($line, $bjid) == -1) { print $line."\n";next;} 
        my @splitty = split("\t",$line);
        #print "$line\t $splitty[1] \n";
        my $panther=$splitty[1];
	if (exists $hash{$panther})
	{
		print OUT "$hash{$panther}\n";
	} 
}

my $sizefoo=  keys %bachash;
print "$sizefoo\n";


print " The End, c'est finis. \n ";

close INFILE;
#close NUCFILE;
close PANTHERFILE;
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
