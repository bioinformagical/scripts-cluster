#!/usr/bin/perl

use strict;
use warnings;

# Script to  identify bar codes for each "good fastq" file and write them to a file in the same order. 
#    Need barcode tab delim file.
#	Need filenames file.


# Variables for holding command line arguments
my $barcodefile = $ARGV[0];
my $filenamefile = $ARGV[1] or die "We need a number for the file position";


open(INPUTFILE, $barcodefile) or die "can't read file";

my $outfile = "log-4trimming.txt";
open OUTFILE, ">$outfile" or die "No open outfile" ;
print OUTFILE "module load fastx-toolkit/0.0.13.2 \n";

open(INPUTID,  $filenamefile) or die "oooooohnoes ! Where is $filenamefile ????";

my %idhash; 
my $Format = '';
while ( my $id = <INPUTID> )
{
	chomp $id;
	my $clippy = "fastx_clipper -i ".$id."-combined-collapsed.fastq -l 40 ";
	$idhash{$id}=$clippy;

}


# Loads one key at a time
 <INPUTFILE>; ## throw away header
while ( my $line = <INPUTFILE> ) 
{
	my @infoline = split("\t",$line);
	my $barcode = $infoline[2];
	my $species = $infoline[3];
	#### change - to a pt
	$species =~ s/-/pt/g;
 
	if (exists $idhash{$species})
	{
		my $tmp = $idhash{$species};
		$idhash{$species} = $tmp." -a ".$barcode;
		print $idhash{$species}," is now what it is   \n";
	}
	else
	{
		print "failed to find",$species,"\n";
		#die "We did not find the correct prgeny. Likely a small character is off for $species \n";
	}

	#print "We got ",$barcode," and ",$species,"\n";

}

foreach my $key (keys %idhash) 
{
	print OUTFILE $idhash{$key}," -o ",$key,"-bartrimmed.fna\n"; 


}
# Prints the final built VCFoutput in the .txt file format  
#print OUTFILE "$VCFoutput";

# Close opened files
close(INPUTFILE);
close(INPUTID);
close(OUTFILE);
exit;


