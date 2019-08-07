use strict;
use warnings;
#use Bio::SeqIO;

# 	Read in blast tabbed output into a hash.  (hit  {blastresults in an array})  ### this is because there are many blastresult hits possible
# 	Iterate through the interproscan table, and write a new lines for each hash hit we have, where it will be blast result and then interscan line result.
# 

my $file= $ARGV[0] or die "Choose some interproscan table  file  \n ";
my $blastfile= $ARGV[1] or die "Feed me blast tabbed file.";

 open(INFILE, $file) || die("no such interproscan file");
 open(BLAST, $blastfile) || die("no such blast file");

my $fileout = $blastfile."-merged.txt";
open (FILEOTU, ">$fileout") or die $!; 


my %hash;
my$header; my $seq;
print "STARTING Loading reference DB into a HASH\n";
while (my $line=<BLAST>)
{
                chomp ($line);
		my @blast=split("\t",$line);
		my $estquery=$blast[0];
		my $oathit=$blast[1];
		if (exists $hash{$oathit})
		{
			push @{$hash{$oathit}},$line;
		}
		else
		{
			$hash{$oathit}[0]=$line;
		}
}
#die "Size is :",scalar keys( %hash );
print " LET'S GO FIND SOME Blast HITS and get Buuuuuuuzy.\n"; 
#my $header=<INFILE>;
#print FILEOTU "$header"; 
while (my $line = <INFILE>)
{
	chomp $line;
	my @interpro=split("\t",$line);
	my $id=$interpro[0];
	if (exists $hash{$id})
	{
		my @tmparray = @{ hash{$id} };
		my $size = scalar(@tmparray); 
		foreach (my $index=0;$index<=$size;$index++) 
		{ 
  			print FILEOTU $hash{$id}[$index],"\t",$line,"\n";
			print "the size is $index for $id\n";
		}
	}
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
