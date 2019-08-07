#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
#use Mysql;
use DBI;
#use DBI::mysql;

# This reads in blasted and parsed xml table results and makes the RPKM values and makes a new table.

my $numargs = $#ARGV + 1;
if ($numargs != 3)
{
	die("We did not get 3 arguments, All YOUR BASE ARE BELONG TO US\#");
}


my $transcriptfile= $ARGV[0] or die "Feed me transcript file ...";
my $readsfile= $ARGV[1] or die "Feed me reads file so I can figure out Total reads ...";
my $tableid = $ARGV[2] or die "Feed me a table id so I can create a new SQL table using that name ...";

#Parse Ts file for lengths of 
#open (TSFILE, $positionfile) or die $!;

my $totalreads = 0;
my %tshash;
my @conan;

my $foo = new Bio::SeqIO (-file=>$transcriptfile, -format=>'fasta');

while (my $seq = $foo->next_seq)
{
	
	my $sid = $seq->display_id;
	my $sequence = $seq->seq;
	$tshash{$sid}= $sequence;
	#print $sid,"\t",$tshash{$sid},"\n";
}

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
my $tablename = $tableid."tscriptread";
my $tablequery = "CREATE TABLE  $tablename ( seqid MEDIUMINT UNSIGNED,  sequence TEXT NOT NULL, tsreads INT UNSIGNED, CONSTRAINT  pk_seqid PRIMARY KEY (seqid))" ;
my $tablequery_handle = $dbstore->prepare($tablequery) or die("PREPARE FAIL: $DBI::errstr");
$tablequery_handle->execute() or die("EXECUTE FAIL: $DBI::errstr");
print $tablequery,"\n";      
$tablequery_handle->finish();



#READ IN READS FILE and get total sum of reads
open(READS, $readsfile) or die "can't read reads file";

while (my $line = <READS>)
{       
      chomp $line;
      my @fields = split('\t', $line);
      $totalreads = $totalreads + $fields[1];
      my $sid = $fields[0];
      my $seq = $tshash{$sid};
      my $read = $fields[1];


	 #  print " Total reads is now ",$totalreads," after adding ",$fields[1],"\n";
	
	#PREPARE (bring out yer dead)
	my $query = "INSERT into $tablename (seqid, sequence, tsreads) VALUES (\'$sid\',\'$seq\',$read)";
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


