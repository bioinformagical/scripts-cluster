use strict;
use warnings;
use Bio::SeqIO;

# Read in blast file into a hash and filter out any duplicate query / hit pairs. Write a new blast out file. 
# 
# 

#my $file= $ARGV[0] or die "Choose some header file s \n ";
my $blastfile= $ARGV[0] or die "Feed me blastx tabbed file.";

 #open(HEADER, $file) || die("no such map file");
 open(BLASTX, $blastfile) || die("no such linkage file");

my $fileout = $blastfile."-filter.txt";
open (FILEOTU, ">$fileout") or die $!; 

my %head;
#die "Size is :",scalar keys( %head );


while (my $line = <BLASTX>)
{
	my @blast=split("\t",$line);
	my $gene=$blast[0]."\t".$blast[1];
	#print $gene," is blast result.\n";
	chomp $gene;
	
	if (! exists $head{$gene})
	{
		$head{$gene}=$line;
		print "We are in:",$gene,"\n";
	}
	
	#foreach my $key (keys %head)
	#{
		#print "We are in:",$gene,"\n";
	#	if ($key =~ /$gene/){
			#print "We are in:",$gene,"\n";
			#my $temp=$head{$gene};
			#$temp++;
	#		$head{$gene}=$line;
	#	}
	#}
}

foreach my $key (keys %head)
{
	print FILEOTU  $head{$key},"\n";
}

close(FILEOTU);
close(BLASTX);
exit;


