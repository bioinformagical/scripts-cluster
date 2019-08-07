#!/usr/bin/perl  

# script name:  ace2fasta for usage w/ AceBrowser-3.1
# author:       he22@cornell.edu 29may01  (w/ invaluable advice provided by dave matthews)

# This script converts the xxx.fasta.cap.ace file produced by the Cap3 alignment program to 
# a fasta formatted file. Each output sequence record is padded with hyphens according to 
# information extracted from the input file.

# Usage: % ace2fasta xxx.fasta.cap.ace > outputFile.fasta  

use strict 'vars';
#use vars qw/$DB $URL %PAPERS/;
#use Ace 1.73; 
#use CGI::Carp qw/fatalsToBrowser/;
use File::Path;

my $len;              # contig length 
my %names;            # identifier and start position of each seq
my @sequence;         # seq. ids and sequences
my $tmp_seq;
my $x;
my $args = 0;
my $namecount = 0;
while(<>){ #ARGV
    $args++;          # print header info
    if($args < 2) { print ""; }

    if($_ =~ /CO/){ 
	$len = &length();
	  #print "\nContig length: $len \n\n";
    }
    if($_ =~ /AF/){   # AF --> ID and start position  
        &nameArr();   # for each AF, the global %name gets a name and start-position added
    }
    $tmp_seq .= $_;   # tmp_seq is entire input file now...    
}  
@sequence = &remTop($tmp_seq);    # @sequence == ID and seq (plus QA line == garbage)
@sequence = &cleanIt(@sequence);  # strip off QA etc 
$tmp_seq = "";                    # clear tmp_seq...this will be written to file

my $size = $#sequence;
for($x=0; $x <= $size; $x++){     # pass in 1 element: ID line and sequence
    &splitIt($sequence[$x]);      # splitIt can return $sequence[$x] = &splitIt($sequence[$x]);
                                  # if pad is fixed within splitIt()
}
print $tmp_seq;  #important line  # tmp sequence contains the cleaned .ace file, fasta formatted 

sub pad {
    my ($name) = @_;              # $name contains sequence name
    my $hyphens;
    $name =~ s/>//;
    my $num = $names{$name} - 1;  # $num == number of padding chars to apply
    for(my $x = 0; $x < $num; $x++){
	$hyphens .= '-';
    }
    return $hyphens;       
}                       
                                       # each $elem contains the following:
                                       # > Be500736 616 0 0
                                       # cccctcgcaccttccggcgaatcaccgcacctctccccggcgaag
	                               # gcccccaaggcggagaagaagccggctgccg ... etc
sub splitIt {                # splits ID line and sequence string, and applies padding to seq. str 
    my ($elem) = @_;         # @sequence is passed in
    my @ID;
    my @arr = split(/\n/,$elem,2);       # split along space  # > BE11111 151 0 0  
    $arr[1] =~ tr/a-z/A-Z/;              # change case
    $arr[1] =~ s/\*/-/g;                 # * becomes -, globally
    #print "$arr[1]\n";                  # debug
    @ID = split(/\s/,$arr[0]);           # @ID == ID line,split on space,  
    $arr[0] = $ID[0].$ID[1];             # $arr[0] ==   >ID12345
    $arr[1] = pad($arr[0]) . $arr[1];    # prepend dashes onto sequence  
    #print $arr[0],"\n";
    $tmp_seq .= $arr[0] . "\n";
    $tmp_seq .= &printLine($arr[1],70);  # format line to 70 chars
    #print $arr[1];  #this works         # want to print lines of 60 chars ..make a fnct()
    return @arr;                         # use outputFile()         
}

sub printLine {
    my ($string,$linelength) = @_;
    my $newString;
    my $count=0;
    $string =~ s/\n//g; #clean string
    my @chars = split(/ */,$string); 
    my $size = $#chars + 1;
    for(my $x=0; $x<$size; $x++){
	$count++;
	$newString .= $chars[$x];
	#print $chars[$x];
	if(($count%$linelength) == 0){ # A modulo B == 0 on multiples of B
	    $newString .= "\n";
	}
    }
    $newString .= "\n";
    return $newString;
}

sub cleanIt {                          # strip off the QA line in each record
    my (@seq) = @_;
    my  @arr;
    my $count; 
    #foreach (@seq){
	#$_ =~ tr/a-z/A-Z/;             # translate lower case to upper aug21 disable case translate
	#$_ =~ s/\*/-/g;               # gap symbol "*" becomes "-" ..21aug enable this...
	#}
    foreach(@seq){
	@arr = split(/QA/,$_);
	$seq[$count++] = $arr[0] ;     # @seq[n] gets just $arr[0]..which is:
	                               # > Be500736 616 0 0
                                       # cccctcgcaccttccggcgaatcaccgcacctctccccggcgaag
	                               # gcccccaaggcggagaagaagccggctgccg ... etc
	#print "$arr[0]\n";  #debug
    }   
    return @seq;
}
# foreach $key (keys(%names)) { print "$key - $names{$key}";  }  # ID & starting position
sub remTop {                           # puts ID + seq into array
    my ($file) = @_;                   #$tmp1 is entire record
    my @seqs = split(/RD/,$file);      # split off useless 1'st section of file 
    #my @tmp2;   # get tail end of first section
    shift @seqs;
    foreach(@seqs){
	$_ = '>' . $_;
    }
    return @seqs;                            # each element of @seq contains RD ... QA
}

sub nameArr() {                             # AF BF428706 U 55
    my @line = split(/ /, $_);              # split on empty space
    $names{$line[1]} = $line[3];            # { BE1234 25, BA2345 30, etc..}
    #print "name count:",$namecount++,",";
    # return $names;                  
}
# unused, but useful
sub length() {  # CO Contig1 776 27 0 U
    my @line = split(/ /, $_);              # split on empty space
    return $line[2];
    }

sub printLine2 { # an interesting function! look into this..
    my ($string,$lineLnth) = @_;
    my @chars = unpack("A1" x length($string),$string);
    my $size = $#chars;
    for(my $x=0; $x<$size; $x++){
	    print $chars[$x];
    }
}

sub outputFile { # create a .fasta formatted output file in ace_images
    my ($content) = @_;
}


