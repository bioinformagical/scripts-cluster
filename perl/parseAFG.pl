#!/usr/bin/perl

#Complement of Dr. G. 

use strict;
use warnings;
use lib "/lustre/sw/amos/3.0.1/lib";
use AMOS::AmosLib;

my $file =  $ARGV[0] or die "I need AFG (.afg) file\n";

my $rFile= $file . ".readCounts.txt";
my $sFile= $file . ".contigSeq.fasta";

open( OUTO, ">$rFile" ) or die $!;
open( OUTT, ">$sFile" ) or die $!;

open(AFG, $file) or die $!;


while (my $record = getRecord(\*AFG))
{
my ($a, $b, $c) = parseRecord($record);	
	if($a eq "CTG")
		{
			my $rNum = 0;
			
			for(my $i = 0; $i <= $#$c; $i++)
			{
				
				my ($d, $e, $f) = parseRecord($$c[$i]);
					if($d eq "TLE")
						{
							++$rNum;
							#	warn "WHOS YOUR DADDY!\n\n";
						}
			}

		print OUTO $$b{iid}, "\t", $rNum, "\n";
		print OUTT ">", $$b{iid}, "\n", $$b{seq};
		
		}

}

close(AFG) or die $!;
close(OUTO) or die $!;
close(OUTT) or die $!;

exit
