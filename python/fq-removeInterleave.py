"""
Convert interleaved FASTQ to 2 paired FASTQ files 

Usage:
$ ./fasta_to_fastq NAME.fasta NAME.fastq
"""
 
import sys, os
#import ParseFastQ
from Bio import SeqIO
from Bio.SeqIO.QualityIO import FastqGeneralIterator

# Get inputs
fa_path = sys.argv[1]
fq_path1 = sys.argv[2]
fq_path2 = sys.argv[3]

f_suffix = "/1"
r_suffix = "/2"
flag = True
# make fastq

#parser = ParseFastQ(fa_path)
#for record in parser:
#	print  record[0] 

with open(fa_path, "r") as fastq, open(fq_path1, "w") as fastq1, open(fq_path2, "w") as fastq2 :
     for record in SeqIO.parse(fastq, "fastq"):
		#print record.id
		if (flag == True):
			#record.id = record.id 
			flag = False
			SeqIO.write(record, fastq1, "fastq")
		else:
			#record.id = record.id 
			flag = True
			SeqIO.write(record, fastq2, "fastq")
		#print record.id.endswith("1:N:0:")
		#record.letter_annotations["phred_quality"] = [40] * len(record)
             	#SeqIO.write(record, fastq, "fastq")
