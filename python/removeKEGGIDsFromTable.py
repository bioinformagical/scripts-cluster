#!/usr/bin/python

import re
import sys
import die

######      This will read in 2 files
	#	Master KEGG table
	#	ID list table of KEGG Ids you want removed.
	#	USAGE:    python /Users/rreid2/scripts/python/removeKEGGIDsFromTable.py ./R/justRibosomeKEGGIDs.txt ./MASTERTABLE-kaas-fpkm.txt
	#
Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Fasta in, parse the header to get protein and contig IDs and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
ribo = set()
for line in file1:
	ribo.add(line.strip())
	#print line.strip()

file2 = open(sys.argv[2])
print sys.argv[2]
#### OUTFILE
outname = sys.argv[2] + "-removedSOME.txt"
target = open(outname, 'w')
target.write(file2.readline())

while 1:
	line = file2.readline()
	if len(line) == 0:
	        print "Done loading hash of Nucl-Reads  !!"
		break
	linearray = line.split()
	keggid  = linearray[0]
	print keggid
	if keggid not in ribo:
		target.write(line)

def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

