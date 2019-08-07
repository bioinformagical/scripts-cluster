#!/usr/bin/python

import re
import sys
import die

######      This will read in the orthocluster list file and the interproscan results. 
#	    We red in an interpro Scan result and summarize how many of each type of annotation that we get.
	#
	#
	#	USAGE:    python /home/rreid2/scripts/python/orthoAnnotateAndSequencePull.py ../xyloplax-only-orthoclusters.out ../all-goterms.txt ../final-42orthos.faa 
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

godict = {}
descdict = {}

###########   Read in the GO terms file as a dict.
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
	desc= linearray[12]
	godict[protid]=goterms
	descdict[protid]=desc
	#print "Our Go terms for ",protid," is ",godict[protid]," and the desc is ",desc 


###########     Read in Fasta of all bj (heavily formatted already)  into a fastadict
aadict = {}
aaid = ""
seq = ""
fa_path = sys.argv[3]
with open(sys.argv[3]) as aafile:
	for line in aafile:
		line =  line.strip()
		if ">" in line:
			aaid = line
			aaid = aaid.replace(">","")
			if len(seq) != 0:
				aadict[aaid]=seq
				#print aaid," AND ",seq
				#if aaid in  godict:
				#	print aaid," AND ",descdict[aaid]
				seq = ""
		elif len(line) == 0:
			break
		else:
			seq += line.strip()
#finish the very last sequence
aadict[aaid]=seq

#sys.exit()

############  OPen up the orthocluster list file and go seek the fasta  file it matches  ############
#temp = open(sys.argv[1]).read().splitlines()

taxafile = "../" + sys.argv[1] + "-only-orthoclusters.out"
for f in open(taxafile):
	if f.strip():
		#print f
		f = f.strip()
		f = f.replace("BJ","bj")
		f = f.replace("|m.","|")
		f = f.replace("aa.","")
		f = f.replace("aa","")
		f = f.replace("|","@")
		linearray = f.split(":")
		orthoid=linearray[0]
		orthosarray = linearray[1].split(" ")
		numincluster = len(orthosarray)-1
		#print orthoid," and the size is",numincluster
		count=1
		fileout = "./" + sys.argv[1] + "/" + orthoid + "-" + sys.argv[1] + ".fasta"
		#print fileout
		outfile = open(fileout, 'w')
		while  count < len(orthosarray):
			#print orthosarray[seq].strip()
			if orthosarray[count] in aadict:
				outfile.write(">")
				outfile.write(orthosarray[count])
				if orthosarray[count] in  godict:
					outfile.write("\t")
					outfile.write(godict[orthosarray[count]])
					outfile.write("\t")
					outfile.write(descdict[orthosarray[count]])
				outfile.write("\n")
				outfile.write(aadict[orthosarray[count]])
				outfile.write("\n") 
							#print "Yay we found a GO term for out orthocluster sequence: ",godict[orthosarray[seq]]
			count += 1
			#print len(orthosarray)
		#### Now we traverse the various pathways to get to orthocluster file of interest
		#if numincluster > 30
		#	file1=""
		#elif
		#elif

sys.exit()

def GetSize(Label):
	Fields = Label.split(";")
	for Field in Fields:
		if Field.startswith("size="):
			return int(Field[5:])
	print >> sys.stderr
	print >> sys.stderr, "Size not found in label: " + Label
	sys.exit(1)

