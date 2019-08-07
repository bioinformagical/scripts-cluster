use strict;
use warnings;
use Bio::SeqIO;

# Read in sample id file to get the Bioproject and Biosample #.
# read in the template and and assign the correct info into the template and save as new template file.
# 

my $bjnum= $ARGV[0] or die "Need a bj number first\n";
#my $inputfile="BJ$fName1.fsa";
my $samples= $ARGV[1] or die "I need A sample text file with species names\n";
open (INFILE, "$samples")or die "Cannot open infile, ";
my $templatefile= $ARGV[2] or die "I need A ncbi generated template file\n";
#my $filename1 = $fName1."-header.fasta";
my $filename1 = "BJ$bjnum-template.sbt";
open (FILE1, ">$filename1") or die $!; 

######  Read in Species tabel and HASH it   ######
my $biosample; my $bioproject;
<INFILE>; # throwa away header
while (my $line=<INFILE>)
{
	chomp $line;
	my @splitty = split("\t",$line);
	#$bioproject= $splitty[8];
	#$biosample= $splitty[9];
	my $bj= $splitty[-1];
	#print "$bioproject $biosample \t $bj\n";
	if ($bj == $bjnum) 
	{
		$bioproject= $splitty[8];
		$biosample=  $splitty[9]; 
		#$taxa = "$genus $species"; 
	}
}

### Writing out exisiting template top new file
open (TEMPLATEFILE, "$templatefile")or die "Cannot open template file, ";
while (my $line=<TEMPLATEFILE>)
{
	chomp $line;
	print FILE1 "$line\n";
}


#### Writing new part to template file (ie the NCBI IDs)
print FILE1 "\t\t\"$bioproject\"\n";
print FILE1 "\t  }\n";
print FILE1 "\t},\n";
print FILE1 "\t{\n";
print FILE1 "\t  label str \"BioSample\",\n";
print FILE1 "\t  num 1,\n";
print FILE1 "\t  data strs {\n";
print FILE1 "\t    \"$biosample\"\n";
print FILE1 "\t  }\n";
print FILE1 "\t}\n";
print FILE1 "  }\n";
print FILE1 "}\n";



print "Fin\n";
close(FILE1);
close(INFILE);
close(TEMPLATEFILE);
exit;
