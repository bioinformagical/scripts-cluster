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
if (len(sys.argv) > 4 or len(sys.argv) < 4 ):
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

with open(sys.argv[2]) as fp:
    for line in fp:
    	#print line
#	line = file1.readline()
#	if len(line) == 0:
#	 	print "Done loading in the interprofile."
#		break
	linearray = line.split("\t")
	protid=linearray[0]
	goterms = linearray[13]
	godict[protid]=goterms
	#print "Our Go terms for ",protid," is ",godict[protid] 

############  OPen up a taxa list and make that an array    ############
#temp = open(sys.argv[1]).read().splitlines()
taxaids = []
taxafile = sys.argv[1] + ".txt"
for f in open(taxafile):
	if f.strip():
		#print f
		f = f.strip()
		f = f.replace("bj","")
		taxaids.append(int(f))
		print f

###########  Iterate through each orthocluster and see if it matches the criteria    #############
#orthofile = open(sys.argv[3])
orthodict = {}
outname = sys.argv[1] +"-only-orthoclusters.out"
outfile = open(outname, 'w')
nohit = sys.argv[3] +"-nohits.txt"
nohitfile = open(nohit, 'w')

with open(sys.argv[3]) as ort:
	for line in ort:
		goodortho = "true"
		line=line.strip('\n')
		linearray = line.split(": ")
		echinoid = linearray[0]
		seqarray = linearray[1].split(" ")
		#print echinoid 
		for prot in seqarray:
			prot = prot.lower().strip()
			prot = prot.replace("aa.","")
			prot = prot.replace("m.", "")
			prot = prot.replace("bj","")
			#print prot
			bjray = prot.split("|")
			bj = bjray[0].strip()
			if len(bj) == 0:
				print "prot is empty !",prot
				sys.exit( "We have died by a ZERO in bj: " )
			if (bj == "refseqSpurp") or (bj =="refseqspurp") :
				bj = 9
			#print bj
			#print int(bj) 
			tmptrue = "false"
			for id in taxaids:
				#id.strip()
				if int(bj) == id: 
					#print " The bj found is ",bj," so we can make it true"
					tmptrue = "true"
			if tmptrue == "false":
				goodortho="false"
		if goodortho == "false":
		 	print " no match"
			nohitfile.write(line)
			nohitfile.write("\n")
		elif goodortho == "true":
			print "This ortho MATCHES :   ",line  
			orthodict[echinoid]=seqarray
			outfile.write(line)
			outfile.write("\n")

def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

