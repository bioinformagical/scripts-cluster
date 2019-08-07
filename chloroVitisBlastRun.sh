#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
#PBS -l pvmem=7600mb

#PBS -N blastnchloroWine


home=/gpfs/fs3/home/rreid2


# Blasting reads against vitis chloroplast genome to identify reads that are chloroplasty and not strictly blueberrish
echo "Launching BlastN "

cd $home


	/sw/ncbi-blast/bin/blastn/makeblastdb -in /gpfs/fs3/home/rreid2/db/vitis/chloroplast/vitisviniferisChloroplastgenome.fna   -dbtype nucl
        /sw/ncbi-blast/bin/blastn/makeblastdb -in /gpfs/fs3/home/rreid2/blueberry/reads/454Sequences/gscr50/GSC3R5O01.fasta   -dbtype nucl


 /sw/ncbi-blast/bin/blastn -outfmt 6 -query  /gpfs/fs3/home/rreid2/blueberry/reads/454Sequences/gscr50/GSC3R5O01.fasta -db ~/db/vitis/chloroplast/vitisviniferisChloroplastgenome.fna  -out /gpfs/fs3/home/rreid2/db/vitis/chloroplast/ -task megablast -evalue 0.00001 -soft_masking false










