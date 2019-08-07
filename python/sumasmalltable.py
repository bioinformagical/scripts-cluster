#!/usr/bin/python

import re
import sys
import die

######      This will read in a table and a add the columns and make a new column of the sums. 
	#	USAGE:		 python ~/scripts/python/umasmalltable.py /nobackup/banana_genome/indieVCF/just7-14/all7-hetpaste.txt 


Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]


#### Read in the VCF file into a dict by coord in this format:   chr01-10156575
file1 = open(sys.argv[1])
print sys.argv[1]
nameray=sys.argv[1].split('.')
outname = nameray[0]+"-summed.txt"
outfile = open(outname, 'w')

header = line = file1.readline()
outfile.write(header)

countray=[0,0,0,0,0,0,0,0]
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
        	print "Done loading VCF file !!"
          	break
	pattern=re.compile("^#")
	if pattern.match(line):
        	continue
	linearray = line.split()
        sum=int(linearray[7]) + int(linearray[1]) + int(linearray[2]) + int(linearray[3]) + int(linearray[4]) + int(linearray[5]) + int(linearray[6])
	
	countray[sum]= countray[sum]+1
	outfile.write(line)
	outfile.write("\t")
	outfile.write(str(sum))
	outfile.write("\n")

	
print countray
print "Done loading Master File , FIN."

def search(values, searchFor,fpkm):
	for k in values:
        	for v in values[k]:
	    		if searchFor in v:
				return max(k,fpkm)
	return None


def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

