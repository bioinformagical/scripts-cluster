#!/usr/bin/python

import re
import sys
import die

######      This will read in broc.loc (a marker file) and a map file and make A csv delimited suitable for RQTL (Received from Wes for brassica)
	#	USAGE:    python /Users/rreid2/scripts/python/convertAllanData2RQTLformat.py ./broc.loc.new ./map3.map.new
	#
Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 3 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 2 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read in Marker file into a dict. Dict will be marke as key and [chr,postion] . 
file1 = open(sys.argv[1])
print sys.argv[1]
#### OUTFILE
outname = sys.argv[1] + "-forRQTL.txt"
target = open(outname, 'w')

### Initialize chromosome #.
chr=1
markdic = {}
### Time to check each line
for line in file1:
	#line = line
	if line.strip():
		if "group" in line:
			chr += 1
			continue
		linearray = line.split()
		marker = linearray[0]
		pos = linearray[1]
		markdic[marker] = [chr,pos]
## Open genotype file, read each line, addin chr and position and write out each of the ind. genotypes with commas.
file2=open(sys.argv[2])
marker="foo"
geno = ""
for line in file2:
	if not re.match(r'\s', line):
		if marker == "foo":
			continue
		target.write(marker,",",geno)
		markray=line.split()
		marker=markray[0]
		geno=""
	else:
		print geno
		line.replace(" ", "")
		charray=list(line)
		for c in charray:
			geno=geno+","+c
		print geno

	#cnt=0
	#for i in linearray:
	#	if i == ".":
	#		cnt += 1
	#if (cnt < cutoff):
	#	target.write(line)
	#	#print line
	#print " We ended with a count size of ",cnt
print "The End, and the last chromosome was ",chr
file2.close

def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

