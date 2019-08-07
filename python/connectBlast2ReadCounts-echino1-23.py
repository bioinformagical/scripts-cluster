#!/usr/bin/python

import re
import sys
import die

######      This will read in 3 files
	#	Protein 2 nt log file that has contig ID and protein ID in header
	#	Blast result file
	#	Read Count File found in /group/janieslab/4db2/readcount
	#
	#	USAGE:    python /home/rreid2/scripts/python/connectBlast2ReadCounts-echino1-23.py ../${num}.logfile.txt ../../4db2/readcount/readspercontig-bj${num}.txt blastname ${num}
	#
Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 5 or len(sys.argv) < 5 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read logfile in, parse the header to get protein and contig IDs and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
aadict = {}
while 1:
	line = file1.readline().rstrip()
	#print line
	if len(line) == 0:
	 	print "Done loading hash of prot - Nucl contigs !!"
		break
	#if ">" not in line: 
	#    continue
	linearray = line.split()
	protid=linearray[0]
	protid = protid.replace(">", "")
	#protidarray = protid.split("|")
	#protid = protidarray[1]
	nuclid=linearray[8]
	tmp = nuclid.split(':')
	nuclid2 = tmp[0] 
	aadict[nuclid2]=protid
	print nuclid2," and Prot ID is",protid
	#print linearray
#sys.exit("Temp stopping !!!")
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
	fpkm = linearray[2]
	#ntdict[contig]=fpkm
	if contig in aadict.keys():
		protreaddict[aadict[contig]]=fpkm
		#print "Contig: ",contig," & FPKM = ",protreaddict[aadict[contig]]


################         READ IN BLAST FILE   AND GET ITS   FPKM VALUE AND PRINT TO NEW FILE     ################################
file3name = sys.argv[3]+".blastp.txt"
file3 = open(file3name)
print sys.argv[3]
print " And now we start writing our results "
outname = "bj" + sys.argv[4] +"-"+ sys.argv[3] + "-blast-fpkm.txt"
target = open(outname, 'w')
while 1:
	line = file3.readline()
	if len(line) == 0:
		break
	linearray = line.split()
	#print linearray
	protarray = linearray[1].split('|')
	prot = protarray[1]
	#print prot
	#kaas = linearray[1]
	if prot in protreaddict.keys():
		print "We just found ",prot
		if sys.argv[4] in  protarray[0]:
			target.write(line.rstrip())
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

