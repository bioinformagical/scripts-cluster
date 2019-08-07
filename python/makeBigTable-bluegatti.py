#!/usr/bin/python

import re
import sys
import die

######      This will read in 2 files,  a master table and an interproscan file.
	#	
	#	Master table to hold all of the data and we will add the annotation info to that table.
	#	Result will be new Master table with annotations. At teh same time, we are going to filter the master table
	#	USAGE:		 python /home/rreid2/scripts/python/makeBigTable-bluegatti.py  ./matrix2.txt ./prosite-ipr-annotations.txt
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Interproscan Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[2])
print sys.argv[2]
interdict = {}
descdict = {}
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading hash of interpro !!"
		break
	linearray = line.split("\t")
	id=linearray[0]
	desc=linearray[5]
	interproid=linearray[11]
	gene = id.split("::")[0].strip()	
	interdict[gene] =interproid
	descdict[gene] = desc 
	print "Gene ID = ",gene,"\t and INterpro ID value = ",interproid," and desc =",desc
#sys.exit()


file2 = open(sys.argv[1])
### OUtfile
outname = sys.argv[1]+".new"
outfile = open(outname, 'w')

##### Append header with new column name
header = file2.readline().strip('\n') + "\t" + sys.argv[2]
outfile.write("Contig ID\tInterproscan ID\tAnnotation Description\t")
outfile.write(header)
outfile.write("\n")

##### read in Master table line by line, and append a interdict where needed, or add "NA".
while 1:
	line = file2.readline()
	line = line.strip('\n')
	#outfile.write(line)
	#outfile.write("\t")
	if len(line) == 0:
	        print "Done Reading Master table  !!"
		break
	linearray = line.split("\t")
	fpkmsum=linearray[25].strip()
	if fpkmsum > 500:
		gene= linearray[0].strip()
		#outfile.write(line)
		#outfile.write("\t")

		#k = kegg.split()[0].strip()
		#print "Kaas in master table is ",kegg," but we can't seem to find it in dict."
		if gene in interdict.keys():
			outfile.write(gene)
			outfile.write("\t")
			outfile.write(interdict[gene])
			outfile.write("\t")
			outfile.write(descdict[gene])
			outfile.write("\t")
			numcolumns=len(linearray)-1
			for i in range(numcolumns):
				outfile.write(linearray[i+1])
				outfile.write("\t")
			outfile.write("\n")
		else:
			#outfile.write("0")	
			print("Could not find " + gene)

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

