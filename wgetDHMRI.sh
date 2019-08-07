#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=24:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=4

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)


#PBS -N wgetFromFieryHell
##PBS -q bigiron

##home=/gpfs/fs3/home/rreid2


# launching Launching build_lmer_table on a single node so it can run till the cows come home
#echo "Launching Repeat Masker"
export PATH=$HOME/bin:$PATH
export PATH=$HOME/bin/RepeatMasker:$PATH
export PATH=$HOME/bin/rmblast-1.2-ncbi-blast-2.2.23+-src/c++/GCC412-ReleaseMT64/bin:$PATH


wget --user=uncc --password=go49ers! http://dl.dhmri.org/UNCC/454_Data/GSC3R5O01.sff
wget --user=uncc --password=go49ers! http://dl.dhmri.org/UNCC/454_Data/GSC3R5O02.sff
wget --user=uncc --password=go49ers! http://dl.dhmri.org/UNCC/HiSeq_Data/Lane1.tar.gz
wget --user=uncc --password=go49ers! http://dl.dhmri.org/UNCC/HiSeq_Data/Lane2.tar.gz
wget --user=uncc --password=go49ers! http://dl.dhmri.org/UNCC/HiSeq_Data/Lane3.tar.gz
wget --user=uncc --password=go49ers! http://dl.dhmri.org/UNCC/HiSeq_Data/Lane4.tar.gz
wget --user=uncc --password=go49ers! http://dl.dhmri.org/UNCC/HiSeq_Data/Lane5.tar.gz


