use strict;

use Bio::DB::EUtilities;
 
# this needs to be a list of EntrezGene unique IDs
my @ids = @ARGV;
 
my $eutil   = Bio::DB::EUtilities->new(-eutil => 'esummary',
                                       -email => 'mymail@foo.bar',
                                       -db    => 'gene',
                                       -term  => '7668[TID]', 
				       -id    => \@ids);
 
my $fetcher = Bio::DB::EUtilities->new(-eutil   => 'efetch',
                                       -email   => 'mymail@foo.bar',
                                       -db      => 'nucleotide',
                                       -rettype => 'gb');
 
while (my $docsum = $eutil->next_DocSum) {
    # This version uses the updated interface in bioperl-live that will be in
    # BioPerl 1.6.1 (consider it a minor bug fix for the obfuscated version
    # above)
    my ($item) = $docsum->get_Items_by_name('GenomicInfoType');
    next unless $item;
 
    my ($acc, $start, $end) = ($item->get_contents_by_name('ChrAccVer'),
                               $item->get_contents_by_name('ChrStart'),
                               $item->get_contents_by_name('ChrStop'));
 
    my $strand = $start > $end ? 2 : 1;
    printf("Retrieving %s, from %d-%d, strand %d\n", $acc, $start, $end,$strand );
 
    $fetcher->set_parameters(-id        => $acc,
                             -seq_start => $start + 1,
                             -seq_stop  => $end + 1,
                             -strand    => $strand);
    print $fetcher->get_Response->content;
}
