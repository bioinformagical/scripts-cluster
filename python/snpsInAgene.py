#!/usr/bin/python

import re
import sys
import die

######      This will read in a VCF file and a GFF file.
	# 	We are going to identify all the regions where there are genes and see if the SNPs fall into those regions. If they do, we write them to a text file.
	#	 keep only the lines where there is a SNP call that lands in a gene region in the GFF.
	#	That is not all. Let's get the number of SNPs per chromosome in a separate counts.txt file..
	#	USAGE:		 python /home/rreid2/scripts/python/snpsInAgene.py  ./someVCFFile.vcf /Volumes/Promise Pegasus/oat/temp-banana/db/musa_acuminata_v2.gff3

  
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 1 or len(sys.argv) < 1 ):
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
	else	
		linearray = line.split()
		snp=linearray[4]
		infocol=linearray[7]
		infocolarray=infocol.split(":,=")
		dp=infocolarray[1]
		
		####### Check if dp > threshold
		threshold=sys.argv[2]
		if dp > threshold:
			outfile.write(line)
			outfile.write("\n")
 			chrome=linearray[0]
			if exists counthash[chrome]:
				tmp=counthash[chrome]
				tmp2=tmp+1
				counthash[chrome]=tmp2
			else
				counthash[chrome]=1;} 
count=0
for key in counthash.keys():
	countfile.write(key)
	countfile.write("\t")
	countfile.write(counthash[key])
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

