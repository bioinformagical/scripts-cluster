#!/usr/bin/perl


# This reads in 3 oat rnaseq parent parsed blast tables.
#	The 1st table will get hashed and each GI entry will be applied to A) it's desc. B) refseqID C) array of refseq RSEM scores.
#
#	end table will look like
#	
#	GI-ID	GI-desc	GS7score	Provenascore	BAM004score
#	
#
#
#



$numargs = $#ARGV + 1;
if ($numargs != 3)
{
	die("We did not get 3 arguments, mastertablefile parsedtable Column\#");
}

my $firstfile= $ARGV[0] or die "TABLE BUILDER \n  MUST Gs7   I need a table file for the read numbers. \n";
my $secondfile=$ARGV[1] or die "TABLE BUILDER \n MUST be Provena.  I need a parsed blast result table file to add to the other file. \n";
my $thirdfile=$ARGV[2] or die "TABLE BUILDER \n MUST be BAm004.   I need a parsed blast result table file to add to the other file. \n";

#my $filename1 = $masterfile.".master.table".$column;
open (OUTFILE, ">$firstfile.masterfile.txt") or die $!; 
print OUTFile "NCBI-ID\tNCBI-desc\tGS7-RSEMscore\tProvena-RSEMscore\tBAM004-RSEMscore\n";

open(FIRST, $firstfile) or die "can't read master";

# A hash that holds the id (key) and desc (value)
my %deschash ;
# hash that holds the 3 score arrays from each parent
my %arrayhash;

while (my $line = <FIRST>)
{
	chomp $line;
	
	my @fields = split('\t', $line);
	if (defined $fields[0] and  defined $fields[3])
	{
		$deschash{$fields[0]} = $fields[1];
		#print  $fields[0], "\t",$fields[1], "\t", $fields[3], "\n";
		my @array3=($fields[3],0,0);
		
				
		$deschash{$fields[0]} = $fields[1];
			# print $array33[$i],"\t";	
		
		$arrayhash{$fields[0]} = \@array3;
	}	
	else {  die("Our master table file, lacked the 4 columns needed !",@fields); }
}
my $size = scalar(keys %arrayhash);
print "Size of array hash is ", $size," and deschash is ",scalar(keys %deschash),"\n";
#die("Carwash");


 open(SECOND, $secondfile) or die "can't read Provena";

#Iterate through parsed xml table and either add a new entry the master table OR update the master table's array.
while (my $line = <SECOND>)
{
	chomp $line;
	my @fields = split('\t', $line);
	#print $line,"\n";
	my $id = $fields[0];
	my $desc = $fields[1];
	my $readnum = $fields[3];
	#print  $id, "\t",$desc,"\t", $readnum, "\n";

	#check if already exists in MASTERTABLE
	 if (exists $arrayhash{$id})
	 {
		#my $firstval = $deschash{$id}[0];	
		$arrayhash{$id}[1]=$readnum;

		#print "we are in exisitng hash for ",$id," and the array is :", $deschash{$id}, "\n";
	 }
	 else
	 {
		my @array3=(0,$fields[3],0);
                
                
                $deschash{$fields[0]} = $fields[1];
                        # print $array33[$i],"\t";      
               $arrayhash{$fields[0]} = \@array3;
	 }
}

#die(" Salad Fingers");

##############   Add 3rd column now for BAM004   ################
open(THIRD, $thirdfile) or die "can't read BAM004";

#Iterate through parsed xml table and either add a new entry the master table OR update the master table's array.
while (my $line = <THIRD>)
{       
        chomp $line;
        my @fields = split('\t', $line);
        #print $line,"\n";
        my $id = $fields[0];
        my $desc = $fields[1];
        my $readnum = $fields[3];
        #print  $id, "\t",$desc,"\t", $readnum, "\n";

        #check if already exists in MASTERTABLE
        if (exists $arrayhash{$id})
         {
                 
                $arrayhash{$id}[2]=$readnum;
                 
                #print "we are in exisitng hash for ",$id," and the array is :", $deschash{$id}, "\n";
         }      
         else   
         {
                my @array3=(0,0,$fields[3]);
                
                
                $deschash{$fields[0]} = $fields[1];
                       # print $array33[$i],"\t";      
               $arrayhash{$fields[0]} = \@array3;
         }     
}        
 
#die(" Salad Fingers");


#print out master table
#
#
foreach my $key (keys(%deschash)) 
{
	my $pline = $key."\t".$deschash{$key}."\t".$arrayhash{$key}[0]."\t".$arrayhash{$key}[1]."\t".$arrayhash{$key}[2];
	chomp $pline;
	#print $pline,"\n";
	#print $pline,"\n";
	
	print OUTFILE $pline,"\n";     
}
	    


        print "All Done, we made it to the end.\n"; 

close(OUTFILE);
close(FIRST);
close(SECOND);
close(THIRD);
exit;





