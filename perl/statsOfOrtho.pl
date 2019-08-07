#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

# This reads in a fasta list  and makes new fasta file.. (removing some white spaces
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 1 argument, All YOUR BASE ARE BELONG TO US\#");
}


my $fastafile= $ARGV[0] or die "Feed me transcript file ...";

open(OUTFILE, ">>/lustre/groups/janieslab/ortho2014/stats.txt") or die "can't write outfile";


my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

my @lenarray;
my $N = 0;
my $total=0;
my $max=-1;
my$min=1000000000000000;

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	#$tshash{$sid}= $seq->seq;
	#print OUTFILE ">",$sid,"\n";
	#print OUTFILE $seq->seq,"\n"; 
	#print $refid,"\t sid=",$sid,"\n";
	my $len = length($seq->seq);
	$N++;
	$total=$total+$len;
	if ($max < $len){$max = $len;}
	if ($min > $len){$min = $len;}

	push (@lenarray, $len);
}

#print "Size of array is",scalar @lenarray," \n";
#@lenarray = sort @lenarray;
@lenarray = sort { $a <=> $b } @lenarray;

#my $per25 = &percentile(25,\@lenarray)
#my @numbers = (10.22,20.33,22.3,11.3,12.4,8.3,10.4);
my $mean = $total/$N;

print OUTFILE $fastafile,"\t",$mean,"\t",$min,"\t",$max,"\t";
#printf OUTFILE"%d\t", percentile($_,\@lenarray)
#printf "%d\t", percentile2($_,\@lenarray)
for (qw/25 50 75 95/)
{
	my $u = &percentile2($_,\@lenarray);
	printf OUTFILE"%d\t",$u;
}
print OUTFILE "\n";

#
print "All Done, we made it to the end.\n"; 

close(OUTFILE);
exit;

sub percentile 
{
	my ($p,$aref) = @_;
	my $percentile = int($p * $#{$aref}/100);
	return (sort @$aref)[$percentile];
}

sub percentile2 
 {
	my($p, $ray) = @_;
	my $percentile = int($p * $#{$ray}/100);		
	#print "Perc is ",$percentile,"\n";
	return $$ray[$percentile]; 
}

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


