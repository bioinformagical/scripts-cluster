use strict;
use Bio::DB::EUtilities;

# set optional history queue
my $factory = Bio::DB::EUtilities->new(-eutil      => 'esearch',
                                       -email      => 'rreid2@uncc.edu',
                                       -db         => 'gene',
                                       -term       => '7668[TID]',
                                       -usehistory => 'y');

my $count = $factory->get_count;
# get history from queue
my $hist  = $factory->next_History || die 'No history data returned\n';
print "History returned\n";
# note db carries over from above
$factory->set_parameters(-eutil   => 'efetch',
                         -rettype => 'fasta',
                         -history => $hist);

my $retry = 0;
my ($retmax, $retstart) = (500,0);

open (my $out, '>', 'seqs.fa') || die "Can't open file:$!\n";
RETRIEVE_SEQS:
while ($retstart < $count) {
    $factory->set_parameters(-retmax   => $retmax,
                             -retstart => $retstart);
    eval{
        $factory->get_Response(-cb => sub {my ($data) = @_; print $out $data} );
    };
    if ($@) {
        die "Server error: $@.  Try again later\n" if $retry == 5;
        print STDERR "Server error, redo #$retry\n";
        $retry++ && redo RETRIEVE_SEQS;
    }
    print "Retrieved $retstart\n";
    $retstart += $retmax;
}









close $out;		


