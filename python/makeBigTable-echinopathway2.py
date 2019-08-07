#!/usr/bin/python

import re
import sys
import die

######      This will read in 2 files,  a master table and a new table that will become a new column in the table
	#	
	#	Master table to hold all of the data
	#	Result will be new Master table with aa new column appended.
	#	USAGE:		 python /home/rreid2/scripts/python/makeBigTable-echinopathway2.py  ./path314-master.txt  ./BJ2.ast
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[2]+".stats.txt")
print sys.argv[2]
keggdict = {}
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading hash of kaas IDs !!"
		break
	linearray = line.split("\t")
	keggid=linearray[0]
	stat=linearray[1]
	keggdict[keggid]=stat
	print "KEGG ID = ",keggid,"\t and stat value = ",stat

file2 = open(sys.argv[1])
### OUtfile
outname = sys.argv[1]+".new"
outfile = open(outname, 'w')

##### Append header with new column name
header = file2.readline().strip('\n') + "\t" + sys.argv[2]
outfile.write(header)
outfile.write("\n")

##### read in Master table line by line, and append a keggdict where needed, or add "NA".
while 1:
	line = file2.readline()
	line = line.strip('\n')
	outfile.write(line)
	outfile.write("\t")
	if len(line) == 0:
	        print "Done Reading Master table  !!"
		break
	linearray = line.split("\t")
	kegg = linearray[0].strip()
	#print "Kaas in master table is ",kaas," but we can't seem to find it in dict."
	if kegg in keggdict.keys():
		outfile.write(keggdict[kegg])
	else:
		#outfile.write("0")	
		sys.exit("Could not find",kegg)
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

