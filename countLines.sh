


#!/bin/sh

# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
##PBS -l pmem=7600mb

#PBS -N countyLine 
##PBS -q bigiron


#Number of times to run this script
##PBS -t 1-10


awk 'BEGIN{P=1}{if(P==2){if(length>=15){print length}}; if(P==2)P=0;P++}' /gpfs/fs3/home/rreid2/bin/sspace/SSPACE-1.1_linux-x86_64/big8kb/GAII_PE_1.fasta | wc -l
