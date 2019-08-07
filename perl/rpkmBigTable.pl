#!/usr/bin/perl


# This reads in blasted table results and the fimal table, of which the blasted table get appended to.

$numargs = $#ARGV + 1;
if ($numargs != 3)
{
	die("We did not get 3 arguments, mastertablefile parsedtable Column\#");
}


my $masterfile= $ARGV[0] or die "TABLE BUILDER \n I need a table file with the 33 columns for the read numbers. \n";
my $parsedxmlfile=$ARGV[1] or die "TABLE BUILDER \n I need a parsed blast result table file to add to the other file. \n";
open(XML, $parsedxmlfile) || die("no such xmled table file");
my $column = $ARGV[2] or die "Need to identify the column number the parsed table goes to";
$column--;

#my $filename1 = $masterfile.".master.table".$column;
open (OUTFILE, ">masterfile") or die $!; 

open(MASTER, $masterfile) or die "can't read master";

# A hash that holds the id (key) and desc (value)
my %deschash ;
# hash that holds the 33 readnum array
my %array33hash;

while (my $line = <MASTER>)
{
	chomp $line;
	
	my @fields = split('\t', $line);
	if (defined $fields[0] and  defined $fields[34])
	{
		$deschash{$fields[0]} = $fields[1];
		#print  $fields[0], "\t",$fields[1], "\t", $fields[34], "\n";
		my @array33;
		for($i = 2; $i < 35; $i++)
		{
			my $j = $i -2;
			$array33[$j] = $fields[$i];
			# print $array33[$i],"\t";	
		}
		$array33hash{$fields[0]} = \@array33;
		
		my $pline = $fields[0]."\t".$deschash{$fields[0]};
		chomp $pline;
		         #print $pline,"\n";
		         #my @temparray = $array33hash{$key};
		        #print $temparray[0],"was zeroth, \t",$temparray[4],"was fourth\t",$temparray[32],"was last \n";
		        #print $array33hash{$key}[4]," was from our hash \n";   
		for($i = 0; $i < 33; $i++)
		{
		      my $colvalue = $array33hash{$fields[0]}[$i];
			$pline = $pline."\t".$colvalue;
			                 #my $gsize =  scalar($array33hash{$key});
			                 #print "Size of MASTERTABLE hash is ", $gsize,"\n";
			                 #print $array33hash{$key}[4]," was array. \n";
		 }
		print $pline,"\n";


		#	print "\n";
	}	


	else {  die("Our master table file, lacked the 35 columns needed !",@fields); }
}
#my $size = scalar(keys %array33hash);
#print "Size of MASTERTABLE hash is ", $size," and deschash is ",scalar(keys %deschash),"\n";
#die("Carwash");



#Iterate through parsed xml table and either add a new entry the master table OR update the master table's array.
while (my $line = <XML>)
{
	chomp $line;
	my @fields = split('\t', $line);
	#print $line,"\n";
	my $id = $fields[0];
	my $desc = $fields[1];
	my $rpkm = $fields[5];
	#print  $id, "\t",$desc,"\t", $readnum, "\n";

	#check if already exists in MASTERTABLE
	 if (exists $array33hash{$id})
	 {
		 #print "we are in exisitng hash for ",$id,"\n";
	 	 #my @tempfo ; #= @array33hash{$id}; # a temp hash
		for($i = 0; $i < 33; $i++)
		{
			$tempfo[$i] = ${ array33hash{$id}[$i]};
			#if ($i == $column) {$temp[$column] = $readnum; print"yay\n"; }
			#		print $tempfo[$i],"\n";

		}
		
		 #print "My column num is ",$column, " and the value is ",$readnum,"\n"; 
		 $tempfo[$column] = $rpkm; # column corresponding to file that came in, is updated.
		$array33hash{$id}[$column] = $rpkm; # \@tempfo; # Update the master hash
		#print $array33hash{$id}[4]," 4 was array. \n";
		#print $array33hash{$id}[0]," 0 was array. \n";
		#print $array33hash{$key}[32]," 33 was array. \n";
	 }
	 else
	 {
		my @temp = ();
		for($i = 0; $i < 33; $i++) 
		{
			push(@temp, "0");
		}
		$temp[$column] = $rpkm; # column corresponding to file that came in, is updated.
		#print "\n",$temp[34],"\n";
		$array33hash{$id} = \@temp; # Update the master hash
		$deschash{$id} = $desc;
		#print $array33hash{$id}[4]," was from our hash \n";
	 }
}

#die(" Salad Fingers");




#print out master table
#
#
open (OUTFILE, ">$masterfile") or die $!; 


foreach my $key (keys(%deschash)) 
{
	my $pline = $key."\t".$deschash{$key};
	chomp $pline;
	#print $pline,"\n";
	#my @temparray = $array33hash{$key};
	#print $temparray[0],"was zeroth, \t",$temparray[4],"was fourth\t",$temparray[32],"was last \n";
	#print $array33hash{$key}[4]," was from our hash \n";	
	 for($i = 0; $i < 33; $i++)
	 {
		my $colvalue = $array33hash{$key}[$i];
		$pline = $pline."\t".$colvalue;
		#my $gsize =  scalar($array33hash{$key});
		#print "Size of MASTERTABLE hash is ", $gsize,"\n";
		#print $array33hash{$key}[4]," was array. \n";
	 }
	 print $pline,"\n";
	
	print OUTFILE $pline,"\n";     
}
	    


        print "All Done, we made it to the end.\n"; 

close(OUTFILE);
close(MASTER);
close(XML);
exit;





