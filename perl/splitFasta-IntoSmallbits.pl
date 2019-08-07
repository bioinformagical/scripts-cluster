#!/usr/bin/perl
use warnings;
#use 5.12.4;
use File::Basename;
#Split FASTA files into chunks determined by user.
#by RNAeye

my $file = "/lustre/groups/janieslab/trinityRun2/orthomcl/all1-48.fasta"; #enter name of your FASTA file here
my $record_per_file = 1000;	#Enter how many record you want per file / chunk size
my $file_number = 1;	#this is going to be a part of your new file names.
my $counter = 0;	#counts number of records

open (FASTA, "<", "$file" ) or die "Cannot open file $file $!";

while (<FASTA>) {
if (/^>/) { 
if ($counter++ % $record_per_file == 0) {
my $basename = basename($file);
my $new_file_name = $basename. $file_number++ . ".faa"; 
close(NEW_FASTA);
open(NEW_FASTA, ">", $new_file_name) or die "Cannot open file $new_file_name $!";
}
}
print NEW_FASTA $_;	
}
