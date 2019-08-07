use strict;
use warnings;
use Bio::SeqIO;

# Read in text file, has it.
# read 2nd file and search hash for match and print to new file.
# 

my $file= $ARGV[0] or die "Choose some NCBI blast output format 6 tabbed file  \n ";
my $searchfile = $ARGV[1] or die "Choose some NR based accesion numbers file ";
my $outfile= $ARGV[2] or die "feed me out file as argument 2.";

open(SEARCHFILE, $searchfile) || die("no such map file"); 
my %hashy;
while (my $line = <SEARCHFILE>)
{  
	chomp $line;
	#print $line,"\n";
	#my @firstname = split('', $line);
        #print $splitty[1],"\n";
        my @accarray = split(/\|/, $line);
	#print $accarray[3],"\t", $accarray[4],"\n";
	$hashy{$accarray[3]}=$accarray[4];
}
print "Hash isize is ",scalar keys %hashy ,"\n";
#die;

open(ACCFILE, $file) || die("no such map file");


open (OUTFILE, ">$outfile") or die $!; 

my $cutoff = 1;
my $goodrow = 0;
while (my $line = <ACCFILE>)
{
	chomp $line;
	my @splitty = split('\t', $line);
	#print $splitty[0],"\n";
	my @accarray = split(/\|/, $splitty[1]);
	#print $accarray[3],"\n";
	if (exists $hashy{$accarray[3]})
	{
		print OUTFILE $line,"\t",$accarray[3],"\t",$hashy{$accarray[3]},"\n";
		$goodrow++;
	}
}

print " Number of good rows markers is ",$goodrow,"\n";
close(OUTFILE);
close(SEARCHFILE);
close(ACCFILE);
exit;


