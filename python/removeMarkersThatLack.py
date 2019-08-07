#!/usr/bin/python

import re
import sys
import die

######      This will read in tab delimited GBS marker hapmap file (eg from brassica)
	#	Going to remove all markers that have not at least 30% of the individuals present (No idea if this should be 30,50, 90%)
	#	USAGE:    python /Users/rreid2/scripts/python/removeMarkersThatLack.py ./finalhapMaptable.txt
	#
Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 2 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read .tab in, parse the line, count the number of NA's or in this case"." and then write .csv if there are enough .
file1 = open(sys.argv[1])
print sys.argv[1]
#### OUTFILE
outname = sys.argv[1] + "-removedSOME.txt"
target = open(outname, 'w')

### Count Number of columns and write header to file.
header = file1.readline()
headarray = header.split()
numcolumns = len(headarray)
cutoff = 0.2 * numcolumns
target.write(header) #### Writing header

### Time to check each line
for line in file1:
	#line = line
	linearray = line.split()
	cnt=0
	for i in linearray:
		if i == ".":
			cnt += 1
	if (cnt < cutoff):
		target.write(line)
		#print line
	print " We ended with a count size of ",cnt
print "The End, and the cutoff was ",cutoff

def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

