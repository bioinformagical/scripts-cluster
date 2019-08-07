#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)


#PBS -N BuildHashTableRepeatScout 
#PBS -q bigiron

#home=/gpfs/fs3/home/rreid2


# launching Launching build_lmer_table on a single node so it can run till the cows come home
#echo "Launching build_lmer_table"

cd $PBS_O_WORKDIR

/gpfs/fs3/home/rreid2/scripts/build_lmer_table -sequence /gpfs/fs3/home/rreid2/arabid/chrdata/chr1out.fas -freq /gpfs/fs3/home/rreid2/arabid/rscout/arabid1.freq

/gpfs/fs3/home/rreid2/scripts/build_lmer_table -sequence /gpfs/fs3/home/rreid2/arabid/chrdata/chr2out.fas -freq /gpfs/fs3/home/rreid2/arabid/rscout/arabid2.freq 

/gpfs/fs3/home/rreid2/scripts/build_lmer_table -sequence /gpfs/fs3/home/rreid2/arabid/chrdata/chr3out.fas -freq /gpfs/fs3/home/rreid2/arabid/rscout/arabid3.freq 

/gpfs/fs3/home/rreid2/scripts/build_lmer_table -sequence /gpfs/fs3/home/rreid2/arabid/chrdata/chr4out.fas -freq /gpfs/fs3/home/rreid2/arabid/rscout/arabid4.freq 

/gpfs/fs3/home/rreid2/scripts/build_lmer_table -sequence /gpfs/fs3/home/rreid2/arabid/chrdata/chr5out.fas -freq /gpfs/fs3/home/rreid2/arabid/rscout/arabid5.freq  



