#!/usr/bin/python

import re
import sys
import die

######      This will read in a VCF file
	# 	We are going to keep only the lines where the SNP call does not fall in a repeat Coordinate.
	#	That is not all. Let's get the number of SNPs per chromosome in a separate counts.txt file..
	#	We read in a GFF file as a list that we need to iterate through for each SNP call and see if it is in the range.
	#	USAGE:		 python /home/rreid2/scripts/python/filterVCF-byRepeat-banana.py  ./someVCFFile.vcf /scratch/rreid2/banana/repeat/red/repeatdir/pahang-reference-link.rpt

Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read kaas FPKM  Table in, parse the line to get kaas id and FPKM and add them to a dict.
file1 = open(sys.argv[1])
file2 = open(sys.argv[2])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = front+"-byRepeat.vcf"
outfile = open(outname, 'w')
countname=front+"-chromosomeCounts-byRepeat.txt"
countfile=open(countname, 'w')
counthash = {}


######   OPEN THAT GFF FILE INTO a BIG ARAY    #####
gffArray = []
gffhash = {}
while 1:
	line = file2.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done loading mRNA GFF file !!"
 		break
	linearray = line.split()
	chromo = linearray[0]
	start = linearray[3]
	repeat = linearray[10]
	chromarray = repeat.split(":")
	chromo = chromarray[0]
	repregion = chromarray[1]
	if chromo in gffhash.keys():
		gffhash[chromo].append(repregion)
	else:
		gffhash[chromo]=[]
		gffhash[chromo].append(repregion)
	#print chromo,"\t",start,"\t",repeat
	#gffArray.append(linearray)



#sys.exit(1)
print "The size of the repeat table is ",len(gffArray)

### OPen our main VCF file and check if gene region exists for each SNP location 
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading VCF file !!"
		break
	pattern=re.compile("^#")
	if pattern.match(line):
		#outfile.write(line)
		#outfile.write("\n")
		continue
	else:	
		linearray = line.split()
		snp=linearray[4]
		infocol=linearray[7]
		chromo = linearray[0].replace("r0","r")  ##This is match up chr from repeat results.
		pos = linearray[1]
		isrepeat = False
		for x in gffhash[chromo]:
		## Interate through GFF array and look for matches
		#for x in gffArray:
		#	if chromo in x[0]:
			startstop = x.split("-")
			start=int(startstop[0])
			stop=int(startstop[1])
			if ((int(pos) > start)  and (int(pos) < stop)):
				isrepeat = True
				print chromo,"\t",pos,"\t",start,"\t",stop
		if (isrepeat == False):
			outfile.write(line)
			outfile.write("\t")
			outfile.write(x[3])
			outfile.write("\t")
			outfile.write(x[4])
			outfile.write("\t")
			outfile.write("%s" % x[8:])
			outfile.write("\n")
			#sys.exit(1)
			chrome=linearray[0]
			if chrome in counthash:
				counthash[chrome] += 1
			else:
				counthash[chrome]=1 
count=0
for key in counthash.keys():
	countfile.write(key)
	countfile.write("\t")
	countfile.write(str(counthash[key]))
	countfile.write("\n")
	count =+1	
print "The Final OVERALL count is ",count,"\n"

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

