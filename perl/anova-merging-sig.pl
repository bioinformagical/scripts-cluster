#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

#######           Reads in Marker phenotyping table and anova table sig table. For each Sig finding, we average the replicates together.
#		BUT NOT ACROSS YEARS. 
#

my $input= $ARGV[0] or die "\nI need A sig ANOVA file \n";
my $secondfile = $ARGV[1] or die "\nI need A pheno file \n";
#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;

#print "Please enter filename (without extension): ";
#$input = <>;

my $fileotu = $input."-averaged.txt";
open (OUT, ">$fileotu") or die $!;

 open (INFILE, "$input") or die "Cannot open infile!";
 open (SECONDFILE, "$secondfile") or die "Cannot open infile!";
my @markray;
my @titleray;
my @mray;
my $header;#=<INFILE>;
while (my $line = <INFILE>)
{
        chomp $line;
	my @ray=split("\t",$line);
	my $id=$ray[0];
	#my $str=join("", @ray);
	push $mray,$id;
	print "My ID is $id and the string is $line\n";
}
#die;
#my @charray;
$header= <SECONDFILE>;
my %poshash;
my @headray=split("\t",$header);
my $size = scalar @headray;
for (my $i=3;$i<$size;$i++)
{
	if (exists $mhash{$headray[$i]})
	{
		my $tmp=$i-3;
		my $phenid=$headray[$i];
		$poshash{$phenid} = $tmp ;
	}
	
}
####  READ in all datapoints to wither a 1-1 1-2  2-1 or 2-2 time frame for each V_XX sibling. Write each line into a hash and write this hash into hashhash. 
my %hashhash;
my %sibhash;
while (my $line = <SECONDFILE>)
{
	chomp $line;
	my @ray=split("\t",$line);
	$sibhash{$ray[0]}=1;
	my $id=shift(@ray)."-".shift(@ray)."-".shift(@ray);

	print " We got array ID of $id\n";
	my %tmphash;
	$hashhash{$id}=\@ray;
	#$hashhash
}	
my $tmp2size = keys %hashhash;
print "The size of hashhash is $tmp2size\n";  	

#### Iterate through each sibhash value, get the years and reps and average them together.
foreach my $key (keys %sibhash)
{       
	##year 1
	my $id1=$key."-1-1";
	my $id2=$key."-1-2";
	print OUT "$key\t1\t";
	foreach my $mkey (keys %mhash)
	{
		#print "$mkey TIME:\n";
		my $pos=$poshash{$mkey};
		my @tmpray1= @{$hashhash{$id1}};
		my @tmpray2= @{$hashhash{$id2}};
		#foreach (@tmpray1) { print "Our 2 arrays are $tmpray1[9]       AND     $tmpray2[10] \n"; }
		if (@tmpray1 > 5 && @tmpray2 > 5)
		{
			my $sum=$tmpray2[$pos]+$tmpray1[$pos];
			my $avg=$sum/2;
			print " The sum was $sum\n";
			print OUT "$avg\t";
		}
		elsif (@tmpray1 > 5)
		{
			print OUT "$tmpray1[$pos]\t";
		}
		elsif (@tmpray2 > 5)
		{
			print OUT "$tmpray2[$pos]\t";
		}
		else
		{
			#die " We found neither for $key\n";
			print OUT "0\t";
		}	
	}

	print OUT "\n";
}

	## year2	
	
close (SECONDFILE);
close (OUT);
close (INFILE);
exit;


#--------------------------------------------------------------------------------
# chomp_fasta: Merges all the sequence lines in a fasta file into one line, so
#              each sequence in the fasta file will have one header line and 
#              one sequence line only
#--------------------------------------------------------------------------------

sub chomp_fasta {

open (INFILE, "$input") or die "Cannot open infile, ",$input;
open (OUT, ">"."$input"."_chomped.fasta") or die "Cannot open outfile!";

while (my $line=<INFILE>) { # Please remove the spaces

if ($line=~/>/) {
print OUT "\n$line";
}

else {
chomp ($line);
print OUT "$line";
}

}
close OUT;
}

