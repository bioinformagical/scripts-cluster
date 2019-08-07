#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::SimpleAlign;
use Bio::PrimarySeq;

# This reads in a text file ..
#Compares 1 sequence to the next. And reports back the the line + # of matching characters and a percent identity. 
#
#

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 2 arguments, All YOUR BASE ARE BELONG TO US\#");
}

my $tfile= $ARGV[0] or die "Feed me ortho fasta file with refseq in the header name ...";

 open OUTFILE, ">$tfile-perc.txt" or die "No open outfile" ;

my $totalcount=0;
my $prime1count=0;
my $prime2count=0;
my $qcount=0;

#Parse Ts file 
open (TSFILE, $tfile) or die $!;
my $header = <TSFILE>;
$header=$header."\t\tprimer1-100%Match\tprimer2-100%match\t%Identity-InfiniumDesign\n";
while (my $line = <TSFILE>)
{
	chomp $line;
	my @ray = split("\t",$line);
	#print $ray[2],"\n";
	my $target = $ray[0];
	my $queery = $ray[2];
	my $primer1 = $ray[5];
	my $primer2 = $ray[7];
	chomp $target; chomp $queery;
	$target =~ s/\s//g;	
	$queery =~ s/\s//g;
	my $seq1 = Bio::PrimarySeq->new( -seq => $target, -alphabet => 'dna' ); 
	my $seq2 = Bio::PrimarySeq->new( -seq => $queery,  -alphabet => 'dna' );
	my $primseq1 = Bio::PrimarySeq->new( -seq => $primer1, -alphabet => 'dna' );
	my $primseq2 = Bio::PrimarySeq->new( -seq => $primer2, -alphabet => 'dna' );

	my $aln = new Bio::SimpleAlign();
#	$aln->add_seq($seq1);
	

	if ($target =~ m/$primer1/)
	{
		$prime1count++;
		print OUTFILE $line,"\t","TRUE";
#		print "we found a match for ",$primer1,"\n";
	}
	else
	{
		print OUTFILE $line,"\t","FALSE";
	}
	$primer2 = &reverse_complement($primer2);
	if ($target =~ m/$primer2/)
        {
                $prime2count++;
		print OUTFILE "\t","TRUE\t";
      #          print "we found a match for ",$primer2,"\n";
        }
	else
	{
		print OUTFILE "\t","FALSE\t";
	}

	#my $factory = Bio::Tools::StandAloneBlast->new('program' => 'blastn', 'outfile' => 'bl2seq.out');
   	#my $bl2seq_report = $factory->bl2seq($target, $queery);
	open O1FILE, ">tmp1.fna" or die "No open outfile" ;
	open O2FILE, ">tmp2.fna" or die "No open outfile" ;	
	print O1FILE ">t1\n",$target,"\n";
	print O2FILE ">t2\n",$queery,"\n";

	my $cmd = "blastn -subject tmp1.fna -query tmp2.fna -outfmt 6 | cut -f 3";    
	#print $cmd."\n";
	my @output = `$cmd`;    
	chomp @output;
        #system("blastn -subject  -query tmp2.fna -outfmt 6 | cut -f 3");
	# Use AlignIO.pm to create a SimpleAlign object from the bl2seq report
   	#my $str = Bio::AlignIO->new(-file=> 'bl2seq.out','-format' => 'bl2seq');
   	#my $aln = $str->next_aln();
	my $percidentity = $output[0];
	#print "Hooray we found the percent ID of ",$output[0],"\n";

	print OUTFILE $percidentity,"\n";	
	$totalcount++;
	close(O1FILE);
	close(O1FILE);
}

print "Primecount1 =",$prime1count,"\n";
print "Primecount2 =",$prime2count,"\n";
print "total count = ",$totalcount,"\n";

#my $count = 0;
#y %tshash;
#my @conan;


#my $foo = new Bio::SeqIO (-file=>$fastafile, -format=>'fasta');

#while (my $seq = $foo->next_seq)

#	my $sid = $seq->display_id;
#	my @sidname = split("-",$sid);
#	print OUTFILE ">",$sidname[0],"@",$sidname[1],"\n";

 print "All Done, we made it to the end.\n"; 

close(TSFILE);
close(OUTFILE);
exit;

sub reverse_complement 
{
        my $dna = shift;

	# reverse the DNA sequence
        my $revcomp = reverse($dna);

	# complement the reversed DNA sequence
        $revcomp =~ tr/ACGTacgt/TGCAtgca/;
        return $revcomp;
}

sub compare2strings
{
	my $s1 = shift;
	my $s2 = shift;
	my $bestscore = 0;
	
	
	my $shortest = length $s1;
	if (length $s2 < $shortest) {$shortest = length $s2;};
	
	my @arr1 = split("",$s1);
	my @arr2 = split("",$s2);
	print $arr1[0]," was the 1st letter\n";
	
		
	for(my $i =0; $i <$shortest; $i++)
	{
		if ($arr1[$i] eq $arr2[$i]) {$bestscore++;}
	}
	return $bestscore;
}
