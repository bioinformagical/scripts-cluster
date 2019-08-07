
#!/bin/sh

# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=16:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
#PBS -l pmem=7600mb

#PBS -N nucmerHunterrr 
##PBS -q bigiron


#Number of times to run this script
#PBS -t 1-33

##home=/gpfs/fs3/home/rreid2
#cd $HOME/blueberry/reads/illumina/091230Sequence1/
#export PATH=/sw/velvet/bin:$PATH
#/sw/velvet/bin/velveth velvet31 31 -fastq -long s_1_sequence.txt.trimmedkmer7520 

#/sw/velvet/bin/velvetg velvet31 -exp_cov auto -min_contig_lgth 100 -unused_reads yes -cov_cutoff auto 

#/sw/velvet/bin/velvetg velvet17 -exp_cov auto -min_contig_lgth 100 -unused_reads yes -cov_cutoff auto

cd ~/old/gm/genes/2more/

ssid=$(sed -n -e "${PBS_ARRAYID}p" ./filedir.txt)

		        

	echo `pwd`


echo $ssid

  ~/sw/MUMmer3.22/nucmer --maxmatch --coords -prefix $ssid.VS2more /lustre/home/rreid2/old/gm/genes/2more/2moregenes.fasta /lustre/home/rreid2/old/gm/assembly2/$ssid/tmp/oases_asm.afg.contigSeq.fasta


