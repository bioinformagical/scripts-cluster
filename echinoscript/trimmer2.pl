#!/usr/bin/perl

open(FILE, $ARGV[0]) || die("Could not open file! Is the path and name correct? To run this program type: perl trimmer.pl <name of input file>\n");
@data=<FILE>;
open(OUT,">$ARGV[0]_trimmed") || die("Cannot Open File");
print "Writing trimmed output to file $ARGV[0]_trimmed\n";
$samplename = "";
$concatline = "";
$sequence_length = 0;
%sample_seq;
%sample_seq_rev;
$first_sample = "";
my %pos_count;  #the pos count hash
my %pos_count_rev;

loadFileToHash();

processAlignments();
#processAlignmentsBegEnd();
close(OUT);
close(FILE);	
#EOP

########################## ROUTINES ####################
sub loadFileToHashReverse() {

	foreach $line (@data)
	{
        	chomp($line);
#       	#print "processing new line with length".length($line)." $line\n";
        	my $pos1 = substr($line,0,1);
        	if ($pos1 eq "#") {
                	if ((length($concatline)) <  1) {
                        	$samplename = $line;
                        	if (length($first_sample)==0) {
                                	$first_sample = $samplename;
                        	}
                	}
               		 elsif(length $concatline > 0) {
                        	$rconcatline = reverse($concatline);
                        	$sample_seq{$samplename} = $rconcatline;
                        	$concatline = "";
                        	$samplename = $line;
                        	$rconcatline = "";
                	}
        	}
		else {
                	$concatline =$concatline.$line;
        	}

		#"add last sample to hash\n "
		$rconcatline = reverse($concatline);
		$sample_seq{$samplename} = $rconcatline;
		$sequence_length = length($rconcatline);
		$sample_count  = scalar keys %sample_seq;
	}
}

#This subroutine will load the file into a hash table with samplename and sequence as key/value.
sub loadFileToHash() {
	
	#print "In loadFileToHash()\n";
	foreach $line (@data)
        {
                chomp($line);
#               print "processing new line with length".length($line)." $line\n";
                my $pos1 = substr($line,0,1);
                if ($pos1 eq "#") {
                        if ((length($concatline)) <  1) {
                                $samplename = $line;
                                if (length($first_sample)==0) {
                                        $first_sample = $samplename;
                                }
                        }
                         elsif(length $concatline > 0) {
                                $sample_seq{$samplename} = $concatline;
                                $sample_seq_rev{$samplename} = reverse($concatline);
				$concatline = "";
                                $samplename = $line;
                                $concatline = "";
                        }
                }
                else {
                        $concatline =$concatline.$line;
                }
	}
	
       #"add last sample to hash\n "
        $sample_seq{$samplename} = $concatline;
        $sample_seq_rev{$samplename} = reverse($concatline);
	$sequence_length = length($concatline);
        $sample_count  = scalar keys %sample_seq;
        print "Sequence length is $sequence_length and number of samples is $sample_count\n";
}

#main method to process each sequence and find trimming locations on each end.
sub processAlignments() {

	for ( $i=0; $i<$sequence_length; $i++)
	{
		my $match_depth = scanSequencesByPos($i);
		$pos_count{$i} = $match_depth;	
	}
	
	my $highkey = findHighestCardinalityMatch(true);
	for ( $r=0; $r<$sequence_length; $r++)
        {
                my $match_depth_rev = scanSequencesByPosRev($r);
                $pos_count_rev{$r} = $match_depth_rev;
        }

        my $highkey_rev = findHighestCardinalityMatch(false);
	
	printTrimmedAlignment($highkey, $highkey_rev);
}

# main sub routine that scans all sequences by given position.
sub scanSequencesByPos() {
	my $pos = $_[0];
	my $count = 0;

	 while (($sample, $sequence) = each(%sample_seq)) {
		my $base1 = getBase($sequence, $pos);
		if ($base1 ne "-") {
			$count++;
		}
	}

	return $count;
}

# main sub routine that scans all sequences by given position.
sub scanSequencesByPosRev() {
        my $pos = $_[0];
        my $count = 0;

         while (($sample, $sequence) = each(%sample_seq_rev)) {
                my $base1 = getBase($sequence, $pos);
                if ($base1 ne "-") {
                        $count++;
                }
        }

        return $count;
}

#gets the base (i.e. char) at a particular location in the string.
sub getBase() {
        substr ($_[0], $_[1], 1);
}

#findHIghestValue will sort hash and return highest value. If more than one of equal val is found,
#then the first one will get it.
#key refers to position, value refers to number of matches or cardinatlity
sub findHighestCardinalityMatch()
{
	my $value = 0;
	my $key = 0;
	my $highvalue = 0;
	my $highkey = 0;
	my @pos_sorted;
	if ($_[0] eq true) {
		@pos_sorted = sort {$a <=> $b} keys(%pos_count);	
	
		foreach (@pos_sorted)  {
			$key = $_;
			$value = $pos_count{$key};
			if ($value > $highvalue) {
				$highvalue = $value;
				$highkey = $key;
			}
		}

		#print "Sequences trimmed at position ".$highkey." with a cardinality of $highvalue\n";
	}
	else {
		@pos_sorted = sort {$a <=> $b} keys(%pos_count_rev);

                foreach (@pos_sorted)  {
                        $key = $_;
                        $value = $pos_count_rev{$key};
			if ($value > $highvalue) {
                                $highvalue = $value;
                                $highkey = $key;
			}
                }
		
		#print "Sequences trimmed at highkey  $highkey with a highvalue of  $highvalue\n";
	}

        return $highkey;
}

#print will display the results of the trimming to an output file with the format
#sample name
#sequence (60 chars per line)
sub printTrimmedAlignment()
{
        my $highkey_beg = $_[0];
        my $highkey_end = $sequence_length - $_[1] - 1;

	#print "printTrimmedAlignment $highkey_beg to $highkey_end\n";
		
	#first sample this is done because the first sample in the resulting file must match the first sample in the input file. The remainder of files order doesn't matter.
	my $first_sequence = $sample_seq{$first_sample};
 	printSequence($first_sample, $first_sequence, $highkey_beg, $highkey_end);	
	
        while (($sample, $value)=each(%sample_seq)) {
		if ($sample ne $first_sample) {
			printSequence($sample, $value, $highkey_beg, $highkey_end);
		}
        }
}


#prints only the sequence formatted for RAXML input. 
sub printSequence() {
	my $sample = $_[0];
	my $value = $_[1];
	my $highkey_start = $_[2];
	my $highkey_end = $_[3];
	
	print OUT "$sample\n";
	$value = substr($value,  $highkey_start, $highkey_end-$highkey_start);

        #chop value in lines of 60
        for ($i=0; $i<length($value); $i+60) {
       		print OUT substr($value,$i,60)."\n";
        	$i = $i + 60;
         }
}
