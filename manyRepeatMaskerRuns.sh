#!/bin/sh





# Request a run time of 5 hours and 30 minutes
#PBS -l walltime=128:30:00

# Request 1 processor in 1 node
#PBS -l nodes=1:ppn=4

# Request 7600 megabytes memory per processor.  ( 48 usable CPUs)


#PBS -N rMaskerContigs2
##PBS -q bigiron

##home=/gpfs/fs3/home/rreid2


# launching Launching build_lmer_table on a single node so it can run till the cows come home
#echo "Launching Repeat Masker"
export PATH=$HOME/bin:$PATH
export PATH=$HOME/bin/RepeatMasker:$PATH
export PATH=$HOME/bin/rmblast-1.2-ncbi-blast-2.2.23+-src/c++/GCC412-ReleaseMT64/bin:$PATH

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/blueberry/blueRScout.out -cutoff 350 -dir /gpfs/fs3/home/rreid2/db/blueberry -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna 

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/vitis/vitisRScout.out -cutoff 350 -dir /gpfs/fs3/home/rreid2/db/vitis -ace -gff /gpfs/fs3/home/rreid2/db/vitis/vitisscaffolds.fa 



#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/repbase/bigRepeats.fasta -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/rm200scout-repbase -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/repbase/bigRepeats.fasta -cutoff 1000 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/rm1000scout-repbase -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/repbase/bigRepeats.fasta -cutoff 500 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/rm500scout-repbase -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4  -lib /gpfs/fs3/home/rreid2/db/repbase/bigRepeats.fasta -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/rm200scout-repbase-noSens -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/repbase/bigRepeats.fasta -cutoff 1000 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/rm1000scout-repbase -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna

#time perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/repbase/bigRepeats.fasta -cutoff 500 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/rm500scout-repbase -ace -gff /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/arabid/repeatlibrary/specieslib -cutoff 350 -dir /gpfs/fs3/home/rreid2/arabid/rmasker/ara350-chr2 -ace -gff /gpfs/fs3/home/rreid2/arabid/chr2out.trim

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/arabid/repeatlibrary/specieslib -cutoff 350 -dir /gpfs/fs3/home/rreid2/arabid/rmasker/ara350-chr3 -ace -gff /gpfs/fs3/home/rreid2/arabid/chr3out.trim

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/arabid/repeatlibrary/specieslib -cutoff 350 -dir /gpfs/fs3/home/rreid2/arabid/rmasker/ara350-chr4 -ace -gff /gpfs/fs3/home/rreid2/arabid/chr4out.trim

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/arabid/repeatlibrary/specieslib -cutoff 350 -dir /gpfs/fs3/home/rreid2/arabid/rmasker/ara350-chr5 -ace -gff /gpfs/fs3/home/rreid2/arabid/chr5out.trim

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/vitis/vitisRScout.out -cutoff 250 -dir /gpfs/fs3/home/rreid2/blueberry/vitisRscoutRM/scout5 -ace -gff /gpfs/fs3/home/rreid2/db/vitis/split/subcontig5.fna 

#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/arabid/repeatlibrary/specieslib -cutoff 350 -dir /gpfs/fs3/home/rreid2/arabid/rmasker/ara350-chr4 -ace -gff /gpfs/fs3/home/rreid2/arabid/chr4out.trim


perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/blueberry/contig2/rscout/contig3RS.out -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/contig2VSrscout3 -ace -gff /gpfs/fs3/home/rreid2/blueberry/contig2/454AllContigs.trim
perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/blueberry/contig2/rscout/contig4RS.out -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/contig2VSrscout4 -ace -gff /gpfs/fs3/home/rreid2/blueberry/contig2/454AllContigs.trim
perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/blueberry/contig2/rscout/contig5RS.out -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/contig2VSrscout5 -ace -gff /gpfs/fs3/home/rreid2/blueberry/contig2/454AllContigs.trim
perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/blueberry/contig2/rscout/contig6RS.out -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/contig2VSrscout6 -ace -gff /gpfs/fs3/home/rreid2/blueberry/contig2/454AllContigs.trim
perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/blueberry/contig2/rscout/contig7RS.out -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/contig2VSrscout7 -ace -gff /gpfs/fs3/home/rreid2/blueberry/contig2/454AllContigs.trim
perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/blueberry/contig2/rscout/contig8RS.out -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/contig2VSrscout8 -ace -gff /gpfs/fs3/home/rreid2/blueberry/contig2/454AllContigs.trim


#perl /gpfs/fs3/home/rreid2/bin/RepeatMasker/RepeatMasker -pa 4 -s -lib /gpfs/fs3/home/rreid2/db/blueberry/ConsensusSequences.fna -cutoff 200 -dir /gpfs/fs3/home/rreid2/blueberry/rmasker/rm200scoutVSrepbaseREVERSED -ace -gff /gpfs/fs3/home/rreid2/db/repbase/bigRepeats.fasta 
