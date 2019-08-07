use strict;
use warnings;
use Bio::SeqIO;

# Read in bt fasta header file and read in blastx tabbed output. Count how often 
# gene gets a hit.  Write out count file for all genes.
# 

my $file= $ARGV[0] or die "Choose some header file s \n ";
my $blastxfile= $ARGV[1] or die "Feed me blastx tabbed file.";

 open(HEADER, $file) || die("no such map file");
 open(BLASTX, $blastxfile) || die("no such linkage file");

my $fileout = $blastxfile.".count.txt";
open (FILEOTU, ">$fileout") or die $!; 

my %head;
while (my $line = <HEADER>)
{
	chomp $line;
	$head{$line}=0;	
	#if ($line =~ /Cry2Aa15_AFK30405/){ die "found Cry2Aa15_AFK30405";}
	print $line," is header.\n";
}
#die "Size is :",scalar keys( %head );


while (my $line = <BLASTX>)
{
	my @blast=split("\t",$line);
	my $gene=$blast[1];
	#print $gene," is blast result.\n";
	chomp $gene;
	
	#if (exists $head{$gene})
	foreach my $key (keys %head)
	{
		#print "We are in:",$gene,"\n";
		if ($key =~ /$gene/){
			print "We are in:",$gene,"\n";
			my $temp=$head{$gene};
			$temp++;
			$head{$gene}=$temp;
		}
	}
	#else
	#{
	#	die" we failed to find ",$gene;
	#}
}

foreach my $key (keys %head)
{
	print FILEOTU  $key,"\t",$head{$key},"\n";
}


close(FILEOTU);
close(BLASTX);
close(HEADER);
exit;


