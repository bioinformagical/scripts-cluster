#!/bin/sh




# launching compare-to-gff.prl on a single node so it can run till the cows come home
echo "Getting names of fna"

cd $HOME/gm/assembly2/

#file=$(sed -n -e "${PBS_ARRAYID}p" ./filedir.txt)


for file in $(find ./ -iname "*.fna");
do 

echo "${file}"

#/gpfs/fs3/home/rreid2/bin/ncbi-blast-2.2.22+/bin/makeblastdb -in ${file} -dbtype nucl 

#/gpfs/fs3/home/rreid2/bin/ncbi-blast-2.2.22+/bin/blastx -db ~/db/swissprot/uniprot_sprot.fasta -query ${file} -out ${file%.fna}.xml

done




#/sw/ncbi-blast/bin/blastn -outfmt 6 -query ~/db/blueberry/blueRScout.out -db ~/db/vitis/vitisscaffolds.fa -out /gpfs/fs3/home/rreid2/blueberry/bbBlastedVitisGenome/bbRscoutVSvitisgenome-mega.out -task megablast -evalue 0.00001 -soft_masking false

# blasting against REPBASE

#/sw/ncbi-blast/bin/blastn -query ~/db/blueberry/blueRScout.out -db ~/db/repbase/bigRepeats.fasta -out /gpfs/fs3/home/rreid2/blueberry/bbBlastedRepbase/bbRscoutVSrepbase-blastncut05.out -task blastn -evalue 0.05 -soft_masking false  -outfmt 6


# Blasting against grape

#/sw/ncbi-blast/bin/blastn -query ~/db/blueberry/blueRScout.out -db ~/db/vitis/vitisscaffolds.fa  -out /gpfs/fs3/home/rreid2/blueberry/bbBlastedVitisGenome/bbRscoutVSvitis-blastncut05.out -task blastn -evalue 0.05 -soft_masking false  -outfmt 6

#/sw/ncbi-blast/bin/blastn -query ~/db/blueberry/blueRScout.out -db ~/db/vitis/vitisscaffolds.fa  -out /gpfs/fs3/home/rreid2/blueberry/bbBlastedVitisGenome/bbRscoutVSvitis-megablastcut05nomask.out -task megablast -evalue 0.05 -soft_masking true  -outfmt 6

#Blasting against NT

#/sw/ncbi-blast/bin/blastn -query ~/db/blueberry/blueRScout.out -db ~/db/nt/nt.00  -out /gpfs/fs3/home/rreid2/blueberry/bbBlastNT/bbRscoutVSnt00-blastncut05nomask.out -task blastn -evalue 0.05 -soft_masking false  -outfmt 6

#/sw/ncbi-blast/bin/blastn -query ~/db/blueberry/blueRScout.out -db ~/db/nt/nt.01  -out /gpfs/fs3/home/rreid2/blueberry/bbBlastNT/bbRscoutVSnt01-blastncut05nomask.out -task blastn -evalue 0.05 -soft_masking false  -outfmt 6

#/sw/ncbi-blast/bin/makeblastdb -in $HOME/blueberry/soap/run3/graph3scaf.fa -dbtype nucl     
#/sw/ncbi-blast/bin/makeblastdb -in $HOME/db/nt/nt.fa  -dbtype nucl
#/sw/ncbi-blast/bin/makeblastdb -in $HOME/blueberry/bbBlastNT/temp.fa  -dbtype nucl
#/sw/ncbi-blast/bin/makeblastdb -in $HOME/blueberry/reads/454Sequences/all/split/3kb_1.fasta
#/sw/ncbi-blast/bin/makeblastdb -in $HOME/blueberry/reads/454Sequences/all/split/8kb_1.fasta
#/sw/ncbi-blast/bin/makeblastdb -in $HOME/blueberry/reads/454Sequences/all/split/20kb_1.fasta
#/sw/ncbi-blast/bin/makeblastdb -in $HOME/gm/assembly2/${file}/transcripts.fa -dbtype nucl

#for i in 1 2 3
#do
#name = "he"

 #	mkdir ${file}
#	/sw/ncbi-blast/bin/blastx -query $HOME/gm/assembly2/${file}/transcripts.fa -db ~/db/swissprot/uniprot_sprot.fasta  -out $HOME/gm/blastx/${file}/blastx.xml  -soft_masking false  -outfmt 5

#done


#/sw/ncbi-blast/bin/blastx -query $HOME/gm/assembly2/${file}/transcripts.fa -db ~/db/swissprot/uniprot_sprot.fasta  -out $HOME/gm/blastx/${file}blastx.out  -soft_masking false  -outfmt 5


#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/reads/454Sequences/all/split/3kb_1.fasta -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/3kb5.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 5

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/reads/454Sequences/all/split/8kb_1.fasta -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/8kb5.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 5

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/reads/454Sequences/all/split/20kb_1.fasta -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/20kb5.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 5



#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/soap/run3/graph3scaf.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/soapRun3.out -task blastn -evalue 0.0000000000005 -soft_masking false  -outfmt 5
#
#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp2.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 2

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp3.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 3

#4/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp4.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 4

#/#sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp5.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 5

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp6.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 6

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp7.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 7

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp8.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 8

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp9.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 9

#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/bbBlastNT/temp.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/temp10.out -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 10



#/sw/ncbi-blast/bin/blastn -query $HOME/blueberry/soap/run3/graph3scaf.fa -db ~/db/nt/nt.fa  -out $HOME/blueberry/bbBlastNT/ -task blastn -evalue 0.00000000005 -soft_masking false  -outfmt 6




