#!/usr/bin/python

import re
import sys
import die

######      This will read in 2 files
	#	KAAS ID table that was parsed in previous python script   (K00XXXXX   240.8)   Kegg ID		FPKM score
	#	That will become a dict.
	#	Master table to hold all of the data
	#	Result will be new Master table with aa new column appended.
	#	USAGE:		 python /home/rreid2/scripts/python/makeBigReadCountTable-bbgage.py  ./BJ${i}-kaas-fpkm.txt  ./MASTERTABLE-kaas-fpkm.txt BJ${i}
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 4 or len(sys.argv) < 4 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
kaasdict = {}
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading hash of kaas IDs !!"
		break
	linearray = line.split()
	kaasid=linearray[0]
	fpkm=linearray[1]
	####### Check if dict exists already and if so get the biugger fpkm value using max
	if kaasid in kaasdict.keys():
		bigger = max(kaasdict[kaasid],fpkm) 
		print "We found a a bigger in ",bigger," compared to ", fpkm, " for ",kaasid
		if fpkm > bigger:
			sys.exit("We have a grave error as the bigger one dod not come for ",bigger)
		kaasdict[kaasid]=fpkm
	else:
		kaasdict[kaasid]=fpkm
	#print "KAAS ID = ",kaasid,"\t and FPKM value = ",fpkm

file2 = open(sys.argv[2])
### OUtfile
outname = "MASTERTABLE-kaas-fpkm.new"
outfile = open(outname, 'w')

##### Append header with new column name
header = file2.readline().strip('\n') + "\t" + sys.argv[3]
outfile.write(header)
outfile.write("\n")

##### read in Master table line by line, and append a kaasdict where needed, or add a 0.
while 1:
	line = file2.readline()
	line = line.strip('\n')
	outfile.write(line)
	outfile.write("\t")
	if len(line) == 0:
	        print "Done Reading Master table  !!"
		break
	linearray = line.split()
	kaas = linearray[0].strip()
	#print "Kaas in master table is ",kaas," but we can't seem to find it in dict."
	if kaas in kaasdict.keys():
		outfile.write(kaasdict[kaas])
	else:
		outfile.write("0")	

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

