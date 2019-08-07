#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
#use Mysql;
use DBI;
#use DBI::mysql;

# This reads in individual Blast output/RPKM tables and makes a new MYSQL table utilizing many other foreign keys......
# files input eg, jb3-e50blastnt.table 

my $numargs = $#ARGV + 1;
if ($numargs != 1)
{
	die("We did not get 1 arguments in the form foo-e50blastrpkm.table, All YOUR BASE ARE BELONG TO US\#");
}


my $rpkmfile= $ARGV[0] or die "Feed me oases.xml.parsede50.rpkm  taBLE file ...";

#READ IN READS FILE and get total sum of reads
open(RPKMTABLE, $rpkmfile) or die "can't read reads file";

my @trueid = split("-",$rpkmfile);
#my @trueid2 = split("/",$trueid[0]);
#print " File line is " , $rpkmfile,"\n\n";
#print " ID is ",$trueid2[5],"\n";

my $oatid = $trueid[0];  # 1st part of file name corresponding to condition type
#die ("my oat ID is dead",$trueid[0]);

my $totalreads = 0;
my %gihash;



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
my $tablename = $oatid."blastnE50rpkm";
print " Tablename is ",$tablename,"\n";
#die(" Got tablename");


my $tablequery = "CREATE TABLE  $tablename \ 
( \
transcriptID mediumint(8) unsigned, \
giID VARCHAR(20), \
trueID VARCHAR(15), \
readcount INT,	\
rpkm INT,	\
foreign key (transcriptID) references ".$oatid."tscriptread(seqid),	\
foreign key (giID) references rpkmBlastnE1(giID),	\
foreign key (trueID) references oatID(trueID),\
CONSTRAINT  pk_giid PRIMARY KEY (giID) \
)";

print $tablequery,"\n";
my $tablequery_handle = $dbstore->prepare($tablequery) or die("PREPARE FAIL: $DBI::errstr");
$tablequery_handle->execute() or die("EXECUTE FAIL: $DBI::errstr");
$tablequery_handle->finish();
#die ("passed create table");

while (my $line = <RPKMTABLE>)
{       
      chomp $line;
      my @fields = split('\t', $line);
      my @title = split('\|',$fields[0]);
      my $giid = $title[1];

	### Check if GI Hash has gi # already
	if (exists $gihash{$giid})
	{
		print "Found duplicate GI !!   ",$fields[1],"\n";
		next;
	}
	else
	{
		$gihash{$giid} = $fields[1];
	}

	my $versionid = $title[3];
      my $genename = $fields[1];
	if ($genename =~ m/\'/)
	{
		#print $genename,"\n";
		$genename =~ s/\'/\\\'/g;
		# print $genename,"\n";
	} 
	my $ts = $fields[2];
	my $readcount = $fields[3];
	my $rpkm = $fields[4];

#print $line,"\n";
#print "gi: ", $giid,"\n";
#print "Version: ", $versionid,"\n";
#print "geneName: ", $genename,"\n";
#print " 1st RPKM value:",$fields[4],"\n";

#die(" A horribe deathhh");

	 #  print " Total reads is now ",$totalreads," after adding ",$fields[1],"\n";
	
	#PREPARE (bring out yer dead)
my $query = "INSERT into $tablename( transcriptID,giID, trueID, readcount, rpkm) VALUES ($ts,\'$giid\',\'$oatid\',$readcount,$rpkm)";
	my $query_handle = $dbstore->prepare($query) or die("PREPARE FAIL: $DBI::errstr");
#	print $query,"\n";
	$query_handle->execute() or die("EXECUTE FAIL: $DBI::errstr");
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



close(RPKMTABLE);
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


