#!/usr/bin/python

import re
import sys
import die

######      This will read in 2 files
	#	Stage Gage result  table that has KEGG pathways and q-score and Set size   (K00XXXXX  )   
	#	That will become  dict. pathway/set size q-value
	#	Master Pathway table to hold all of the data
	#	Result will be new Master table with aa new column appended.
	#	USAGE:		 python /home/rreid2/scripts/python/makeBigPathwayTable-bbgageNull.py  ./null2ripe.greater.txt.txt  ./masterTable.txt
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
print sys.argv[1]
gagedict = {}
header = file1.readline().strip('\n')
stage = header.split()[-1]
stage = re.split(r'_',stage)[1]
print header
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading hash of kaas IDs !!"
		break
	linearray = re.split(r'\t+',line)
	linearray2 = line.split()
	keggid=linearray2[0]
	qval=linearray[4]
	if qval == "NA":
		qval="0"
 	elif float(qval) < 0.1:
		qval = "1"
	else:
		qval = "0"
	setsize = linearray[5]
	gagedict[keggid]=qval
	print "Kegg ID = ",keggid,"\t and qval value = ",qval

file2 = open(sys.argv[2])
### OUtfile
outname = "masterTable.txt.new"
outfile = open(outname, 'w')

##### Append header with new column name
header = file2.readline().strip('\n') + "\t" + stage
outfile.write(header)
outfile.write("\n")

##### read in Master table line by line, and append a gagedict where needed, or add a 0.
while 1:
	line = file2.readline()
	line = line.strip('\n')
	outfile.write(line)
	outfile.write("\t")
	if len(line) == 0:
	        print "Done Reading Master table  !!"
		break
	linearray = line.split()
	#keggset = linearray[0].strip()
	print line
	keggid = linearray[0].strip()
	#print "Kegg in master table is ",keggid," but we can't seem to find it in dict."
	if keggid in gagedict.keys():
		outfile.write(gagedict[keggid])
	else:
		outfile.write("0")	

	outfile.write("\n")



def checkCutoff( qval ):
	if qval < 0.1:
		return "1"
	else:
		return "0"
	return None

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

