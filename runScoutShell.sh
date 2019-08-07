#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
#PBS -l pvmem=7600mb

#PBS -N compareRepeatScoutOutputToGFF


home=/gpfs/fs3/home/rreid2


# launching compare-to-gff.prl on a single node so it can run till the cows come home
echo "Launching Compare-to-gff.prl"

cd $home

./scripts/compare-out-to-gff.prl --cat=../ConsensusSequencesTrimmed.fna.cat.filtered --gff=../ConsensusSequences.fna.out.gff --f=../ConsensusSequences.fna 

exit 0

