#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in 2 fasta files (before and after PTP pruning) and will add a single taxa from the branches that got chopped off.
# It will add the longest sequence from each taxa that does not exist in the post fasta file.
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 2)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $prefile= $ARGV[0] or die "echino parser \n I need a blast tab file..s. \n";
my $postfile= $ARGV[1] or die "Feed me transcript file ...";
#my $speciesID=$ARGV[3] or die "Feed me a bj Number ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $count = 0;
my %posthash;
my %taxahash;
my $outfile = $prefile.".reAdded.fasta";
open(OUTFILE, ">$outfile") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$postfile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	$posthash{$sid}= $seq->seq;
	#print "sid=",$sid,"\n";
	$count++;
	my @liner = split("@",$sid);
	my $taxa = $liner[0];
	$taxahash{$taxa}=$sid;
	print "This taxa is ",$taxa,"\n";
}

#die("we made Ts hash...");

 my $foo2 = new Bio::SeqIO (-file=>$prefile, -format=>'fasta');
while (my $seq = $foo2->next_seq)
{
	my $sid = $seq->display_id;
	my @liner = split("@",$sid);
	my $taxa = $liner[0];
	
	if ($taxa =~ m/XP/)
	{
		$posthash{$sid}= $seq->seq;
		print " Adding special: ",$sid,".\n";
	}
	elsif ($taxa =~ m/NP/)
	{
		$posthash{$sid}= $seq->seq;
		print " Adding special: ",$sid,".\n";
	}
	elsif (exists $taxahash{$taxa})
	{
		print "Ignoring this taxa, " ,$sid,"\n";
	}
	else
	{
		$posthash{$sid}= $seq->seq;
		$taxahash{$taxa}=$sid;
		print " Adding a new taxa !! = ",$taxa, " for sequence ",$sid,".\n";
	}
}

#die ("so far so good, 2nd file down.");

# READ IN PRE  FASTA FILE and find all the taxa types that are missing. 
foreach my $key ( keys %posthash )
{
	#chomp $line;
	#my @array = split("\t",$line);
	#my $first = $array[0];
	#chomp $first;
	#my $seq = $posthash{$first};

	print OUTFILE ">",$key,"\n",$posthash{$key},"\n";
}
#
#
 print "All Done, we made it to the end.\n"; 

#close(BLASTFILE);

close(OUTFILE);
exit;


sub calcrpkm
{
	if (@_ != 3) {die ("Wrong number of args for RPKM calulator method");}
	#	print " We are in RPKM !!\n";
	my $read = $_[0];
	 my $tslength = $_[1]/1000;
	 my $totalreads = $_[2]/1000000;
	
	 my $a = $read/$tslength;
	 my $b = $a/$totalreads;
	 $b;
	# my $a = (10**9*$read)/($tslength*$totalreads);
}


