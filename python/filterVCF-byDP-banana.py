#!/usr/bin/python

import re
import sys
import die

######      This will read in a VCF file
	# 	We are going to keep only the lines where there is a SNP call in column 5.
	#	That is not all. Let's get the number of SNPs per chromosome in a separate counts.txt file..
	#	USAGE:		 python /home/rreid2/scripts/python/filterVCF-byDP-banana.py  ./someVCFFile.vcf 10     (The 10 in this case is the DP threshold.....)  
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
### OUtfile
outname = front+"-byDP.vcf"
outfile = open(outname, 'w')
countname=front+"-chromosomeCounts-byDP.txt"
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
		infocol=linearray[7]
		infocolarray=infocol.split(";")
		infocol2=infocolarray[5].split("=")
		#print infocolarray[0]
		dp=infocol2[1]
		print infocolarray[5]," and the DP is ",dp	
		####### Check if dp > threshold
		threshold=sys.argv[2]
		if dp > threshold:
			outfile.write(line)
			outfile.write("\n")
 			chrome=linearray[0]
			if chrome in counthash:
				counthash[chrome] += 1
			else:
				counthash[chrome]=1 
count=0
for key in counthash.keys():
	countfile.write(key)
	countfile.write("\t")
	countfile.write(str(counthash[key]))
	countfile.write("\n")
	count =+1	
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

