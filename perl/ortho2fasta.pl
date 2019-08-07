#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;
use List::MoreUtils qw/ uniq /;

#
#	This will parse the orthmcl output file and generate a bunch of fasta files for each generated ortholog
#       1. Read in Fasta to a hash
#	2. Read each line from orthoMCL output, fetch appropos fastas and write to a file.
#
#
#


my $fastafile= $ARGV[0] or die "500 largest Fastas Finder 1 \nI need A fasta file \n";
my $ortholist = $ARGV[1] or die "500 largest Fastas Finder 1 \nI need A list file \n";
#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;



#print "Please enter filename (without extension): ";
#$fastafile = <>;
chomp ($fastafile);

#print "Please enter no. of sequences you want in each file ";
#$upper_limit = <>+1;
#chomp ($upper_limit);


#--------------------------------------------------------------------------------
#   read in a fasta file. 
#--------------------------------------------------------------------------------
my %tshash;

#open (INFILE, "$fastafile.fasta") or die "Cannot open infile, ",$fastafile;
#open (OUT, ">"."$fastafile"."500large.fna") or die "Cannot open outfile!";

my $file1 = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

while (my $seq = $file1->next_seq)
{
		my $sid = $seq->display_id;# print "ref ", $sid, "\n";
		my $sequence = $seq->seq;
		my $length = length($sequence);
		#print OUT $sid, "\t", $length,"\n";
		$tshash{$sid}=$sequence;
}
print "Finished loading fasta seqinces";

#--------------------------------------------------------------------------------
##   read in OrthoMCL  file. 
##--------------------------------------------------------------------------------
#
open(MASTER, $ortholist) or die "can't read refseq list file.";
my $len;
my $species;


while (my $line = <MASTER>)
{
	chomp $line;
	my @array = split(":",$line);
	my @first = split(/\(/,$array[0]);
	my $ortho = $first[0];
	#open (OUT, ">"."$ortho".".faa") or die "Cannot open outfile!";
	#print $ortho,"\t","\n";
	#print OUT ">",$line,"\n",$tshash{$line},"\n";
	#print $array[1],"\n"; 
	my @muddyIDs = split(/ +/,$array[1]);
	#print scalar(@muddyIDs),"\t",$muddyIDs[0],"\t",$muddyIDs[1],"\n";
	shift(@muddyIDs);  ## 1st element is an empty tab so buh bye to that.
	#print scalar(@muddyIDs),"\t",$muddyIDs[0],"\t",$muddyIDs[1],"\n";
	

	#### Figure out Number of species   ####
	my $numspecies=0;
	my @tmparray;
	for my $id (@muddyIDs)
	{
		my @tmp = split(/\|/,$id);
		#print $tmp[0],"\t\t",$tmp[1],"\n"; 
		push (@tmparray, $tmp[0]);
	}
	my $size= scalar @tmparray;
	#print "size of array before uniq:", $size,"\n";
	$numspecies = scalar (uniq @tmparray);
	#print "size of array after uniq:", $numspecies,"\n";
	
	
	###  Printing off the faSTA File now that we know # of species.
	
	if(($numspecies <= 4) && ($numspecies >=2))
	{ #print "less than 4:", $numspecies;
	open (OUT, ">","/lustre/groups/janieslab/ortho2014/lessThan4/"."$ortho"."-".$numspecies.".faa");
	}
	if(($numspecies >= 5) && ($numspecies <=10))
	{
	open (OUT, ">","/lustre/groups/janieslab/ortho2014/ortho5-10/"."$ortho"."-".$numspecies.".faa");
	}
	if(($numspecies >= 11) && ($numspecies <=20))
	{
        open (OUT, ">","/lustre/groups/janieslab/ortho2014/ortho11-20/"."$ortho"."-".$numspecies.".faa");  
        } 
	if($numspecies >=20)
        {
        open (OUT, ">","/lustre/groups/janieslab/ortho2014/ortho20plus/"."$ortho"."-".$numspecies.".faa");
        }
	#else
	#{open (OUT, ">"."$ortho"."-".$numspecies.".faa") or die "Cannot open outfile!";}
	
	
	
	for my $id2 (@muddyIDs)
	{
		my @temp= split(/\|/,$id2);
		$species = $temp[0];
				
		#We get the amino acid Counts below
		#my @temp2=split('\.',$id2);
		my $resCount= $temp[1];
		#print $resCount;

		my $sequence = $tshash{$id2};
		if ($species =~ /tri/)
		{
			$len = length $species;
			$len = $len - 3;
			$species=substr($species,0,$len);
			#$speciesName ="$species/\|$temp[1]";
			#print $species," hooray we split it\n";
			#die;
		}
		
		#print $species," is the species\n";
		#print OUT1 ">",lc($species),"|AA.",$resCount,"\n",$sequence,"\n";
		#print OUT2 ">",lc($species),"|AA.",$resCount,"\n",$sequence,"\n";
		#print OUT3 ">",lc($species),"|AA.",$resCount,"\n",$sequence,"\n";
		#print OUT4 ">",lc($species),"|AA.",$resCount,"\n",$sequence,"\n";
		#print OUT5 ">",lc($species),"|AA.",$resCount,"\n",$sequence,"\n";
		print OUT ">",lc($species),"|",$resCount,"\n",$sequence,"\n";
	}
	print " All done:  ","$ortho","-",$numspecies,".faa","\n";
	#close OUT1;
	#close OUT2;
	#close OUT3;
	#close OUT4;
	#close OUT5;
	#close OUT;
}	

close OUT;
close MASTER;
exit;
