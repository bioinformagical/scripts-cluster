#!/usr/bin/python

import re
import sys
import die

######      This will read in the scaffold/marker file, the blat2genome file, a protein sequence file  and the bb rnaseq interproscan results. 
#	    We read in an interpro Scan result and summarize how many of each type of annotation that we get.
	#
	#
	#	USAGE:    python /home/rreid2/scripts/python/bb-parse-blat2genome2interpro.py ./cleaned-sort-uniq-markers2scaff.txt /group/p2ep/blueberry/rnaseq/sra-srr118/blat2genome/blat-SRR1188089.gff    \ 
	#	/group/p2ep/blueberry/rnaseq/sra-srr118/aa/SRR1187632/best_candidates.eclipsed_orfs_removed.pep  \
	#	/group/p2ep/blueberry/rnaseq/sra-srr118/interpro/SRR1187632-iprscan.out  
	#
	#
#Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 5 or len(sys.argv) < 5 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read in interpro results, parse the IDs and add them to a dictm.
#file1 = open(sys.argv[2])
#print sys.argv[2]
#prefix=sys.argv[1].split('-')[0]
#print prefix

godict = {}
descdict = {}

###########   Read in the GO terms file as a dict.
with open(sys.argv[4]) as fp:
    for line in fp:
    	#print line
#	line = file1.readline()
#	if len(line) == 0:
#	 	print "Done loading in the interprofile."
#		break
	linearray = line.split("\t")
	#if "GO:" in line:
	protid=linearray[0]
	#goterms = linearray[13]
	godict[protid]=linearray[2:]
	#print "Our Go terms for ",protid," is ",godict[protid] 


###########     Read in Fasta of Proteins  into a fastadict with the NT as the key and the prot id as the value.
aadict = {}
aaid = ""
seq = ""
#fa_path = sys.argv[3]
with open(sys.argv[3]) as aafile:
	for line in aafile:
		line =  line.strip()
		if ">" in line:
			aaid = line
			aaid = aaid.replace(">","")
			linearray = aaid.split(" ")
			protid = linearray[0]
			ntid = linearray[9]
			ntray = ntid.split(":")
			nt = ntray[0]
			#print nt
			aadict[nt]=protid
#sys.exit()

############  OPen up the GFF file of blat2genome and make a blatdict      ############
blatdict={}
print sys.argv[2]
with open(sys.argv[2]) as blat:
	for _ in xrange(1):
		### Throwa away GFF header
		next(blat)
	for line in blat:
		linearray = line.split("\t")
		scaf = linearray[0]
		#print scaf
		#sys.exit()
		rnaseqsluj = linearray[8]
		#print rnaseqsluj
		rnaray = rnaseqsluj.split(";")
		ranray2 = rnaray[1].split(" ")
		rnaseqid = ranray2[0]
		blatdict[scaf]=rnaseqid


#############    Open the marker 2 scaff file and gather all the pieces   ###############
sra = sys.argv[4].split("-")[2]
fileout = sra+"-merged.txt"
outfile = open(fileout, 'w')
with open(sys.argv[1]) as marks:
	for line in marks:
		line =  line.strip()
		linearray = line.split(" ")
		marker = linearray[0]
		scaf = linearray[1]
		position = linearray[2]
		outfile.write(line)
		if scaf in blatdict:
			outfile.write("\t")
			outfile.write(blatdict[scaf])
			outfile.write("\t")
			rnaseqtarget = blatdict[scaf].split("=")  ## Removing the target word from string.
			rnaseq = rnaseqtarget[1]
			print rnaseq
			if rnaseq in aadict:
				aa = aadict[rnaseq]
				outfile.write(aa)
				outfile.write("\t")
				if aa in godict:
					desc=' '.join(godict[aa])
					outfile.write(desc)
		outfile.write("\n")


sys.exit("C'est fin !")

def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

