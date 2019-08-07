#!/usr/bin/perl

use warnings;
use strict;
use Bio::SearchIO;
my $blastFile = shift(@ARGV);
my $outname = shift(@ARGV);
my $pv_cutoff = shift(@ARGV);

my $blastfile        = $_[0];
my $parseoutfile     = $outname;
#my $pv_cutoff        = 1e-10;

open (PARSEOUT,">$parseoutfile");
print STDERR "\nParsing blast result!\n";
#write_log("\nParsing blast result!\n");
my $searchio = Bio::SearchIO->new(-file   => $blastFile,  -format => 'blast') or dieWithUnexpectedError("Blast parsing failed!");
my $similarityid=1;
print "Starting blast query\n";

open (INBLAST,"< $blastFile");
while (my $result = <INBLAST>)
{
	#print $result,"\n";
	chomp $result;
	my @splitty = split("\t",$result);
	my $queryid = $splitty[0];
	my $subjectid = $splitty[1];
	my $querylen  = $splitty[3];
	my $subjectlen = $splitty[3];
	my $pvalue = $splitty[10];
	my $percentIdent = $splitty[2];
	my $qstart = $splitty[6];
	my $qstop = $splitty[7];
	my $substart = $splitty[8];
	my $substop = $splitty[9];
	
	$querylen = $qstop - $qstart;
	$subjectlen = $substop - $substart;
	my $simspan = "1:$qstart-$qstop:$substart-$substop.";
	
	if ($pvalue == 0) {$pvalue=1e-149;}
	print PARSEOUT "$similarityid;$queryid;$querylen;$subjectid;$subjectlen;$pvalue;$percentIdent;$simspan\n";
	#print "$similarityid;$queryid;$querylen;$subjectid;$subjectlen;$pvalue;$percentIdent;$simspan\n";
	$similarityid++;
}

=comment
while (my $result = $searchio->next_result()) {
        my $queryid=$result->query_name;
        my $querylen=$result->query_length;
	print $queryid,"is query ID\n";
        while( my $hit = $result->next_hit ) {
                next unless numeric_pvalue($hit->significance) < $pv_cutoff;
                my $subjectid=$hit->name;
                my $subjectlen=$hit->length;
                my $pvalue=numeric_pvalue($hit->significance);
                my ($pm,$pe);
                if ($pvalue==0) {$pm=0;$pe=0;}
                elsif ($pvalue=~/(\d+)e(\-\d+)/) {$pm=$1;$pe=$2;}
                my $simspanid=1;
                my $simspan='';
                my (@percentidentity,@hsplength);
                while( my $hsp = $hit->next_hsp ) {
                        my $querystart=$hsp->start('query');
                        my $queryend=$hsp->end('query');
                        my $subjectstart=$hsp->start('sbjct');
                        my $subjectend=$hsp->end('sbjct');
                        $percentidentity[$simspanid]=$hsp->percent_identity;
                        $hsplength[$simspanid]=$hsp->length('hit');
                        $simspan.="$simspanid:$querystart-$queryend:$subjectstart-$subjectend.";
                        $simspanid++;
                }
                my $sum_identical=0;
                my $sum_length=1;
                for (my $i=1;$i<$simspanid;$i++) {
                        $sum_identical+=$percentidentity[$i]*$hsplength[$i];
                        $sum_length+=$hsplength[$i];
                }
                my $percentIdent=int($sum_identical/$sum_length);
                #print PARSEOUT "$similarityid;$queryid;$querylen;$subjectid;$subjectlen;$pvalue;$percentIdent;$simspan\n";
		print "$similarityid;$queryid;$querylen;$subjectid;$subjectlen;$pvalue;$percentIdent;$simspan\n";
		$similarityid++;
        }
}
=cut

print STDERR "Parsing blast file finished\n";
#write_log("Parsing blast file finished\n");
close(PARSEOUT);


exit(1);

# Make pvalue numeric, used by subroutine blast_parse
# One Arguments:
# 1. String Variable: pvalue
# Last modified: 07/19/04
sub numeric_pvalue {
        my $p=$_[0];
        if ($p=~/^e-(\d+)/) {return "1e-".$1;}
        else {return $p}
} # numeric_pvalue

