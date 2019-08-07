#!/usr/bin/python

import re
import sys
import die

######      This will read in a megatable file and add up how often each SNP occurs across 95 columns.  We then add the count along with freq (count/95)
	#   Let's add how often we see each type of SNP call (0/1, 2,2, 1*/1), etc.   As a new table.
	#	USAGE:		 python /users/rreid2/scripts/python/addFreq2Megatable.py   masterTrimmed.current  
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
outname = front+"-snp-RowFrequency.txt"
outfile = open(outname, 'w')

#####  Printing a Header
outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
outfile.write("\n")

#####    Read in Master table, add up the SNPs
file2 = open(sys.argv[1])
while 1:
	line = file2.readline()
	line = line.strip('\n')
	if len(line) == 0:
		 print "Done reading master file, We out !!"
		 break
	#print line
	linearray = line.split()
	outfile.write(linearray[0])
	outfile.write("\t")
	count=0
	del linearray[0]
	snpray=[]
	for i in range(9):
		snpray.append(0)
	for i in range(len(linearray)) :
		#count=count+int(linearray[i])	
		if linearray[i] in "0/0":
			snpray[0]=snpray[0]+1
		elif linearray[i] in "0/1":
			snpray[1]=snpray[1]+1
		elif linearray[i] in "0/2":
			snpray[2]=snpray[2]+1
		elif linearray[i] in "1/0":
			snpray[3]=snpray[3]+1
		elif linearray[i] in "1/0":
			snpray[4]=snpray[4]+1
		elif linearray[i] in "1*/1":
			snpray[5]=snpray[5]+1
		elif linearray[i] in "1/1":
			snpray[6]=snpray[6]+1
		elif linearray[i] in "1/2":
			snpray[7]=snpray[7]+1
		elif linearray[i] in "2/2":
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

