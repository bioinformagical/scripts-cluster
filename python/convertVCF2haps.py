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
infile = open(sys.argv[1])

for line in Infile:
	if line[0]!="#":
        	A=line.split()
        	chrom=A[0]
        	pos=int(A[1])
        	hets= A[9][0:3]
#        if hets=="0/0":
#        print>>outfile, chrom, pos, hets
        	if hets== "0/1":
            		print>>outfile, chrom, pos, hets, "he"
        	elif hets== "1/1":
            		print>>outfile, chrom, pos, hets, "ho"
        	else:
            		print>>outfile, chrom, pos, hets, "ref"


