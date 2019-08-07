#!/usr/bin/python

import re
import sys
import die

#########################3          rebuild Venki        #########################################
##########################################################################################################
######
######			We output it in a venki friendly format.    We read in a file that has coords in the first column. 
######		This will read in a venki file as a hash via it's coords.
	# 	We are going to:
	#		1. For every coord, get the hash results and write to file.
	#	USAGE:		 python ~/scripts/python/rebuildVenkiFromCoord.py noNs-all-venki-guyod.txt deduped-all-venki-guyod.txt   
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! :")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+".venki"
outfile = open(outname, 'w')
#countname=front+"-v2-snppicked-rejected.txt"
#countfile=open(countname, 'w')
counthash = {}

#####   Open COORD file of interest and use column 1 for key value for Dict for checking later if our SNP pick matches
ausshash={}
megapos=-1000
with open(sys.argv[1]) as aussiefile:
	 for line in aussiefile:
	 	line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^#")
		if pattern.match(line):
			continue
		else:
			linearray = line.split()
			##First we are going to throw away any line where the sequence is not 100NT long. Columns 3 is the sequence.
			seq=linearray[2]
			if len(seq) < 100:
				print len(seq)
				#continue
			coord=linearray[0]
			pos=coord.split("-")[1]
			if ((int(pos)-5) < megapos):
				megapos=int(pos)
				continue
			ausshash[coord]=line
			megapos=int(pos)
			#print coord
#sys.exit()			

with open(sys.argv[2]) as aafile:
        for line in aafile:
		line =  line.strip()
		if not line:
			continue
		if line in ausshash:
			outfile.write(ausshash[line])	
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
	

