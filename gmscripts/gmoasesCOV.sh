
#!/bin/sh

# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
##PBS -l pmem=7600mb

#PBS -N GMOases
#PBS -q bigiron


#Number of times to run this script
##PBS -t 1-10

##home=/gpfs/fs3/home/rreid2
#cd $HOME/blueberry/reads/illumina/091230Sequence1/
export PATH=$HOME/bin/velvet_1.1.04:$PATH


cd $HOME/gm/assembly/


num=1;
while [ $num -le 10 ]
do
	#/sw/oases-0.1.16/bin/oases  $HOME/br49 -cov_cutoff ${num} 
	

	/sw/oases-0.1.16/bin/oases  $HOME/gm/assembly/he49 -cov_cutoff ${num}
	mkdir $HOME/gm/assembly/covTemp/he49-${num}
	cp $HOME/gm/assembly/he49/* $HOME/gm/assembly/covTemp/he49-${num}
	num=`expr $num + 1`;
	
done


echo   ${file};

echo `pwd`



