#!/usr/bin/python

import re
import sys
import die

######      This will read in a mastersnp file of 1's and 0's and add up how many 1's we have on each line and append that to the end of the line
	#	We will aso track how many of each count we get and print that to a new file at the end. 
	#	USAGE:		 python ~/scripts/python/countSNPs.py megamaster-v2.txt 


Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]


#### Read in the VCF file into a dict by coord in this format:   chr01-10156575
file1 = open(sys.argv[1])
print sys.argv[1]
nameray=sys.argv[1].split('/')
#print nameray[7]
#name=nameray[7].split("-")[0]
counthash = {}
outname = sys.argv[1]+"-counted.txt"
outfile = open(outname, 'w')

header=file1.readline().strip('\n')
outfile.write(header)
outfile.write("\tCOUNT")
outfile.write("\n")


while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
        	print "Done loading master file !!"
          	break
	linearray = line.split()
        lin=''.join(linearray[1:])
	#print lin
	count=lin.count('1')
	#print count
	#if (count > 6):
	#	print count
	scount=str(count)
	if (count > 6):
		outfile.write(line)
		outfile.write("\t")
		outfile.write(scount)
		outfile.write("\n")
	chrome=linearray[0]
	position=linearray[1]
	pos=chrome + "-" + position
	if scount in counthash:
		tmp=counthash[scount]
		tmp += 1
		counthash[scount]=tmp
	else:
		counthash[scount]=1
#sys.exit(0)

outname2 = sys.argv[1]+"-histogram.txt"
outfile2 = open(outname2, 'w')

for c in counthash:
	outfile2.write(c)
	outfile2.write("\t")
	outfile2.write(str(counthash[c]))
	outfile2.write("\n")

	
print "Done writing Hisotgram File , FIN."

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

