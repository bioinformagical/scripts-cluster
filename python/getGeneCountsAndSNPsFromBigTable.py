#!/usr/bin/python

import re
import sys
import die

######      This will read in a table and a add the columns and make a new column of the sums. 
	#	USAGE:		 python ~/scripts/python/umasmalltable.py /nobackup/banana_genome/indieVCF/just7-14/all7-hetpaste.txt 10 


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
nameray=sys.argv[1].split('.')
outname = "geneSNPCounts-"+sys.argv[2]+".txt"

outfile = open(outname, 'w')

header = file1.readline()
file1.readline()

#outfile.write(header)

cutoff=int(sys.argv[2])
countray=[0,0,0,0,0,0,0,0]
pollencount=0
piscount=0
polnag=0
polmal=0
polm82=0
pisnag=0
pismal=0
pism82=0
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
        	print "Done loading big SNP gene expression table file !!"
          	break
	pattern=re.compile("^#")
	if pattern.match(line):
        	continue
	linearray = line.split()
        #print linearray
        nagsnp=int(linearray[1])
        malsnp=int(linearray[2])
        m82snp=int(linearray[3])
        pollen1=int(linearray[7])
        pollen2=int(linearray[8])
        pollen3=int(linearray[9])
        pis1=int(linearray[10])
        pis2=int(linearray[11])
        pis3=int(linearray[12])


        ## Check pollen COunts are high enough
        if pollen1 > cutoff  and pollen2 > cutoff and pollen3 > cutoff:
            pollencount += 1
            if nagsnp > 0:
                polnag += 1
            if malsnp > 0:
                polmal += 1
            if m82snp > 0:
                polm82 += 1
        if pis1 > cutoff  and pis2 > cutoff and pis3 > cutoff:
            piscount += 1
            if nagsnp > 0:
                pisnag += 1
            if malsnp > 0:
                pismal += 1
            if m82snp > 0:
                pism82 += 1

        ## Check Pistils

	
print "Summary of ",sys.argv[2]
print "Malintka:\t",pollencount,"\t",polmal,"\t",piscount,"\t",pismal
print "Nagcarlang:\t",pollencount,"\t",polnag,"\t",piscount,"\t",pisnag
print "M82:\t",pollencount,"\t",polm82,"\t",piscount,"\t",pism82

print "Done  File , FIN."

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

