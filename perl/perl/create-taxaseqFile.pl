#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# Script to create a taxaseq.file  for purposes of phyldog.
#	File will look like  
#	Asteroid_Xyloplax:bj12|aa.34
#	Reads in taxa file and full aa sequence file.	



# Command  line arguments
my $taxafile = $ARGV[0];
my $aafastafile =  $ARGV[1];
open(INPUTFILE, "$taxafile") or die "can't read file, $taxafile";

my $count=0;
my %lilhash;


######   Read in taxa table to hash taxa,bj#  ########
while ( my $line = <INPUTFILE> ) 
{
	# Scans each line to fill hash
	chomp $line;
	my @ray = split("\t",$line);
	my $taxa = $ray[0]."_".$ray[1];
	my $bjnum = $ray[2];
	$lilhash{$bjnum}=$taxa;
	print "Our bj was ",$bjnum," and the name is ",$taxa,"\n";
}
close (INPUTFILE);
#die " made it through loading of little table";

###open to the outfiles now
open OUTFILE, ">/lustre/groups/janieslab/4phyldog/taxaseq.file" or die "No open outfile" ;

#########   Read in fasta and write out results in taxaseq.file format.    ##############

my $file1 = new Bio::SeqIO (-file=>$aafastafile, -format=>'fasta');

while (my $seq = $file1->next_seq)
{
                my $sid = $seq->display_id;# print "ref ", $sid, "\n";
		$sid = lc($sid);
		if ($sid =~ m/refseq/) {next;}
                my $sequence = $seq->seq;
		my @ray = split(/\|/,$sid);
		my $lastbit = $ray[1];
		my @ray2 = split("bj",$ray[0]);
		my $num = $ray2[1];
		if ($num =~ m/tri/) {$num=substr($num, 0, -3);}
		#print " $sid   $ray[0]    $num  \n";
		
		print OUTFILE $lilhash{$num},":bj",$num,"|$lastbit\n";
		
}

	
	$count++;
	


print "OUr line count was ", $count, "\n";
#print "OUr GOOD count was ", $goodcount, "\n";

# Close opened files
close(INPUTFILE);
close(OUTFILE);
exit;


