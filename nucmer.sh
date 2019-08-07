
#!/bin/sh




# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
##PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
##PBS -l pmem=7600mb

#PBS -N nucmerrrrrrrr 
##PBS -q bigiron


#Number of times to run this script
##PBS -t 1-10
##PBS -l pmem=7600mb



cd ~/blueberry/nucmer

 ~/sw/MUMmer3.22/nucmer --maxmatch -mincluster 50 -b 400 -minmatch 40 --coords -prefix newblerVSmirarep2 garrons454Scaffolds.fna mirarep.fa 


