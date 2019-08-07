#!/bin/sh

# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=98:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=4

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)


#PBS -N LucySkyDiamonds
#PBS -q bigiron

##home=/gpfs/fs3/home/rreid2


# launching Launching build_lmer_table on a single node so it can run till the cows come home
#echo "Launching Repeat Masker"
export PATH=$HOME/bin:$PATH

cd $HOME/blueberry/reads/454Sequences/all/


for file in $(find ./ -name "*.fasta.clean");
do
 echo   ${file};
  lucy -xtra 4 -o ${file}.lucy ${file%.fasta.clean}.qual.clean.lucy ${file} ${file%.clean}.qual.clean      
done








#lucy -xtra 4 -o split_1.fasta.clean.lucy split_1.qual.clean.lucy split_1.fasta.clean split_1.qual.clean
#lucy -xtra 4 -o split_2.fasta.clean.lucy split_2.qual.clean.lucy split_2.fasta.clean split_2.qual.clean
#lucy -xtra 4 -o split_3.fasta.clean.lucy split_3.qual.clean.lucy split_3.fasta.clean split_3.qual.clean
