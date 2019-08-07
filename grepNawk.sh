

grep Nucleotide_alignment_147 ~/old/gm/cslf6/br2.bowtied | awk '{ if (length($7)>=50) print $5 "\t" $7 "\t" $10 }' | less

