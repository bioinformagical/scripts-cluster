#!/usr/bin/python

import re
import sys
import die

######      This will read in 4 VCF files and add each coord to a big table, the MASTER TABLE, Ooooooh.
	# 	We are going to keep all the lines, not just true SNPs.
	#	That is not all. Let's get the number of SNPs per chromosome in a separate counts.txt file..
	#	USAGE:		 python /users/rreid2/scripts/python/vcf-add2table.py  /nobackup/rogers_research/rob/gatk/gatk-dsant/vcf_emit_all_sites_files/dsant-rgrouped-oran_cas_33_S87_L008.raw.vcf  megatable.txt  
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Table in, parse the line.
file1 = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[2]
tmparray=tmp.split(".")
front=tmparray[0]
### Load hash with chrom-position
outname = front+".new"
outfile = open(outname, 'w')
countname=front+"-chromosomeCounts.txt"
countfile=open(countname, 'w')
counthash = {}
snphash = {}
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
	 	print "Done loading VCF file !!"
		break
	pattern=re.compile("^#")
	if pattern.match(line):
		next
		#outfile.write(line)
		#outfile.write("\n")
	else:	
		linearray = line.split()
		chrom=linearray[0]
		pos=linearray[1]
		snpid=chrom+"-"+pos
		#print snpid
		snp=linearray[4]
		snphash[snpid]=1
		####### Check if snp exists already.
		pattern2 = re.compile("[A,C,G,T]")
		if pattern2.match(snp):
			#outfile.write(line)
			#outfile.write("\n")
 			chrome=linearray[0]
			if chrome in counthash:
				counthash[chrome] += 1
			else:
				counthash[chrome]=1

#####    Read in Master table, Check each line if we have SNP
file2 = open(sys.argv[2])
while 1:
	line = file2.readline()
	line = line.strip('\n')
	if len(line) == 0:
		 print "Done reading master file, We out !!"
		 break
	#print line
	linearray = line.split()
	outfile.write(line)
	outfile.write("\t")
	if linearray[0] in  snphash:
		#print "We found a snp for ",line
		outfile.write("1")
	else:
		outfile.write("0")

	outfile.write("\n")

##### Get some stats too
count=0				 
for key in counthash.keys():
	countfile.write(key)
	countfile.write("\t")
	#countfile.seek(0)
	countfile.write(str(counthash[key]))
	countfile.write("\n")
	count=count+1
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

