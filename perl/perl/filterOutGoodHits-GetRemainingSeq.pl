use strict;
use warnings;
use Bio::SeqIO;
use Bio::DB::GenBank;
#use Bio::SeqIO;

# 	Read in query fasta and read in blast tabbed output.
# 	Identify the blast output ID 's and append them to blast result (result is in format 7, and then only top hit).
	# Of the remaining sequences that had no hit, add those to a new fasta file of unlovedToys. 
#	Write a new fasta file  ${file}-unlovedtoys.faa
# 

my $file= $ARGV[0] or die "Choose some fasta file  \n ";
my $blastfile= $ARGV[1].".txt" or die "Feed me blast tabbed format 7 file.";

open(INFILE, $file) || die("no such map file");
open(BLAST, $blastfile) || die("no such linkage file");

my $fileout = $blastfile."-withDesc.txt";
open (FILEOTU, ">$fileout") or die $!; 

my $fastaout = $blastfile."-lonelytoy.faa";
open (FASTAOUT, ">$fastaout") or die $!;


my %hash;
my $fastacount=0;
my$header; my $seq;
print "STARTING Loading reference DB into a HASH\n";
while (my $line=<INFILE>)
{
        if ($line=~/>/)
        {
   		if ($seq) {$hash{$header} = $seq;  $fastacount++; }#print "Header = $header\n";}            
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
$hash{$header} = $seq;  $fastacount++;}
#die "Size is :",scalar keys( %hash );
print " LET'S GO FIND SOME Blast HITS and get their sequence.\n"; 

#### Note this is a Line FORMAT 7 Blast OUTPUT, different than the usual format 6.
while (my $line = <BLAST>)
{
	chomp $line;
	my @blast=split("\t",$line);
	my $query=$blast[0];
	my $hit=$blast[1];
	my @accarray=split(/\|/,$hit);
	my $acc=$accarray[3];
	### Remove all PDb related entries ###
	my $ref=$accarray[2];
	#if ($ref =~ /pdb/){print "We found a PDB entry, $line\n"; print FILEOTU "$line\tNA\n";next;}
	#if ($ref =~ /pir/){print "We found a PIR entry, $line\n"; print FILEOTU "$line\tNA\n";next;}
	#if ($ref =~ /prf/){print "We found a PRF entry, $line\n"; print FILEOTU "$line\tNA\n";next;}
		
	#my $db_obj = Bio::DB::GenBank->new;
	#my $desc;
        #if (my $seq_obj = $db_obj->get_Seq_by_id($acc))
	#{
        	#my $species_obj = $seq_obj->species;
        #	$desc = $seq_obj->desc;
#        my $genus = $species_obj->genus();
#        my $taxid = $species_obj->ncbi_taxid();
	#}
	#else
	#{
	#	$desc = "NA";
	#}
	print FILEOTU "$line\n";
	delete $hash{$query};
	#print FASTAFILE ">$query\n$hash{$query}\n";
}
my $count=0;
foreach my $key (keys %hash)
{
	print FASTAOUT ">$key\n$hash{$key}\n";
	$count++;
}
my $percent=100*($count/$fastacount);
print " Finel percent was $percent from a total of $fastacount \n";
print "C'est Fin\n";

close(FILEOTU);
close(FASTAOUT);
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
