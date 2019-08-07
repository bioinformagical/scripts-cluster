#!/usr/bin/perl


# This reads in the master table, check each description for an "=" sign and provides only 1 hit for each similar desc.

$numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 3 arguments, mastertablefile parsedtable Column\#");
}


my $masterfile= $ARGV[0] or die "MASTER TABLE FILTER \n I need a master table file with the 33 columns for the read numbers. \n";

#my $filename1 = $masterfile.".master.table".$column;
open (OUTFILE, ">$masterfile"."-byEqualSign.trimmed") or die $!; 

open(MASTER, $masterfile) or die "can't read master";

# A hash that holds the id (key) and desc (value)
my %deschash ;
# hash that holds the 33 readnum array
my %array33hash;
# a hash to hold the short desc.
my %shorthash;

while (my $line = <MASTER>)
{
	chomp $line;
	
	my @fields = split('\t', $line);
	if (defined $fields[0] and  defined $fields[34])
	{
	
		#my @shortdesc = split("=",$fields[1]);
		my @shortdesc = split("=",$fields[1]);
		#my @shortdesc = split(" ",$fields[1]);
		#my $newdesc = $shortdesc[0]," ",$shortdesc[1]," ",$shortdesc[2]," ",$shortdesc[3]," ",$shortdesc[4]," ",$shortdesc[5];
		#my $newdesc = $shortdesc[0]." ".$shortdesc[1]," ",$shortdesc[2]," ",$shortdesc[3];
		my $newdesc = $shortdesc[0];
		chomp $newdesc;
		$newdesc = substr($newdesc,0,16);
		
		#chomp $newdesc;

		$deschash{$fields[0]} = $fields[1];
		
		#if (exists $shorthash{$shortdesc[0]})
		if (exists $shorthash{$newdesc})

		{
			#print " Exists !!", $newdesc, "\n";
		}
		else
		{
			$shorthash{$newdesc} = $fields[0];
		}
#	print $deschash{$fields[0]},"\n";
#	print  $fields[0], "\t",$fields[1], "\t", $fields[34], "\n";
		my @array33;
		for($i = 2; $i < 35; $i++)
		{
			my $j = $i -2;
			$array33[$j] = $fields[$i];
			# print $array33[$i],"\t";	
		}
		$array33hash{$fields[0]} = \@array33;
		
		#my $pline = $fields[0]."\t".$deschash{$fields[0]};
		#chomp $pline;
		         #print $pline,"\n";
		         #my @temparray = $array33hash{$key};
		        #print $temparray[0],"was zeroth, \t",$temparray[4],"was fourth\t",$temparray[32],"was last \n";
		        #print $array33hash{$key}[4]," was from our hash \n";   
			#for($i = 0; $i < 33; $i++)
			#{
			# my $colvalue = $array33hash{$fields[0]}[$i];
			#	$pline = $pline."\t".$colvalue;
			                 #my $gsize =  scalar($array33hash{$key});
			                 #print "Size of MASTERTABLE hash is ", $gsize,"\n";
			                 #print $array33hash{$key}[4]," was array. \n";
					 #}
					 #print $pline,"\n";


		#	print "\n";
	}	


	else {  die("Our master table file, lacked the 35 columns needed : ",$masterfile,"\t",@fields); }
}
my $size = scalar(keys %array33hash);
my $smallsize = scalar(keys %shorthash); 
print "Size of MASTERTABLE hash is ", $size," and deschash is ",scalar(keys %deschash),"\n";
print "Size of Small hashTABLE hash is ", $smallsize,"\n";
#die("Carwash");



#print out master table
#
#


foreach my $key (keys(%shorthash)) 
{
	my $acc =  $shorthash{$key}; 
	my $pline;
	if (exists $deschash{$acc})
	{
		#print $deschash{$acc},"\n";	
	       	$pline = $acc."\t".$deschash{$acc};	
	}
	else
	{
		die("Our acc was not in the deschash !!! ",$acc);
	}
	#$pline = $acc,"\t",$deschash{$acc};
	 #chomp $pline;
#	print $pline,"\n";
	#my @temparray = $array33hash{$key};
	#print $temparray[0],"was zeroth, \t",$temparray[4],"was fourth\t",$temparray[32],"was last \n";
	#print $array33hash{$key}[4]," was from our hash \n";	
	 for($i = 0; $i < 34; $i++)
	 {
		my $colvalue = $array33hash{$acc}[$i];
		$pline = $pline."\t".$colvalue;
		#my $gsize =  scalar($array33hash{$key});
		#print "Size of MASTERTABLE hash is ", $gsize,"\n";
		#print $array33hash{$key}[4]," was array. \n";
	 }
#	  print $pline,"\n";
	
	 print OUTFILE $pline,"\n";     
}
	    
        print "All Done, we made it to the end.\n"; 

close(OUTFILE);
close(MASTER);
exit;





