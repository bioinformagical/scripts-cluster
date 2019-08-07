#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
#use Mysql;
use DBI;
#use DBI::mysql;

# This reads in  RPKM table and makes a new MYSQL table.

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $rpkmfile= $ARGV[0] or die "Feed me rpkm taBLE file ...";

my $totalreads = 0;
my %tshash;
my @conan;


#die("we made Ts hash...");

#Set up the SQL CONNECTION
my ($host) = "localhost";
my ($user)="gm";
my ($password)="gm";
my $db = "gmTranscripts";
my $col1 = "tsreads";
 
#CONNECT to DB
print "Starting DB connections:\n\n";
my $dsn = "dbi:mysql:$db:localhost:3306";
my $dbstore = DBI->connect($dsn, $user, $password) or die ("Failed to connect to",$host," $DBI::errstr \n") ;



#CREATE a new table in MySQL to insert data into
my $tablename = "rpkmBlastnE1";
####### HAS MANY ERRORS my $tablequery = "CREATE TABLE  $tablename ( giID VARCHAR(20), versionID  sequence TEXT NOT NULL, genename TEXT NOT NULL, HiFi1 INT NOT NULL,  HiFi2 INT NOT NULL, HiFi3 INT NOT NULL, OT30441 INT NOT NULL, OT30442 INT NOT NULL, OT30443 INT NOT NULL, OT30181 INT NOT NULL, OT30182 INT NOT NULL, OT30183 INT NOT NULL, 883041 INT NOT NULL, 883042 INT NOT NULL, 883043 INT NOT NULL, Leggett1 INT NOT NULL, Leggett2 INT NOT NULL, Leggett3 INT NOT NULL, Marion1 INT NOT NULL, Marion2 INT NOT NULL, Marion3 INT NOT NULL, A_strigosa1 INT NOT NULL, A_strigosa2 INT NOT NULL, A_strigosa3 INT NOT NULL, Bam_49_21 INT NOT NULL, Bam_49_22 INT NOT NULL, Bam_49_23 INT NOT NULL, Syn_Hexaploid1 INT NOT NULL, Syn_Hexaploid2 INT NOT NULL, Syn_Hexaploid3 INT NOT NULL, CM11 INT NOT NULL, CM12 INT NOT NULL, CM13 INT NOT NULL, CM1_WT1 INT NOT NULL, CM1_WT2 INT NOT NULL, CM1_WT3 INT NOT NULL, CONSTRAINT  pk_giid PRIMARY KEY (giID))" ;
#my $tablequery_handle = $dbstore->prepare($tablequery) or die("PREPARE FAIL: $DBI::errstr");
#$tablequery_handle->execute() or die("EXECUTE FAIL: $DBI::errstr");
#print $tablequery,"\n";      
#$tablequery_handle->finish();



#READ IN READS FILE and get total sum of reads
open(READS, $rpkmfile) or die "can't read reads file";

while (my $line = <READS>)
{       
      chomp $line;
      my @fields = split('\t', $line);
      my @title = split('\|',$fields[0]);
      my $giid = $title[1];
      my $versionid = $title[3];
      my $genename = $fields[1];

#print "gi: ", $giid,"\n";
#print "Version: ", $versionid,"\n";
#print "geneName: ", $genename,"\n";
#print " 1st RPKM value:",$fields[2],"\n";

#die(" A horribe deathhh");

	 #  print " Total reads is now ",$totalreads," after adding ",$fields[1],"\n";
	
	#PREPARE (bring out yer dead)
my $query = "INSERT into $tablename( giID, versionID, genename, HiFi1, HiFi2, HiFi3, OT30441, OT30442, OT30443, OT30181, OT30182, OT30183, `883041`, `883042`, `883043`, Leggett1, Leggett2, Leggett3, Marion1, Marion2, Marion3, A_strigosa1, A_strigosa2, A_strigosa3, Bam_49_21, Bam_49_22, Bam_49_23, Syn_Hexaploid1,  Syn_Hexaploid2, Syn_Hexaploid3, CM11, CM12, CM13, CM1_WT1, CM1_WT2, CM1_WT3) VALUES ($giid,\'$versionid\',\'$genename\',$fields[2],$fields[3],$fields[4],$fields[5],$fields[6],$fields[7],$fields[8],$fields[9],$fields[10],$fields[11],$fields[12],$fields[13],$fields[14],$fields[15],$fields[16],$fields[17],$fields[18],$fields[19],$fields[20],$fields[21],$fields[22],$fields[23],$fields[24],$fields[25],$fields[26],$fields[27],$fields[28],$fields[29],$fields[30],$fields[31],$fields[32],$fields[33],$fields[34])";
	my $query_handle = $dbstore->prepare($query) or die("PREPARE FAIL: $DBI::errstr");
	$query_handle->execute() or die("EXECUTE FAIL: $DBI::errstr");
	print $query,"\n";	
	$query_handle->finish();
}

#die(" we read ts hash and total reads");



#READIN QUERY
#my @data;
#while (@data = $query_handle->fetchrow_array())
#{
#	my $sid = $data[0];
#	my $seq = $data[1];
#	my $tsread = $data[2];
#	print "Success getting query:",$sid,"\t",$seq,"\t reads = ",$tsread,"\n"
#}


#$query_handle->finish();


print "All Done, we made it to the end.\n"; 



close(READS);
#close(MASTER);
#close(OUTFILE);
$dbstore->disconnect();
#$connect->disconnect();
exit(0);


sub calcrpkm
{
	if (@_ != 3) {die ("Wrong number of args for RPKM calulator method");}
	#	print " We are in RPKM !!\n";
	my $read = $_[0];
	 my $tslength = $_[1]/1000;
	 my $totalreads = $_[2]/1000000;
	
	 my $a = $read/$tslength;
	 my $b = $a/$totalreads;
	 $b;
	# my $a = (10**9*$read)/($tslength*$totalreads);
}


