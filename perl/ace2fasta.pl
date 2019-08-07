use Bio::Assembly;
use Bio::SeqIO;
use Bio::Seq;

$infile = shift or die;
$outfile = shift or die;

$seqio_obj = Bio::SeqIO->new(-file => ">$outfile", -format => 'fasta' );

$assembly_obj = Bio::Assembly::IO->new(-file=>"<$infile", -format=>'ace');

$assembly = $assembly_obj->next_assembly;

foreach $contig ($assembly->all_contigs) {

    $seq = $contig->get_consensus_sequence()

    $seq_obj = Bio::Seq->new(-seq => $seq->seq(),                        
                          -display_id => "ID_is_always_good",                        
                          -desc => "Say_smth_about_it",                        
                          -alphabet => "dna" );

    $seqio_obj->write_seq($seq_obj);

}
