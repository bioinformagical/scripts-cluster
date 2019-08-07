#!/usr/bin/python

import re
import sys
import die

######      This will read in an exonerate file that has a special fasta sequence in it.
	#
	#
	#	USAGE:    python /home/rreid2/scripts/python/parseSpecialExoner8-4fasta.py est-kc-take6-split-perc70.txt 
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
prefix=sys.argv[1].split('.')[0]
#print prefix

outgo = prefix + "-justfasta.fna"
goout = open(outgo, 'w')
writeflag = 0
with open(sys.argv[1]) as fp:
    for line in fp:
    	#print line
#	line = file1.readline()
	if len(line.strip()) == 0:
		writeflag = 0
	if  line.startswith('>'):
		goout.write(line)
		writeflag = 1
	elif writeflag == 1:
		goout.write(line)
		



