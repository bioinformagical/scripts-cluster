use strict;
use warnings;
#use Bio::SeqIO;
#use bignum;


#######    Read in CDHIT cluster file, identify unique species in each cluster and spit out a count for all.

# 	5. Profit ?!
# 
# 

my $fName1= $ARGV[0] or die "Feed first a cdhit cluster file \n";
#my $filenames = $ARGV[1] or die "Need a file containing all the file names. eg 15-ORTHOMCL151.faa.blastp.xml-XP_001186977.2.tabbed.fasta  \n";

my $fileotu = $fName1."-speciescount.summary";
open (OUT, ">$fileotu") or die $!; 


#read in cluster cdhit  file
open(FILE, $fName1) || die("no such file");

my $name;
while (my $line = <FILE>)
{
	chomp $line;
	
		#print $line,"\n";
		print $line,"\t";	
		my $check =0;
		while ($check == 0)
		{
			$line = <FILE>;
			chomp $line;
			if ($line =~ m/^>/)
			{
				print OUT $line,"\t";
				$check = 1;
			}
			my @splitty = split(/\|/,$line);
			my @split2 = split(/>/, $splitty[0]);
			my $id = $split2[1];
			print $id,"\t";
		}
	#my @entry = split(/[-ORTHOMCL,.]+/,$line);
	#print " OUR ortho num is ",$num,"\n"; 
	
	#print $entry[1],"\t\t\t",$entry[3],"\n";
	
}


close(FILE);
close(OUT);
exit;


