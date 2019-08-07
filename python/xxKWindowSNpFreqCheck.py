#!/usr/bin/python

import re
import sys
import die

######      This will read in a column file and calculate the number of SNPs per 10KB window. 
	#   Let's add how often we see each type of SNP call (0/1, 2,2, 1*/1), etc.   As a new table.
	#	USAGE:		 python /users/rreid2/scripts/python/xxKWindowSNpFreqCheck.py  Green_1_7__1_S67_L007-col.txt ../masterTrimmed.orig 
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Table in, parse the line.
file1 = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### Load hash with chrom-position
outname = front+"-10KWindow-SNPFreq.txt"
outfile = open(outname, 'w')

#####  Printing a Header
#outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
#outfile.write("\n")

#####    Read in Master table, 
file2 = open(sys.argv[1])
filemaster = open(sys.argv[2])
startcount=0
stopcount=10000
currentcount=0
chrom="2L"
while 1:
	line = file2.readline()
	linecount = filemaster.readline()
	positionray=linecount.split()[0]
	posray=positionray.split("-")
	pos=int(posray[1])
	newchrom=posray[0]
	if (newchrom not in chrom):
		startcount=0
		stopcount=10000
		currentcount=pos
	
	line = line.strip('\n')
	if len(line) == 0:
		 print "Done reading master file, We out !!"
		 break
	#print line
	linearray = line.split()

	#outfile.write(linearray[0])
	#outfile.write("\t")
	#count=0
	#del linearray[0]
	if linearray[0] in "0/0":
		next
	elif linearray[0] in "0/1":
		next
	elif linearray[0] in "0/2":
		next
	elif linearray[0] in "1/0":
		currentcount=currentcount+1
	elif linearray[0] in "1/0":
		snpray[4]=snpray[4]+1
	elif linearray[0] in "1*/1":
		snpray[5]=snpray[5]+1
	elif linearray[0] in "1/1":
		snpray[6]=snpray[6]+1
	elif linearray[0] in "1/2":
		snpray[7]=snpray[7]+1
	elif linearray[0] in "2/2":
		snpray[8]=snpray[8]+1

	for i in range(len(snpray)):
		outfile.write(str(snpray[i]))
		outfile.write("\t")
			
	#outfile.write(str(count))
	#outfile.write("\t")
	#freq=float(count)/95.0
	#print freq
	#outfile.write("{0:0.2f}".format(freq))
	outfile.write("\n")

#print "The Final OVERALL count is ",count,"\n"

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

