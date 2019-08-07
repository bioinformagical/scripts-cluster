#!/usr/bin/python

import re
import sys
import die

######      This will read in our mega file of parsed VCF of just 3 columns.
	# 	We are going to make a hash of the 3 columns, key = chrom1-033476-G.
	#	That is not all. Each hash will be counted and the key value will be that count .
	#	USAGE:		 python /home/rreid2/scripts/python/filterVCF-megaCount-banana.py  ./mega-3cols.txt        
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
#file2 = open(sys.argv[2])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-counted.txt"
outfile = open(outname, 'w')
#countname=front+"-chromosomeCounts-byGeneLocation-v2.txt"
#countfile=open(countname, 'w')
#counthash = {}

######   OPEN THAT GFF FILE INTO a BIG ARAY    #####
gffhash = {}
print " Starting the hash build of the SNP coordinates"
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done loading mega file !!"
 		break
	linearray = line.split()
	chromo = linearray[0]
	start = linearray[1]
	snp = linearray[2]
	snparray=snp.split(",")
	nt=snparray[0]
	keyval = chromo +"-"+start+"-"+nt
	if keyval in gffhash.keys():
		count = gffhash[keyval] + 1
		gffhash[keyval] = count
	else:
		gffhash[keyval]=1
		print "new key found: ",keyval

	#print chromo,"\t",start,"\t",stop
	#gffArray.append(linearray)



#sys.exit(1)
print "The size of the GFF hash is ",len(gffhash)

count=0
for key in gffhash.keys():
	countfile.write(key)
	countfile.write("\t")
	countfile.write(str(gffhash[key]))
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

