#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use File::Copy "cp";

####  GOAL:   Add an outgroup to the ortho clustter

# This reads in the 
# 	outgroup fasta file ..
#	orthocluster fasta file
#	ortho tab delimited blast result file.
#
#	Make a hash of ortho outgroup fasta.  outgroupID --> sequence 
#	make a hash outgroup blast hits bj3@xxxx -->outgroupID
#	
#	Iterate through orthocluster sequences
#		check if outgroup blast hits has a match. Count it if so.
#	Decide on which outgroup ID showed up most.
#	Print a new fasta file with appended outgroup sequence added.
#

my $numargs = $#ARGV + 1;
if ($numargs != 3)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $orthoFastaFile= $ARGV[0] or die "Feed me ortho fasta file with refseq in the header name ...";
my $outgrouporthoFastaFile=$ARGV[1] or die "Feed me spurp refseq aa fasta filer ...";
my $outgroupBlastfile=$ARGV[2] or die "Feed me tabbed outgroup blast file ...";
#Parse Ts file for lengths of 

print $orthoFastaFile,"\n";
#die ("die");

### Copy contents of orthocluster to new file.
cp("$orthoFastaFile","$orthoFastaFile.outgrouped.fasta") or die "can't copy the outfile";

my $foo = new Bio::SeqIO (-file=>$outgrouporthoFastaFile, -format=>'fasta');
my %outgroupHash;
while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	
	#print ">",$sid,"\n";
	$outgroupHash{$sid}= $seq->seq;
}

#die(" well our refseq was $refseqacc");

#####   Read in blast table and make a few hashes
my %counthash;
my %seq2outgrouphash;

open(SEARCH, $outgroupBlastfile) or die "can't read tabbed blast file";
while (my $line = <SEARCH>)
{
	chomp $line;
	        #print   $line,"\n";
	my @entry = split("\t",$line);
	my $outgroupid = $entry[1];
	my $orthoid = $entry[0];

	$seq2outgrouphash{$orthoid}=$outgroupid;
	
	if (exists $counthash{$outgroupid})
	{
		my $county = $counthash{$outgroupid};
		$county++;
		$counthash{$outgroupid} = $county;
	}
	else
	{
		$counthash{$outgroupid} = 1;
	}
}

####	Check which outgroup hash has the most hits, or take 1st one


my $foo2 = new Bio::SeqIO (-file=>$orthoFastaFile, -format=>'fasta');

my $bestoutgroup = "dud";
my $bestcount = 0;
while (my $seq = $foo2->next_seq)
{
        my $sid = $seq->display_id;
        
	## Check if $sid is in outgroupBlast Hash
	if (exists $seq2outgrouphash{$sid})
	{
		if($counthash{$seq2outgrouphash{$sid}} > $bestcount)
		{
			$bestcount = $counthash{$seq2outgrouphash{$sid}};
			$bestoutgroup = $seq2outgrouphash{$sid};
		}	
	}

}

### Opening outfile file, and adding the outgroup to the end.
open (OUTFILE, ">>$orthoFastaFile.outgrouped.fasta");
print OUTFILE ">bj1000@",$bestoutgroup,"\n";
print OUTFILE $outgroupHash{$bestoutgroup},"\n";


print "All Done, we made it to the end.\n"; 

close (SEARCH);
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


