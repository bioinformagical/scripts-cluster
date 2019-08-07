#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#
#	This will parse the orthmcl output file and generate a stat file.
#       1. 
#	2. Read each line from orthoMCL output, gather stats and write a 1 line entry out to a stats folder. 
#
#
#


#my $fastafile= $ARGV[0] or die "500 largest Fastas Finder 1 \nI need A fasta file \n";
my $ortholist = $ARGV[1] or die "500 largest Fastas Finder 1 \nI need A list file \n";
my $sizefile =  $ARGV[0] or die "need tab delim size file to add to stats \nI need Afile \n";

#--------------------------------------------------------------------------------
#   read in a protein size file. 
#--------------------------------------------------------------------------------
my %sizehash;

open (SIZEFILE, "$sizefile") or die "Cannot open infile, ",$sizefile;
#open (OUT, ">"."$fastafile"."500large.fna") or die "Cannot open outfile!";

#my $file1 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $line = <SIZEFILE>)
{
		my @splitty = split("\t",$line);
		my $id = $splitty[0];   #### looks like this: refseqSpurp|aa24 
		my @splitty2 = split("\Q|",$id);
		my $sid = $splitty2[3];
		my $length = $splitty[1];
		chomp $length;
		if (length($length) == 0){ die "We had a hit length that was empty";}
		#print $sid, "\t", $length," are the deets for the protein list.\n";
		$sizehash{$sid}=$length;
}
#die " end of hash maker";
#--------------------------------------------------------------------------------
##   read in OrthoMCL  file. 
##--------------------------------------------------------------------------------
#
open(MASTER, $ortholist) or die "can't read refseq list file.";

my %ortholist ;
my $spurphit ;
my $linecount = 0;
my $hitlength = -9999;

while (my $line = <MASTER>)
{
	$linecount++;
	chomp $line;
	my @array = split("\t",$line);
	$spurphit = $array[1]."\t".$array[2];
	my @first = split("-",$array[0]);
	
	#print $array[1],"\n";
	$ortholist{$first[0]} = 1;
	
	##getting length
	my @acc = split("\Q|",$array[1]);
	print $acc[3]," is the spurp reference in the original stats list\n";
	$hitlength = $sizehash{$acc[3]};
	#if (length $hitlength == 0) die "We had a hit length that was empty";
	#print $sizehash{$array[1]}," for ", $array[1];
	my $bj = $first[0];
	#open (OUT, ">"."$ortho".".faa") or die "Cannot open outfile!";


	#print OUT ">",$line,"\n",$tshash{$line},"\n";
	#print $array[1],"\n"; 
	my @muddyIDs = split(/ +/,$array[1]);
	#print scalar(@muddyIDs),"\t",$muddyIDs[0],"\t",$muddyIDs[1],"\n";
	shift(@muddyIDs);  ## 1st element is an empty tab so buh bye to that.
	#print scalar(@muddyIDs),"\t",$muddyIDs[0],"\t",$muddyIDs[1],"\n";

	for my $id (@muddyIDs)
	{
		my @temp= split(/\(/,$id);
		my $seqid = $temp[0];
		print $seqid," is now shrink to this after splitting again\n";
		#print OUT ">",$seqid,"\n",$tshash{$seqid},"\n";
	}

}

my $numoftaxa = keys %ortholist;
if ($numoftaxa > 14)
{
	system(" cp ${ortholist}.fasta ~/echinoderms/ortho/process4ptp/"); 
}
my $list;
foreach my $key (sort keys %ortholist)
{
	$list .= $key.",";
}
my $comma = chop($list); 
if ($hitlength < 1){ die "hitlength of < 1";}
open (OUT, ">"."$ortholist".".stat") or die "Cannot open outfile!";
print OUT $linecount,"\t",$numoftaxa,"\t",$hitlength,"\t",$spurphit,"\t",$list,"\n";

close SIZEFILE;
close OUT;
close MASTER;
exit;
