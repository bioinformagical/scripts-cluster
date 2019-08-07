use strict;
use warnings;
use Bio::SeqIO;
use Bio::DB::GenBank;

# Read in blast file into a hash and filter out any duplicate query / hit pairs. 
#	Write a new blast out file. 
# 	Filter by score.
# 	Count how often a target gets a hit

#my $file= $ARGV[0] or die "Choose some header file s \n ";
my $blastfile= $ARGV[0] or die "Feed me blastx tabbed file.";

 #open(HEADER, $file) || die("no such map file");
 open(BLASTX, $blastfile) || die("no such linkage file");

my $fileout = $blastfile."-filter.txt";
open (FILEOTU, ">$fileout") or die $!; 

my %head;
my %counthash;
#die "Size is :",scalar keys( %head );


while (my $line = <BLASTX>)
{
	chomp $line;
	my @blast=split("\t",$line);
	my $gene=$blast[1];
	my $score = $blast[10];
	if ($score > 1e-25) { next;}
	#print $gene," is blast result. Score is $score\n";
	chomp $gene;
	
	if (exists $counthash{$gene})
	{
		$head{$gene}=$line;
		my $tmp= $counthash{$gene};
		$tmp=$tmp+1;
		$counthash{$gene}=$tmp;
		#print "We are in:",$gene," and tmp = $tmp\n";
	}
	else
	{
		$head{$gene}=$line;
		$counthash{$gene}=1;
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

foreach my $key (keys %counthash)
{
	if ($counthash{$key} > 10000)
	{
		print FILEOTU  $key,"\t",$counthash{$key},"\t";
	
		my @ray = split(/\|/,$key);
		my $id = $ray[3];
	
		my $db_obj = Bio::DB::GenBank->new;
 		my $seq_obj = $db_obj->get_Seq_by_id($id);
		my $species_obj = $seq_obj->species;
		my $species = $species_obj->species();
		my $genus = $species_obj->genus();
		#print "The species is $species for $id and the genus is $genus \n";
		print FILEOTU "$id\t$species\t$genus\n";
	}
}

close(FILEOTU);
close(BLASTX);
exit;


