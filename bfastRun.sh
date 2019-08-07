
#!/bin/sh

# Run Bfast Alignment tool

PATH=$HOME/bin/bfastDir/bfast+bwa-0.6.5a:$PATH


#Create Reference Genome
#bfast fasta2brg -f $HOME/cluster/bin/sspace/SSPACE-1.1_linux-x86_64/big8kb/454LargeContigs.fna  #-T /home/rreid2/cluster/temp -A 0 

#create indexes of Reference genome
#bfast index -m 1111011101011111101111 -f  $HOME/cluster/bin/sspace/SSPACE-1.1_linux-x86_64/big8kb/454LargeContigs.fna -w 12 -i 5

#find candidate alignment locations (CALs) for each read.
bfast match -f $HOME/cluster/bin/sspace/SSPACE-1.1_linux-x86_64/big8kb/454LargeContigs.fna -r $HOME/cluster/bin/sspace/SSPACE-1.1_linux-x86_64/big8kb/GAII_PE_1.fasta 

#  fully align each CAL for each read
#bfast localalign

#final step is to prioritize the final alignments.
#bfast postprocess

#post convert....
#bfast bafconvert





# -n 4    (# of CPUs) 
# -Q 1000  (# of reads to load at a time)
# -T ./tmp   (where to store temp files)
# -w option specifies the hash width

