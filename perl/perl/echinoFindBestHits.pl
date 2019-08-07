use strict;
use warnings;
use Bio::SeqIO;
use bignum;

# Read in  Echino Blast table and identify all the RefSeq entries that have a hit.
#
# 	1. Read in table
# 	2. Fill hash of unique hits  and lowest escore. Fill 2nd hash of unique hits and # of occurences
# 	3. Add up number of hash entries (escore < e-10)
# 	4. Iterate through hash at e-50 for number of entries.
# 	5. Print out 2nd hash where # of occurences = 1.
# 
# 

my $fName1= $ARGV[0] or die "Choose a Blast output TaBLLE, tab delimited. \n";


my $fileotu = $fName1.".summary";
open (FILESUM, ">$fileotu") or die $!; 

my $filechimera = $fName1.".besthits";
open (FILEBEST, ">$filechimera") or die $!;


#my $fName1= shift or die $!;
my $file1 = new Bio::SeqIO (-file=>$fName1, -format=>'fasta');

my %uniqhash;
my %besthash;

	

#$hash{$splitter[0]}=$sequence;


	#print "bad one  ! \t",$sequence," and we are at count:", $count, "\n";
	#	print FILE1 ">",$sid,"\n",$sequence,"\n";
	#print "All Done, Count is ", $count,"\n"; 

#read in blast table file
open(READMAP, $fName1) || die("no such file");
while (my $line = <READMAP>)
{
	chomp $line;
	my @entry = split("\t",$line);
	
	#print $entry[1],"\t\t\t",$entry[3],"\n";
	
	my $gi = $entry[1];
	my $escore = $entry[3];

	if (exists $uniqhash{$gi})
	{
		my $count = $besthash{$gi};
		$count++;
		$besthash{$gi} = $count;

		#my @currentBest = split('e',$uniqhash{$gi});
		#my @latest = split('e',$escore);

		if ($uniqhash{$gi} ge $escore)
		#if (($currentBest[1] gt $latest[1]) || ($escore = 0))
		{
			#print " Newer BETTEr Escore @@!!!\t Old score in hash: ",$uniqhash{$gi}, " and new score: ", $escore,"\n";
			#print " Newer BETTEr Escore @@!!!\t Old score in hash: ",$currentBest[1], " and new score: ", $latest[1],"\n";
			$uniqhash{$gi} = $escore;
		}
	}
	else
	{
		$uniqhash{$gi} = $escore;
		$besthash{$gi} = 1.0;
	}

	#	if ($entry[9] =~ m/CHIMERA_\d+/)
	#	{
			#	print FILECHI ">",$entry[8],"\n",$hash{$entry[8]},"\n";
			#	}
			#elsif ($entry[9] =~ m/OTU_\d+/)
			#	{
			# 	 print FILEOTU ">",$entry[8],"\n",$hash{$entry[8]},"\n";

			#}

}
my $sizeU = scalar(keys %uniqhash);
my $sizeB = scalar(keys %besthash);

print FILESUM "\n\n\n\ Size of Uniq Hash is: \t",$sizeU,"\n";    
print FILESUM " Size of Best hash is: ",$sizeB,"\n";  

my $percUniq = $sizeU / 344.15 ;
my $percBest = $sizeB / 344.15 ;

print FILESUM "\n\n\n\ Percent Size of Uniq Hash is: \t %2.2f %\n",$percUniq;
print FILESUM " Percent Size of Best hash is: ",$percBest," %\n";

my $count1 = 0;
foreach my $key (keys(%besthash))
{
	#my $count1 = 0;
	if ($besthash{$key} eq 1)
	{
		$count1++;
	}
	if ($besthash{$key} eq 2)
	{
	        $count1++;
	}
	if ($besthash{$key} eq 3)
	{
	        $count1++;
	}
}

print FILEBEST "\n Count of BestHash at value of 1 is: ", $count1,"\n";


close(FILESUM);
close(FILEBEST);
close(READMAP);
exit;


