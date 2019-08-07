#!/usr/bin/perl
use strict;
use warnings;
#use Bio::SeqIO;


# This reads in a vcf, and a hap.txt file and a master table.
# Make Hash of VCF, make hash of hap file.
# Read in big table, check if in hashes, and write out the appropriate VCF call to a new file.
######    This script works only with D. Yakuba flies, not the D. sant. Seek other script for the D.sant files.
##		 perl ~/scripts/perl/mcchare-tableColumnMaker.pl 1466.vcf   ./ masterTemplate.current


my $numargs = $#ARGV+1;
if ($numargs != 2)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $vcffile= $ARGV[0] or die "VCF FILE OPEN \n I need a VCF file..s. \n";
my $masterfile= $ARGV[1] or die "Feed me reads file so I can figure out Total reads ...";


#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $totalreads = 0;
my %vcfhash;
my %haphash;
#my @conan;

#my $foo = new Bio::SeqIO (-file=>$transcriptfile, -format=>'fasta');
open(VCF, $vcffile) or die "can't read VCF file";

print "Starting run on ".$ARGV[1]."\n"; 
while (my $line = <VCF>)
{
	chomp $line;
	if ($line =~ /^#/) { next; }
	#print $line."\n";
	my @fields = split('\t', $line);
	my $pos = $fields[0]."-".$fields[1];
	my $info = $fields[9];
	my @ray = split(':',$info);
	my $snpcall = $ray[0];
	#print $snpcall."\n"; 
	if ($snpcall =~ m/1\/2/) {$snpcall="0/1";}
	elsif ($snpcall =~ m/1\/1/) {$snpcall="1/1";}
	elsif ($snpcall =~ m/0\/1/) {$snpcall="0/1";}
	elsif ($snpcall =~ m/0\/0/) {$snpcall="0/0";}
	 elsif ($snpcall =~ m/.\/./) {$snpcall="0/0";}
	else {print $snpcall; die ("What is this crazy snpcall????\n");} 
	$vcfhash{$pos}= $snpcall;
	#print $pos,"\t",$vcfhash{$pos},"\n";
}
print "Finished VCF hash loading\n";
#die("we made vcf hash...");


#READ IN HAP FILE and get total sum of reads
#open(READS, $hapfile) or die "can't read reads file";
#my $haploo="notset";
#while (my $line = <READS>)
#{       
#      	chomp $line;
#      	#print $line."\n";
#	my @fields = split(' ', $line);
#	my $pos = $fields[0]."-".$fields[1];
#	my $hap=$fields[2];
#	my $end=$fields[3];
#	for (my $i=$fields[1];$i<=$end;$i++)
#	{
#		$pos=$fields[0]."-".$i;
#		$haphash{$pos}= $hap;
#	}
        #print " Hap POsition is now ",$pos," and the hap call is ",$hap,"\n";
#}
#print "Finished HAP hash loading\n";
#die(" we read hap hash");


#READ IN Master table postions and get counts
print "Starting Master table process\n";
open(MASTER, $masterfile) or die "can't read master table.";

open (OUTFILE, ">$ARGV[0]"."-col.txt");
### Open a count file too.
### Chrom-Position  0/0     0/1     1/1  
open (COUNTFILE, ">$ARGV[0]"."-count.txt");
my @count=(0,0,0);
###  PRINT a HEADER   ###
print OUTFILE $ARGV[0]."\n"; 
while (my $line = <MASTER>)
{
	chomp $line;
	
	my @fields = split('\t', $line);
	my $pos = $fields[0];
	if (exists $vcfhash{$pos})
	{
		if ($vcfhash{$pos} =~ m/0\/1/)
		{
			print OUTFILE "$vcfhash{$pos}\n";$count[1]++;
		}
		elsif ($vcfhash{$pos} =~ m/1\/1/)
		{
			print OUTFILE "$vcfhash{$pos}\n";$count[2]++;
		}
		else 
		{
			print OUTFILE "0/0\n";$count[0]++;
		}
	}
		else
		{
			print OUTFILE "0\n";
		}
}


### Print the count array
print COUNTFILE "$ARGV[0]\t@count\n";
print "All Done, we made it to the end.\n"; 

close(VCF);
#close(READS);
close(MASTER);
close(OUTFILE);
close(COUNTFILE);
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


