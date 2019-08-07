#!/usr/bin/env perl
use SOAP::Lite +trace => [qw(debug)];
###############     This needs SOAP module, too lazy to go get that.

my $serv = SOAP::Lite -> service("http://soap.genome.jp/KEGG.wsdl");
my $result = $serv->get_genes_by_pathway('path:hsa00010');
my $count = 0;
foreach (@{$result}){
    print $_,"\n";
    $count += 1;
}
print $count,"\n";
