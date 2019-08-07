#!/usr/bin/python

import re
import sys
import die

#########################    vcf-file-breakdown.py ---- This Breaks down VCF file for Nick's subsequent steps in popGen magic        #########################################
##########################################################################################################
######
	#	USAGE:		 python /users/rreid2/scripts/python/vcf-file-breakdown.py /nobackup/rogers_research/rob/mayotte/gatk/03_S21-gatk.vcf
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
outname = front+"-nicked.txt"
#sys.exit()
outfile = open(outname, 'w')

with open(sys.argv[1]) as afile:
	for line in afile:
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


#sys.exit()

print "The Final is done "

def search(values, searchFor,fpkm):
	for k in values:
        	for v in values[k]:
	    		if searchFor in v:
				return max(k,fpkm)
	return None


	

