use strict;
use warnings;
#use Bio::SeqIO;

# 	Read in -db fasta and read in blast tabbed output.
# 	Identify the coords in the blast output and grab the sequence from that region. 
#	Write a new fasta file  DBname-coordStart-coordstop.fna
# 

my $file= $ARGV[0] or die "Choose some fasta ref file  \n ";
my $blastfile= $ARGV[1] or die "Feed me blast tabbed file.";

 open(INFILE, $file) || die("no such map file");
 open(BLAST, $blastfile) || die("no such linkage file");

my $fileout = $blastfile."-blastedRegions.fna";
open (FILEOTU, ">$fileout") or die $!; 

my %hash;
my$header; my $seq;
print "STARTING Loading reference DB into a HASH\n";
while (my $line=<INFILE>)
{
        if ($line=~/>/)
        {
   		if ($seq) {$hash{$header} = $seq; print "Header = $header\n";}            
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
$hash{$header} = $seq;}
#die "Size is :",scalar keys( %hash );
print " LET'S GO FIND SOME Blast HITS and get their sequence.\n"; 

while (my $line = <BLAST>)
{
	my @blast=split("\t",$line);
	my $query=$blast[0];
	my $chromo=$blast[1];
	my $start=$blast[8];
	my $stop=$blast[9];
	if ($blast[8] > $blast[9]) { $start=$blast[9]; $stop=$blast[8];}     ### check to see which is higher, and reverse em !
	my $offset=1+$stop-$start;
	my $seq=$hash{$chromo};
	my $subseq=substr($seq, $start, $offset);

	#print $subseq," is blast sequence coord result for $chromo.\n";
	print FILEOTU ">",$query,"-$chromo:$start-$stop\n";
	print FILEOTU $subseq,"\n";
	#chomp $gene;
	
}

print "C'est Fin\n";

close(FILEOTU);
close(BLAST);
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