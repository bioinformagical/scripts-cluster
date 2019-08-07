#!/usr/bin/python

import re
import sys
import die

######      This will read in a VCF file
	# 	We are going to keep only the lines where there is a SNP call in column 5.
	#	That is not all. Let's get the number of SNPs per chromosome in a separate counts.txt file..
	#	USAGE:		 python /users/rreid2/scripts/python/filterVCF-banana.py  ./someVCFFile.vcf  
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-filth.vcf"
outfile = open(outname, 'w')
countname=front+"-chromosomeCounts.txt"
countfile=open(countname, 'w')
counthash = {}

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
		snp=linearray[4]
		####### Check if snp exists already.
		pattern2 = re.compile("[A,C,G,T]")
		if pattern2.match(snp):
			outfile.write(line)
			outfile.write("\n")
 			chrome=linearray[0]
			if chrome in counthash:
				counthash[chrome] += 1
			else:
				counthash[chrome]=1
##### Get some stats too
count=0				 
for key in counthash.keys():
	countfile.write(key)
	countfile.write("\t")
	#countfile.seek(0)
	countfile.write(str(counthash[key]))
	countfile.write("\n")
	count=count+1
print "The Final OVERALL count is ",count,"\n"

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

