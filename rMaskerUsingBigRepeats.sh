#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=8

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
#PBS -l pvmem=7600mb

#PBS -N RepeatMasker
##PBS -q bigiron

##home=/gpfs/fs3/home/rreid2


# launching Launching build_lmer_table on a single node so it can run till the cows come home
#echo "Launching Repeat Masker"
export PATH=$HOME/bin:$PATH
export PATH=$HOME/bin/RepeatMasker:$PATH
export PATH=$HOME/bin/rmblast-1.2-ncbi-blast-2.2.23+-src/c++/GCC412-ReleaseMT64/bin:$PATH

perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 8 -s -lib /gpfs/fs3/home/rreid2/db/bigRepeats.fasta -cutoff 350 -dir $HOME $1 -ace -gff $HOME/vitisscaffolds.fa  



