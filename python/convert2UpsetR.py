#!/usr/bin/python

import re
import sys
import die

#########################    convert2UpsetR.py ---- Read in table, change the labels        #########################################
##########################################################################################################
######
######		This will read in a big table where genes = rows, columns are a condition
	# 	We are going to:
	#		1. read the line. For each column, if > 0, Write out the ID from Column 1 instead of the number.
	#	USAGE:		 python /users/rreid2/scripts/python/convert2UpsetR.py /Users/rreid2/Documents/tomato/bigtable-snpCountsPerGene-v2.txt
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  making some OUTPUT FILES.
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = "snpcounts-converted2IDs.txt"
#sys.exit()
outfile = open(outname, 'w')


with open(sys.argv[1]) as afile:
	for line in afile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^CHR")
		if pattern.match(line):
			continue
		else:
			linearray = line.split()
			id=linearray[0]
			outfile.write(id)
			#outfile.write("\t")
			for i in range(1, len(linearray)):
				
				outfile.write("\t")
				value=int(linearray[i])
				#print value
				if value > 0:
					outfile.write(id)
				else:
					print "We found a ",linearray[i]
					outfile.write("0")
			outfile.write("\n")
#sys.exit()

print "The Final is done "

def search(values, searchFor,fpkm):
	for k in values:
        	for v in values[k]:
	    		if searchFor in v:
				return max(k,fpkm)
	return None


	

