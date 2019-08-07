
#!/bin/sh

# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=168:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
##PBS -l pmem=7600mb

#PBS -N GMVelvetOases
#PBS -q bigiron


#Number of times to run this script
##PBS -t 1-10

##home=/gpfs/fs3/home/rreid2
#cd $HOME/blueberry/reads/illumina/091230Sequence1/
#export PATH=$HOME/bin/velvet_1.1.04:$PATH
#/sw/velvet/bin/velveth velvet31 31 -fastq -long s_1_sequence.txt.trimmedkmer7520 

#/sw/velvet/bin/velvetg velvet31 -exp_cov auto -min_contig_lgth 100 -unused_reads yes -cov_cutoff auto 

#/sw/velvet/bin/velvetg velvet17 -exp_cov auto -min_contig_lgth 100 -unused_reads yes -cov_cutoff auto

cd $HOME/gm/assembly/


num=21;
while [ $num -le 88 ]
do
	/sw/velvet/bin/velveth $HOME/gm/assembly/br${num} ${num} -short -fastq /gpfs/fs3/home/rreid2/gm/data/filter/br2.fastq.dup.trim20
         /sw/velvet/bin/velvetg $HOME/gm/assembly/br${num} -read_trkg yes
	
	/sw/oases/bin/oases $HOME/gm/assembly/br${num}

#	/sw/velvet/bin/velveth $HOME/gm/assembly/he${num} ${num} -short -fastq /gpfs/fs3/home/rreid2/gm/data/filter/he2.fastq.dup.trim20	
#	 /sw/velvet/bin/velvetg $HOME/gm/assembly/he${num} -read_trkg yes 

#	/sw/oases/bin/oases $HOME/gm/assembly/he${num}
		
	num=`expr $num + 2`;
	echo $num
done

#/sw/velvet/bin/shuffleSequences_fastq.pl s_1_1_sequence.txt.trimmedkmer75v120 s_1_2_sequence.txt.trimmedkmer75v120 sequencev2.shuffled

#echo Starting velvetH
#/sw/velvet/contrib/VelvetOptimiser-2.1.7/VelvetOptimiser.pl -s 45 -e 65 -f ' -fastq -shortPaired /gpfs/fs3/home/rreid2/blueberry/reads/illumina/091005Sequence1/sequencev2.shuffled'
#/sw/velvet-1.1.03/bin/velveth velvet63trimmed 63 -fastq -shortPaired $HOME/blueberry/reads/illumina/091005Sequence1/sequencev2.shuffled

#/sw/velvet-1.1.03/bin/velveth velvet63trimmed 63 -fastq -shortPaired $HOME/blueberry/reads/illumina/091005Sequence1/sequencev2.shuffled

#/sw/velvet-1.1.03/bin/velveth velvet63trimmed 63 -fastq -shortPaired $HOME/blueberry/reads/illumina/091005Sequence1/sequencev2.shuffled
echo `pwd`



