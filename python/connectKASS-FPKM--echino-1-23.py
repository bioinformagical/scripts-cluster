#!/usr/bin/python

import re
import sys
import die
from Bio import SeqIO

######      This will read in 4 files
	#	Protein 2 nt log file that has contig ID and protein ID in header
	#	KAAS result file
	#	Read Count File found in /group/janieslab/4db2/readcount
	#	Fasta file of contigs which needed to calc FPKM values, (Need sequence lengths, and Overall # of NTs in run)	
	#
	#	USAGE:    python /home/rreid2/scripts/python/connectKASS2ReadCounts-echinopath1-23.py ./${num}.logfile.txt ../4db2/readcount/readspercontig-bj${num}.txt ./kaas/bj${num}-kaas.txt-justK.txt ./../4db2/wherebverNTFastaFileIs.fasta ${num}
	#
Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 6 or len(sys.argv) < 6 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read logfile in, parse the header to get protein and contig IDs and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
aadict = {}
while 1:
	line = file1.readline()
	if len(line) == 0:
	 	print "Done loading hash of prot - Nucl contigs !!"
		break
	if ">" not in line: 
	    continue
	linearray = line.split()
	protid=linearray[0]
	protid = protid.replace(">", "")
	nuclid=linearray[8]
	tmp = nuclid.split(':')
	nuclid2 = tmp[0] 
	aadict[nuclid2]=protid
	print nuclid2
	#print protid

###  Read FASTA file in, parse the read length of nucl and add them to a dict. And after get BIG N.
filefasta4 = open(sys.argv[4],"rU")
print sys.argv[4]
fastadict = {}
bigN = 0
for record in SeqIO.parse(filefasta4, "fasta"):
	bigN = bigN + len(record.seq)
	header = record.id
	header = header.replace(">", "")
	headray = header.split(' ')
	header2 = headray[0]
	fastadict[header2]=len(record.seq)

##########   Function to calc FPKM    ###########
def CalcFPKM(reads,tslength,bigN):
        tslen2 = (tslength/1000)
	#read2 = float(reads/1000000)
	a = (reads/tslen2)*1000000
	b = a/bigN
	#print b
	#sys.exit(1)
	return float(b)

############ Creates a dict of protein ID and FPKM.
file2 = open(sys.argv[2])
print sys.argv[2]
ntdict = {}
protreaddict = {}
##### Throw away header
file2.readline()
while 1:
	line = file2.readline()
	if len(line) == 0:
	        print "Done loading hash of Nucl-Reads  !!"
		break
	linearray = line.split()
	contig = linearray[0]
	reads = int(linearray[2])
	#print "Contig is ",contig," and we found a read length of ",fastadict[contig]," and bigN is ",bigN
	if contig in fastadict.keys():
		fpkm = CalcFPKM( float(reads), float(fastadict[contig]), float(bigN) )

		#ntdict[contig]=fpkm
		if contig in aadict.keys():
			protreaddict[aadict[contig]]=str(fpkm)
			#print "Contig: ",contig," & FPKM = ",protreaddict[aadict[contig]]

############    Writing to FILE, first we iterate through KAAS result getting matched KEGG id to Prot ID (e.g m33445)  ########### 
file3 = open(sys.argv[3])
print sys.argv[3]
outname = "bj" + sys.argv[5] + "-kaas-fpkm.txt"
target = open(outname, 'w')
while 1:
	line = file3.readline()
	if len(line) == 0:
		break
	linearray = line.split()
	protarray = linearray[0].split('|')
	prot = protarray[1]
	kaas = linearray[1]
	if prot in protreaddict.keys():
		target.write(kaas)
		target.write("\t")
		target.write(protreaddict[prot])
		target.write("\n")

def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

def CalcFPKM(reads,tslength,bigN):
	tslen2 = tslength/1000
	read2 = read/1000000
	a = read2/tslen2
	b = a/bigN
	print b
	return float(b)
