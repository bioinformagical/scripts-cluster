use strict;
use warnings;
#use Bio::SeqIO;

# 	Read in blast tabbed output into a hash.  (contig {refseqID})
# 	Iterate through the FPKM table, swapping out the contig ID for the new Refseq Id. (track how many times we fail to find a match and send that to a "unique file"
#	Write a new FPKM table using the refseq Ids instead.
# 

my $file= $ARGV[0] or die "Choose some FPKM table  file  \n ";
my $blastfile= $ARGV[1] or die "Feed me blast tabbed file.";

 open(INFILE, $file) || die("no such map file");
 open(BLAST, $blastfile) || die("no such linkage file");

my $fileout = $blastfile."-refseqId.txt";
open (FILEOTU, ">$fileout") or die $!; 

my $uniqout = $blastfile."-unique.txt";
open (UNIQUE, ">$uniqout") or die $!;

my %hash;
my$header; my $seq;
print "STARTING Loading reference DB into a HASH\n";
while (my $line=<BLAST>)
{
                chomp ($line);
		my @blast=split("\t",$line);
		my $compid=$blast[0];
		my $refseq=$blast[1];
		$hash{$compid}=$refseq;
}
#die "Size is :",scalar keys( %hash );
print " LET'S GO FIND SOME Blast HITS and get Buuuuuuuzy.\n"; 
my $header=<INFILE>;
print FILEOTU "$header"; 
while (my $line = <INFILE>)
{
	chomp $line;
	my @blast=split("\t",$line);
	my $id=$blast[0];
	if (exists $hash{$id})
	{
		print FILEOTU $hash{$id},"\t",$line,"\n";
	}
	else
	{
		print UNIQUE "$line\n";
	}
}

print "C'est Fin\n";

close(FILEOTU);
close(BLAST);
close(INFILE);
close(UNIQUE);
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
