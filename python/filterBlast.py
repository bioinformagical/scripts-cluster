#!/usr/bin/python

import re
import sys
import die

######      This will read in a tab delimited Blast file and filter by Escore.
	#	USAGE:		 python ~/scripts/python/filterBlast.py  ./someBlastresult.txt 1e-50 

  
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
escore=float(sys.argv[2])
### OUtfile
outname = front+"-byEscore-"+sys.argv[2]+".txt"
outfile = open(outname, 'w')

while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading VCF file !!"
		break
	pattern=re.compile("^#")
	if pattern.match(line):
		outfile.write(line)
		outfile.write("\n")
	else:	
		linearray = line.split()
		escore2=float(linearray[10])
		print escore2
		
		####### Check if escore > escore2 of line
		if escore > escore2:
			outfile.write(line)
			outfile.write("\n")

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

