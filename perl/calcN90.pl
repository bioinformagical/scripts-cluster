#/usr/bin/perl -w
use strict;
my ($len,$total)=(0,0);
my @x;
while(<>){
if(/^[\>\@]/){
if($len>0){
	$total+=$len;
	push @x,$len;
}
$len=0;
}
else{
	s/\s//g;
	$len+=length($_);
}
}
if ($len>0){
	$total+=$len;
	push @x,$len;
}
@x=sort{$b<=>$a} @x; 
my ($count,$half,$ten,$twenty,$thirty,$fourty,$sixty,$seventy,$eighty)=(0,0,0,0,0,0,0,0,0);
my $count50=0;
for (my $j=0;$j<@x;$j++){
	$count+=$x[$j];
	if (($count>=$total*.1)&&($ten==0)){
		print "N10: $x[$j]\n";
		$ten=$x[$j]
        }elsif (($count>=$total*.2)&&($twenty==0)){
                print "N20: $x[$j]\n";
                $twenty=$x[$j]
        }elsif (($count>=$total*.3)&&($thirty==0)){
		print "N30: $x[$j]\n";
		$thirty=$x[$j]
	}elsif (($count>=$total*.4)&&($fourty==0)){
		print "N40: $x[$j]\n";
		$fourty=$x[$j]
	}elsif (($count>=$total/2)&&($half==0)){
		print "N50: $x[$j]\n";
		$half=$x[$j]
	}elsif (($count>=$total*.6)&&($sixty==0)){
		print "N60: $x[$j]\n";
		$sixty=$x[$j]
	}elsif (($count>=$total*.7)&&($seventy==0)){
		print "N70: $x[$j]\n";
		$seventy=$x[$j]
	}elsif (($count>=$total*.8)&&($eighty==0)){
		print "N80: $x[$j]\n";
		$eighty=$x[$j]
	}elsif ($count>=$total*0.9){
		print "N90: $x[$j]\n";
		exit;
	}else{
		if ($count%500==0){
		#	print "$x[$j]\n";
		}
	}
}
