#!/usr/bin/python

import re
import sys
import die

######      This will read in a VCF file and a Master file and the 3master.txt file(This the SNP file to go to Illumina eventually) 
	# 	We are going to add to the master file a new column, for that NCF file.
	#	If the SNP line does not exist, we put a "0". Otherwise we put "1" if found
	#	(we repeat this for all the SNP files we care about.
	#	USAGE:		 python ~/scripts/python/makeMasterSNPFile.py  /scratch/rreid2/banana/align/run3/bygenelocation/someVCFFile.vcf snpmaster.txt 


Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]


#### Read in the VCF file into a dict by coord in this format:   chr01-10156575
file1 = open(sys.argv[1])
print sys.argv[1]
nameray=sys.argv[1].split('/')
print nameray[7]
name=nameray[7].split("-")[0]
vcfhash = {}

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
        chrome=linearray[0]
	position=linearray[1]
	pos=chrome + "-" + position
	#print position," and chrome = ",chrome
	vcfhash[pos]=1
#sys.exit(0)


###  Read Master text file in, print header, print the first part, and then check for pos in dict. Write a 0 or a 1.
file2 = open(sys.argv[2])
print sys.argv[2]
#tmp=sys.argv[1]
#tmparray=tmp.split(".")
#front=tmparray[0]
### OUtfile
outname = sys.argv[2]+"-new.txt"
outfile = open(outname, 'w')

header=file2.readline().strip('\n')+"\t"+name
outfile.write(header)
outfile.write("\n")
print header
#sys.exit(0)

while 1:
	line = file2.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading master file !!"
		break
	#print line		
	linearray = line.split()
	id=linearray[0].strip()
	outfile.write(line)
	outfile.write("\t")

	if id in vcfhash:
		outfile.write("1")
	else:
		outfile.write("0")
	outfile.write("\n")
	
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

