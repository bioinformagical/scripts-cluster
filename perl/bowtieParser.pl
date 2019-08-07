#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;


# This reads in blasted table results and the fimal table, of which the blasted table get appended to.

my $numargs = $#ARGV + 1;
if ($numargs != 4)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $masterfile= $ARGV[0] or die "Bowtie parser \n I need a table file with 8 columns from Bowtie..s. \n";
my $positionfile= $ARGV[1] or die "Feed me position file ...";
my $consensusfile= $ARGV[2] or die "Feed me consensus fasta file with 1 sequence ...";
my $rejectfile= $ARGV[3] or die "where is the rejected SNP file?";

#chomp $positionfile;
open (POSFILE, $positionfile) or die $!;

my @positions;
my %poshash;
my @conan;

while (my $line = <POSFILE>)
{
	#print $line,"\t";
	chomp $line;
	push (@positions, $line);
	$poshash{$line} = ['0','0','0','0']; 
}
my $numsnps = @positions;
print $numsnps," was the number of SNP locations we care about. \n";

#for (my $i =0;$i < $numsnps; $i++)
#{
#	print $positions[$i],"\n";
#}

#die;

#READ IN CONSENSUS SEQUENCE
my $foo = new Bio::SeqIO (-file=>$consensusfile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	my $sid = $seq->display_id;
	my $sequence = $seq->seq;
	@conan = split('',$sequence);
	my $sequencelength = @conan;
	print $sequencelength," was the consensus length  we care about and the last NT is ",$conan[2834], ".\n";
}

#READ IN BOWTIE RESULTS
#	FILTER TOO SHORT READS
#	DEFINE BOUNDARIES OF THE ALIGNED READ
#	DETERMINE HOW MANY SNPs FALL INTO THAT RANGE
#	CHECK THAT EITHER SIDE IS A CORRECT MATCH
#	UPDATE THE SNP HASH ACCORDINGLY
print "Reading in lines from alignment file:  ",$masterfile,"\n";

#my $filename1 = $masterfile.".master.table".$column;
#open (OUTFILE, ">>masterfile"."SNPcounted.txt") or die $!; 

open(MASTER, $masterfile) or die "can't read master";
open (NEWSNPFILE, ">>".$rejectfile) or die $!;
open (SNPFILE, ">".$masterfile.".snps.txt") or die $!;

while (my $line = <MASTER>)
{
	chomp $line;
	
	my @fields = split('\t', $line);
	if (defined $fields[0] and  defined $fields[3])
	{
		if (length($fields[2]) > 19)
		{
			chomp $fields[2];
			#print  $fields[2], "\n";
			#  HUNTING FOR NEW SNPs.
			if (exists $fields[4])
			{
				#print  $fields[0], "\t",$fields[4], "\n";
				my @diffs = split(',',$fields[4]);
				#print $diffs[0],"\n";
				for (my $i=0; $i < @diffs; $i++)
				{
					my @num = split(':',$diffs[$i]);
					my $location = $num[0] + $fields[1] + 1;
					#print $location,", The the starting spot was ",$fields[1],"\n";
					if (exists $poshash{$location})
					{
						my $sn = substr $num[1],-1;
						#print "Eureka,  we found a SNP: ",$location,"\t",$sn,"\n";
						 
					}
					else
				       	{ 
						#	print "\nMissed this one !! ",$location,"\n\n";
					       print NEWSNPFILE $location,"\n";	
					}
				}
			} # END OF HUNT FOR NEW SNPS

			# Updating HASH for every SNP location in the sequence.
			my $start = $fields[1] + 1;
			my $stop = $fields[1] + 1 + length($fields[2]);
			for (my $i = $start; $i < $stop; $i++)
			{
				if (exists $poshash{$i})
				{
					my @quence = split('',$fields[2]);

					my $j = $i - $start;
					#print $i,"\t",$quence[$j],"\n";
					#	my @temparray;
					#for (int $i=0; $i<4; $i++) {$temparray[$i]= $poshash{$i}[$i];	
					if ($quence[$j] eq 'A')
					{
						#	$temparray[0]++;
						$poshash{$i}[0]++;
						print "we in A and the temp array count is now at ",$poshash{$i}[0],"\n";
					}
					elsif ($quence[$j] eq 'C')
					{
						# $temparray[1]++;
						$poshash{$i}[1]++;
					       	print "we in C ! \n";
					}
				       elsif ($quence[$j] eq 'G')
			               {
					       # $temparray[2]++;
					       $poshash{$i}[2]++;
					       print "we in G ! \n";
	                               }
		       		       elsif ($quence[$j] eq 'T')
		                       {
					       # $temparray[3]++;
					       $poshash{$i}[3]++;
					       print "we in T ! \n";
                                       }
				       else {die "We hit no A,C,G or T";}      
					#print SNPFILE $i,"\t",$quence[$j],"\n";
					# $poshash{$i} = \@temparray;
				}
			}	
		}
	}	

	else {  die("Our master table file, lacked the 4 columns needed !",@fields); }
}
#
#
#Print out the hash of array table now.
##
print SNPFILE $masterfile,"\n";
print SNPFILE "SNP\tA\tC\tG\tT\n"; 
foreach (sort {$a <=> $b} keys(%poshash))
	{
		print SNPFILE  $_,"\t";
		for (my $x=0;$x<4;$x++)# (@poshash{$_})
		{
			print SNPFILE $poshash{$_}[$x],"\t";
		}
		print SNPFILE "\n";	
	}

        print "All Done, we made it to the end.\n"; 

close(POSFILE);
close(MASTER);
close(NEWSNPFILE);
close(SNPFILE);
exit;




