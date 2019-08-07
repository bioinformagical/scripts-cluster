use strict;
use warnings;
use Bio::SeqIO;

# Read in fasta file used for uchime and read in uchime readmap.uc.
# Identify each sequence as either chimera OR OTU and write 2 new fasta files
# accordingly
# 

my $file= $ARGV[0] or die "Choose some map file s \n ";
my $linkagenames= $ARGV[1] or die "Feed me linkage names file.";

 open(MAPMAP, $file) || die("no such map file");
 open(LINK, $linkagenames) || die("no such linkage file");

my $fileout = $file.".filter.txt";
open (FILEOTU, ">$fileout") or die $!; 

my @links;
while (my $line = <LINK>)
{
	push(@links,$line);
}

my $headerline = <MAPMAP>;
my @headers = split("\t",$headerline);
my $h =0; 
my $vb158 = "banana";
while ($h < scalar (@headers))
{    
 	if ($headers[$h] =~ /VI158/)
	{
		$vb158 = $h;
		die "$h";
	}
	print $h++;
}
my $rowcount;
my $colcount;
my $goodrow=0;
while (my $line = <MAPMAP>)
{
	$rowcount++;
	my @col = split("\t",$line);
	$colcount = scalar (@col);
	#print " Number of cols = ", scalar (@col),"\n";
	#print $line;
	my $baddies = 0;
	my $i =0;
	my $vb158flag = 0;
	while ($i < scalar (@col))
	{
		#if ($col[$i] == 0 || $col[$i] == 2)
		if ($col[$i] == 0)
		{
			$baddies++;
		}

		if ($i == $vb158)
		{
			if ($col[$i] == 2) {$baddies = $baddies + 1000;}
		}
		$i++;
	}
	#print " Number of baddies = ",$baddies,"\n";	
	my $percent = $baddies / $colcount * 100;
	print " Percent of baddies = ",$percent,"%\n";
	if ($percent < 23)
	{
		$goodrow++;
		print FILEOTU $line,"\n";
	}
}


print " Number of good rows markers is ",$goodrow,"\n";
print " Number of linkage name cols = ", scalar (@links),"\n";
close(FILEOTU);
close(LINK);
close(MAPMAP);
exit;


