

#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=48:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=1

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)
#PBS -l pvmem=7600mb

#PBS -N fetchNT


home=/gpfs/fs3/home/rreid2


# launching compare-to-gff.prl on a single node so it can run till the cows come home
echo "Launching BlastN "

cd $home/db/nt



#/sw/ncbi-blast/bin/blastn -outfmt 6 -query ~/db/blueberry/blueRScout.out -db ~/db/vitis/vitisscaffolds.fa -out /gpfs/fs3/home/rreid2/blueberry/bbBlastedVitisGenome/bbRscoutVSvitisgenome-mega.out -task megablast -evalue 0.00001 -soft_masking false

#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.00.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.01.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.02.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.03.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.04.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.06.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.07.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.08.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.09.tar.gz
#wget ftp://ftp.ncbi.nih.gov/blast/db/nt.05.tar.gz

tar xvf nt.02.tar
tar xvf nt.03.tar
tar xvf nt.04.tar
tar xvf nt.05.tar
tar xvf nt.06.tar
tar xvf nt.07.tar
tar xvf nt.08.tar
tar xvf nt.09.tar



