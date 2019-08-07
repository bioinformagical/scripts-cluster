#!/usr/bin/python

import re
import sys
import die

######      This will read in a taxa list file from Greg that contains some echinos.
#	    We red in an interpro Scan result and summarize how many of each type of annotation that we get.
	#
	#
	#	USAGE:    python /home/rreid2/scripts/python/orthohunt.py crinoids.txt ./all-goterms.txt echinomcl-clean.txt
	#
	#
#Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read in interpro results, parse the IDs and add them to a dictm.
#file1 = open(sys.argv[2])
#print sys.argv[2]
#prefix=sys.argv[1].split('-')[0]
#print prefix

iprdict = {}
pfamdict = {}
prositedict = {}
godict = {}
pantherdict = {}

#outgo = prefix + "-GOterms.txt"
#goout = open(outgo, 'w')

outname = sys.argv[1] +".xml"
outfile = open(outname, 'w')
outfile.write("<files>")
outfile.write("\n")

with open(sys.argv[1]) as fp:
    for line in fp:
	line =  line.strip()
	print line
#	line = file1.readline()
#	if len(line) == 0:
#	 	print "Done loading in the interprofile."
#		break
	linearray = line.split("\t")
	filename=linearray[0]
	name = linearray[1]
	outfile.write("<file name=\"")
	outfile.write(filename)
	outfile.write("\"\n")
	outfile.write("title=\"")
	outfile.write(name)
	outfile.write("\"\n")
	outfile.write("description=\"")
	outfile.write(name)
	outfile.write("\"\n")
	outfile.write("background=\"FFFFFF\"\n")
	outfile.write("foreground=\"0000FF\"\n")
	outfile.write("max_depth=\"15\"\n")
	outfile.write("name_size=\"12\"/>\n")
	

outfile.write("</files>")
outfile.write("\n")


def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

