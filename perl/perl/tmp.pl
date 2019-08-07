#!/usr/bin/perl

use strict;
use warnings;

my $str = "AAGGCTATCCCCCCCGGAGAGAGAGAGAGAGAGAGTTTTTTGGGAGAGA";

if ($str =~ /(T{6,})/ and length $1 == 6)
{
	
	print "we found 6 C\n$1\n";
}


my @numbers = (10.22,20.33,22.3,11.3,12.4,8.3,10.4);
printf "Percentile %d%% at %f\n", $_, percentile($_,\@numbers)
for qw/25 50 75 90 95 99/;
sub percentile {
my ($p,$aref) = @_;
my $percentile = int($p * $#{$aref}/100);
return (sort @$aref)[$percentile];
}



#else
#{
#	print " no luck bud\n";
#}

#if ($str =~ /[ACGT]{10,10}/)
#{
#         print "we found 6 of something\n";
#}  
