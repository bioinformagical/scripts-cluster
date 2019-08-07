#!/usr/bin/python

import re
import sys
import die

#		read a VCF, look for the GEne Id in there and remove any duplicates, so we have just unique entities.
#	We read in a GFF file as a list and check the line below to see if it is a duplicate.
	#	USAGE:		 python /home/rreid2/scripts/python/removeGeneDupesFromVCF.py ./${chr}.vcf

Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
#genomesize = sys.argv[4]
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-v2-deduped.vcf"
outfile = open(outname, 'w')
#countname=front+"-v2-snppicked-rejected.txt"


###### Go find the proper SNP / Gene for each interval
currentpos = 0
is2ndgene = 0
ncbihash = {}
### OPen our main VCF file and check if gene region exists for each SNP location 
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading VCF file !!"
		break
	pattern=re.compile("^#")
	if pattern.match(line):
		#outfile.write(line)
		#outfile.write("\n")
		continue
	else:	
		linearray = line.split("\t")
		snp=linearray[3]
		snp2=linearray[4]
		#print len(snp2)," and the SNP is ",snp2
		if (len(snp) >1):
			continue
		if (len(snp2) >1):
			continue
		infocol=linearray[12]
		tmpray=infocol.split(",")[1]
		ncbi=tmpray.split(";")[0]
		ncbi = ncbi.replace("Genbank:","")
		if ncbi in ncbihash:
			print "We found a dupe for Genbank:",ncbi," for the line ",tmpray
		else:
			ncbihash[ncbi]=1
			outfile.write(line)
			outfile.write("\n")

#sys.exit()

print "The Final is done. \n"

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

def getIntervals(genomesize, fastasequence):
	fastasize=len(fastasequence)
	percent=fastasize/genomesize
	## We are calling 15,000 snps. So this is pulling a pecent of those
	numofSNPs=int(15000*percent)
	interval=fastasize/numofSNPs
	count=interval
	countarray =[]
	while (count < fastasize):
		countarray.extend(count)
		count += interval
	return(countarray)
	

