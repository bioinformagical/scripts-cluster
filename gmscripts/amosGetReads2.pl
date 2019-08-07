use AMOS::AmosLib;


#my $fileName = $ARGV[0] or die "Need a asm_afg file generated from Velvet / oases. \n This will give you reads / contig\n";
#my $fileName = "velvet_asm.afg";
my $fileName = "/lustre/home/rreid2/old/gm/assembly2/sp2/oases_asm.afg";
open(fileHandle, $fileName);

my $totalReads = 0;

my $totalContigs = 0;

while (my $record = getRecord(\*fileHandle)){

        my ($rec, $fields, $recs) = parseRecord($record);

        if($rec eq "CTG"){

                $totalContigs++;

                my $nReads = 0;

                for(my $r = 0; $r <= $#$recs; $r++){

                        my ($srec, $sfields, $srecs) = parseRecord($$recs[$r]);

                        if($srec eq "TLE"){

                                $nReads++;

                                $totalReads++;

                        }

                }

                print "Number of Reads in contig#", $$fields{iid}, " are ", $nReads, "\n";

        }

}

print "Total # of Contigs :", $totalContigs, "\n";

print "Total # of reads in contigs:", $totalReads, "\n";


close(fileHandle);
