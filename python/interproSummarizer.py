#!/usr/bin/python

import re
import sys
import die

######      This will read in Interpro Scan result and summarize how many of each type of annotation that we get.
	#
	#	USAGE:    python /home/rreid2/scripts/python/interproSummarizer.py ./${file}-iprscan.out
	#
Prefix = ""
print sys.argv[1]
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments!!!")
	#die.Die("Must specify 3 ARGS. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read in interpro results, parse the IDs and add them to a dict and print them.
file1 = open(sys.argv[1])
print sys.argv[1]
prefix=sys.argv[1].split('-')[0]
print prefix

iprdict = {}
pfamdict = {}
prositedict = {}
godict = {}
pantherdict = {}

outipr = prefix + "-ipr.txt"
iprout = open(outipr, 'w')
outpfa = prefix + "-pfam.txt"
pfaout = open(outpfa, 'w')
outpro = prefix + "-prosite.txt"
proout = open(outpro, 'w')
outgo = prefix + "-GOterms.txt"
goout = open(outgo, 'w')
outpan = prefix + "-PANTHER.txt"
panout = open(outpan, 'w')

while 1:
	line = file1.readline()
	if len(line) == 0:
	 	print "Done loading in the interprofile."
		break
	linearray = line.split()
	protid=linearray[0]
	annot = linearray[3]
	id = linearray[4]
	if annot == "PANTHER":
		if id in pantherdict.keys():
			next	
		else:
			panout.write(id)
			panout.write("\n")
			pantherdict[id]=1
	elif annot == "Pfam":
		if id in pfamdict.keys():
			next
		else:
			pfaout.write(id)
			pfaout.write("\n")
			pfamdict[id]=1
			for x in linearray:
				if "IPR" in x:
					if x in iprdict.keys():
						next
					else:
						iprout.write(x)
						iprout.write("\n")
						iprdict[x]=1
				elif "GO:" in x:
					if x in godict.keys():
					        next
					else:
						goout.write(x)
						goout.write("\n")
						godict[x]=1
	elif annot == "ProSiteProfiles":
		if id in prositedict.keys():
			next
		else:
			proout.write(id)
			proout.write("\n")
			prositedict[id]=1 


def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

