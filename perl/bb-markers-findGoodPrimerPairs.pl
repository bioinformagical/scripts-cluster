use strict;
use warnings;
#use Bio::SeqIO;

# 	Read in scaffold fasta and read in bowtie tabbed output of markers to scaffolds.
# 	Identify the markers where they have a reverse partner on the same scaffold.  
#	Write a new table with columns on the end. scaffold size  reverseComplimentOnSameCompliment primerNearEnd primerAlone   
# 

my $file= $ARGV[0] or die "Choose some fasta ref file  \n ";
my $bowtiefile= $ARGV[1] or die "Feed me bowtie tabbed sam file. (with all the \@gobbledegook removed";

 open(INFILE, $file) || die("no such map file");
 open(BOWTIE, $bowtiefile) || die("no such linkage file");

my $fileout = $bowtiefile."-filterPlus.txt";
open (FILEOTU, ">$fileout") or die $!; 

my %hash;
my$header; my $seq;
print "STARTING Loading reference DB into a HASH\n";
while (my $line=<INFILE>)
{
        if ($line=~/>/)
        {
   		if ($seq) {my $sz = length $seq; $hash{$header} = $sz; print "Header = $header, size = $sz \n ";}            
		$header = $line;
		$header =~ s/^>//; # remove ">"
	        $header =~ s/\s+$//; # remove trailing whitespace
		$seq="";
	}
        else
        {
                chomp ($line);
		$seq .=$line;
        }
}
if ($seq) { # handle last sequence
my $sz= scalar $seq;
$hash{$header} = $sz;}
#die "Size is :",scalar keys( %hash );
print " LET'S GO FIND SOME Bowtie HITS and find matches.\n"; 

## Print header ##
print FILEOTU "Marker\tAlignment Code\tScaffold Name\tPosition\tQuality\tScaffoldLength\tNearEnd\n";

my %bowhash; my %reversehash;
while (my $line = <BOWTIE>)
{
	chomp $line;
	my @bowtie=split("\t",$line);
	my $marker=$bowtie[0];
	my $alignCode=$bowtie[1];
	if ($alignCode == 4) { next;}
	#print $alignCode, " is the align code\n";
	my $scaffold=$bowtie[2];
	#print "Scaffold is $scaffold \n";
	chomp $scaffold;
	my $position=$bowtie[3];
	my $qual=$bowtie[4];
	if (! exists $hash{$scaffold}) { die "We no have $scaffold in the fasta hash \n."}
	my $size = $hash{$scaffold};
	my $isnearend = 0;
	if ($position < 1500) { $isnearend=1;}
	my $posNearEnd = $size - $position;
	if ($posNearEnd < 1500) { $isnearend=1;}
	print FILEOTU $marker,"\t$alignCode\t$scaffold\t$position\t$qual\t",$size,"\t",$isnearend,"\n";
	if ($marker =~ /reverse/ && ($alignCode == 0 || $alignCode == 16)) 
	{
		if (exists $reversehash{$scaffold})
		{
			my $tmp = $reversehash{$scaffold};
                        $tmp = $tmp." ".$marker;
                        $reversehash{$scaffold}=$tmp;
		}
		else
		{
			$reversehash{$scaffold} = $marker;
		}
	}
	elsif ($alignCode == 0 || $alignCode == 16)
	{
		if (exists $bowhash{$scaffold})
		{
			my $tmp = $bowhash{$scaffold};
			$tmp .= " ".$marker;
			$bowhash{$scaffold}=$tmp;
		}
		else
		{
			$bowhash{$scaffold}=$marker;
		}
	}
}

##  	Find matching bits 	##
my $filepairout = $bowtiefile."-pairedPrimersMatch.txt";
open (PAIROUT, ">$filepairout") or die $!;

open(BOWTIE, $bowtiefile) || die("no such linkage file");
my $goodcount=0;
my$badcount=0;

while (my $line = <BOWTIE>)
{
	chomp $line;
        my @bowtie=split("\t",$line);
        my $marker=$bowtie[0];
        my $alignCode=$bowtie[1];
        #print $alignCode, " is the align code\n";
        my $scaffold=$bowtie[2];
	chomp $scaffold;
	if ((exists $bowhash{$scaffold}) && (exists $reversehash{$scaffold}))
	{
		#print "We have both !\n";	
		$goodcount++;
		print PAIROUT $scaffold,"\t";
		#for (my $i = 0; $i < scalar @bowhash{$scaffold}; $i++)
		#{
	        print PAIROUT "$bowhash{$scaffold}";
		#}
		print PAIROUT "\tREVERSE\t";
		#foreach (@reversehash{$scaffold})
                #{
                print PAIROUT "$reversehash{$scaffold} \n";
        }
	else
	{
		#print " We only have 1 of the 2 !\n";
		$badcount++;
		next;
	}
}
print " size of bowhash is ",scalar(keys %bowhash)," and size of reverse hash is ",scalar(keys %reversehash),"\n"; 
print "Good count = $goodcount and badcount = $badcount \n";
print "C'est Fin\n";

close(PAIROUT);
close(FILEOTU);
close(BOWTIE);
close(INFILE);
exit;

sub read_fasta_file {
   my %seqs;
   my $header;
   my $seq;
   open (IN, $file) or die "can't open $file: $!\n";
   while (<IN>) {
      if (/>/) {
         if ($seq) {    
            $seqs{$header} = $seq;
         }              

         $header =~ s/^>//; # remove ">"
         $header =~ s/\s+$//; # remove trailing whitespace

         $seq = ""; # clear out old sequence
      }         
      else {    
         s/\s+//g; # remove whitespace
         $seq .= $_; # add sequence
      }         
   }    
   close IN; # finished with file

   if ($seq) { # handle last sequence
      $seqs{$header} = $seq;
   }    

   return \%seqs;
}

sub check4Partner {


}
