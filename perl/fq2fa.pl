#!/usr/bin/perl

use strict;
use warnings;
#use Cwd;

##### ##### ##### ##### #####

use Getopt::Std;
use vars qw( $opt_a $opt_c $opt_v);

# Usage
my $usage = "

fa2fq.pl - converts fastq files to fasta format.


Usage: perl fa2fq.pl options
 required:
  -a	fastq input file.
 optional:
  -c	inset in nucleotides, used to remove barcodes [default = 0].
  -v	verbose mode [T/F, default is F].

";

# command line processing.
getopts('a:c:v:');
die $usage unless ($opt_a);

my ($inf, $inset, $verb);
$inf	= $opt_a if $opt_a;
$inset	= $opt_c ? $opt_c : 0;
$verb	= $opt_v ? $opt_v : "F";

##### ##### ##### ##### #####
# Globals.

my ($temp, $in, $outF, $outR, $outf, $outr);
my @temp;

##### ##### ##### ##### #####
# Manage outfile name.
@temp = split(/\//, $inf);
$temp = $temp[$#temp];
@temp = split(/\./, $temp);
$outf = $temp[0] . ".f";
$outr = $temp[0] . ".r";
##### ##### ##### ##### #####
# Main.

# Open input and output files.
open( $in, "<",  $inf)  or die "Can't open $inf: $!";
open( $outF, ">",  $outf.".fa")  or die "Can't open $outf.fa: $!";
open( $outR, ">",  $outr.".fa")  or die "Can't open $outf.fa: $!";

while (<$in>){
  chomp($temp[0] = $_);		# First line is an id.
  chomp($temp[1] = <$in>);	# Second line is a sequence.
  chomp($temp[2] = <$in>);	# Third line is an id.
  chomp($temp[3] = <$in>);	# Fourth line is quality.

  # Prune first char.
  $temp[0] = substr($temp[0], 1);

  # Substring to inset value.
  $temp[1] = substr($temp[1], $inset);
if($temp[0]=~ m/1$/)
{
  # Print to fasta file.
  print $outF ">$temp[0]\n";
  print $outF "$temp[1]\n";
}
if($temp[0]=~ m/2$/)
{
  # Print to fasta file.
  print $outR ">$temp[0]\n";
  print $outR "$temp[1]\n";
}

}

close $in or die "$in: $!";
close $outF or die "$outF: $!";
close $outR or die "$outR: $!";
