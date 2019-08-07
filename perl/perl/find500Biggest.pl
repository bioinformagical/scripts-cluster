#! /usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;


my $input= $ARGV[0] or die "Pair Finder 1 \nI need A fasta file that is paired and interleaved from sff_extract\n";

#my $filename1 = $fName1.".paired";
#open (INFILE, ">$filename1") or die $!;



#print "Please enter filename (without extension): ";
#$input = <>;
chomp ($input);

#print "Please enter no. of sequences you want in each file ";
#$upper_limit = <>+1;
#chomp ($upper_limit);


#--------------------------------------------------------------------------------
#   read in a fasta file. 
#   	get the sizes of each sequence 
#              print a file of those sizes.....
#--------------------------------------------------------------------------------


#open (INFILE, "$input.fasta") or die "Cannot open infile, ",$input;
open (OUT, ">"."$input"."sizes") or die "Cannot open outfile!";

my $file1 = new Bio::SeqIO (-file=>$input, -format=>'fasta');

while (my $seq = $file1->next_seq)
{
		my $sid = $seq->display_id;# print "ref ", $sid, "\n";
		my $sequence = $seq->seq;
		my $length = length($sequence);
		print OUT $length,"\n";

}






close OUT;
exit;
