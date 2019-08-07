use strict;
use warnings;
#use Bio::SeqIO;

# 	Read in blast tabbed output X 2. 1 for markers, 1 for the assembly.
#	Read in the marker table and make hash of marker name + the entire line.
# 	 
#	Check that each markah blast finds a partner in perfect matrimony with no other mutiple hits. make sure a reverse blast also matches....
#	Write a new table file.  
# 

my $file= $ARGV[0] or die "Choose some big marker table file  \n ";
my $blastfile= $ARGV[1] or die "Feed me blast tabbed file for markahvsXXX.out";
my $blast2file= $ARGV[2] or die "Feed me blast tabbed file for markahvsXXX.out";

 open(INFILE, $file) || die("no such map file");
 open(BLAST, $blastfile) || die("no such first blast file");
 open(BLAST2, $blast2file) || die("no such 2nd blast file");

my $fileout = $blastfile."-blastedFilteredTable.txt";
open (FILEOUT, ">$fileout") or die $!; 

my %hash;
my$header=<INFILE>;
print FILEOUT $header,"\n";

print "STARTING Loading marker hapmap table into a HASH\n";
while (my $line=<INFILE>)
{
	chomp $line;
	my @table=split("\t",$line);
	my $tp = $table[0];
	$hash{$tp} = $line;
}

#die "Size is :",scalar keys( %hash );
print " LET'S GO FIND SOME Blast HITS and then MOAR blast Hits !\n"; 

my %blasthash;
while (my $line = <BLAST>)
{
	my @blast=split("\t",$line);
	my $que=$blast[0];
	my @temp=split("_",$que);
	my $query=$temp[0];
	my $scaffold=$blast[1];
	my $start=$blast[8];
	my $stop=$blast[9];
	
	$blasthash{$query}=$scaffold;	
		
}

while (my $line = <BLAST2>)
{
        my @blast=split("\t",$line);
        my $que=$blast[1];
        my @temp=split("_",$que);
        my $tp=$temp[0];
        my $scaffold=$blast[0];
        my $start=$blast[8];
        my $stop=$blast[9];
	
	if (exists $blasthash{$tp})
	{
		print FILEOUT $hash{$tp},"\n";
	}
 
}




print "C'est Fin\n";

close(FILEOUT);
close(BLAST);
close(BLAST2);
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
