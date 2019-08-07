#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=128:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=4

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)


#PBS -N RepeatMaskerVitis
##PBS -q bigiron

##home=/gpfs/fs3/home/rreid2


# launching Launching build_lmer_table on a single node so it can run till the cows come home
#echo "Launching Repeat Masker"
export PATH=$HOME/bin:$PATH
export PATH=$HOME/bin/RepeatMasker:$PATH
export PATH=$HOME/bin/rmblast-1.2-ncbi-blast-2.2.23+-src/c++/GCC412-ReleaseMT64/bin:$PATH

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/blueberry/blueRScout.out -cutoff 350 -dir /gpfs/fs3/home/rreid2/db/blueberry -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna 

perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/vitis/vitisRScout.out -cutoff 350 -dir /gpfs/fs3/home/rreid2/db/vitis -ace -gff /gpfs/fs3/home/rreid2/db/vitis/vitisscaffolds.fa 

