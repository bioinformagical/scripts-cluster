#!/usr/bin/python

import re
import sys
import die

######      This will read in a VCF file and add each coord to a new column file.
	#	Read in VCF file as a hash.
	#	Raed in haps.txt file as a hash, making entry for every sequence in the range that matters.
	# 	We are going to keep all the lines, not just true SNPs.
	#	We read in mega table, read each line, see if there is haps.txt presence, otherwise 0/0.  Then see if there is VCF snp call.. then might be 1/0, 1/1. 2/2. etc.....
	#	USAGE:		 python /users/rreid2/scripts/python/inbred-makeColumns4Table.py oran_cas_33_S87_L008 masterTrimmed.now  
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 3 or len(sys.argv) < 3 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Table in, parse the line.
file1 = open( "/nobackup/rogers_research/rob/gatk/gatk-dsant/vcf_emit_all_sites_files/dsant-rgrouped-"+sys.argv[1]+".raw.vcf")
print sys.argv[1]
tmp=sys.argv[2]
#tmparray=tmp.split(".")
#front=tmparray[0]
### Load hash with chrom-position for each line of VCF
outname = sys.argv[1]+"-"+sys.argv[2]
outfile = open(outname, 'w')
### Print the column header
#outfile.write(sys.argv[1]+"-"+sys.argv[2])
#outfile.write("\n")
#counthash = {}
snphash = {}
print "Starting to read in VCf file for "+sys.argv[1]
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
		info=linearray[9]
		genotype=info.split((":")[0])
		#print genotype[0]
		call=genotype[0]
		if "1/2" in call:
			call="0/1"
		elif "0/0" in call:
			call="0/0"
		elif "1/1" in call:
			call="1/1"
		elif "0/1" in call:
			call="0/1"
		else:
			call="0/0"
		
		#if not "1/1" in call:
		#	if not "0/1" in call:
		#		if not "0/0" in call:
		#			print genotype[0]+" or "+call
		#			sys.exit("We have info type issue in the VCF file!")
		snphash[snpid]=call
		####### Check if snp exists already.
		#pattern2 = re.compile("[A,C,G,T]")
		#if pattern2.match(snp):
			#outfile.write(line)
			#outfile.write("\n")
 		#	chrome=linearray[0]
	#		if chrome in counthash:
	#			counthash[chrome] += 1
	#		else:
	#			counthash[chrome]=1
#sys.exit("Oy!")

#### Load hash of the haps.txt file. 1 for every position in each range
filehaps = open("/nobackup/rogers_research/rob/inbred/vcf-megatable/hapsFiles/"+sys.argv[1]+"_haps.txt")
hapshash={}
print "Starting to read in .hsp file for "+sys.argv[1]
while 1:        
	line = filehaps.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done reading haps file, We out !!"
		break
	linearray = line.split()
	chrom=linearray[0]
	pos=linearray[1]
	inbredtype=linearray[2]
	#print inbredtype
	if not "nbred" or not "etero" in inbredtype:
		print inbredtype
		sys.exit("We have inbred type issue in the hap.txt file!")
	start=int(pos)
	stop=int(linearray[3])
	snpid=chrom+"-"+pos
	if snpid in hapshash:
		next
	while start < stop:
		snpid=chrom+"-"+str(start)
		hapshash[snpid]=inbredtype
		start=start+1
		#print start
	#print "done with "+snpid
#die "lets stop for now"
#sys.exit("Oy!")

#####    Read in Master table, Check each line if we have SNP
print "Starting to read Master file and writing out the snp calls"
file2 = open(sys.argv[2])
count=0
while 1:
	count=count+1
	line = file2.readline()
	line = line.strip('\n')
	if len(line) == 0:
		 print "Done reading master file, We out !!"
		 break
	#print line
	linearray = line.split()
	###    These 2 lines are no longer needed, it is no longer a master table.
	#outfile.write(line)
	#outfile.write("\t")
	call="OOPS"
	if not linearray[0] in hapshash:
		#print "WE ARE NOT IN THE HAPSHASH"
		if linearray[0] in snphash.keys():
			if ("0/1" in snphash[linearray[0]]):
				call="1/0"
			elif "1/1" in snphash[linearray[0]]:
				call="2/0"
			elif "0/0" in snphash[linearray[0]]:
				call="0/0"
			else:
				call="0/0"
		else:
			call="0/0"
	elif linearray[0] in  snphash:
		#print "WE ARE IN THE HAPSHASH and the SNP hash"
		#print "We found a snp for ",line
		#if "0/0" in snphash[linearray[0]]:
		#	if "inbred" in hapshash[linearray[0]]:
                #        	outfile.write("??")
                #	elif "hetero" in [linearray[0]]:
                #        	outfile.write("1/2")
		if "0/1" in snphash[linearray[0]]:
			if "nbred" in hapshash[linearray[0]]:
                        	call="1*/1"
                	elif "etero" in [linearray[0]]:
                        	call="1/2"
		elif "1/1" in snphash[linearray[0]]:
			if "nbred" in hapshash[linearray[0]]:
                        	call="1/1"
                	elif "etero" in [linearray[0]]:
                        	call="2/2"
		elif "0/0" in snphash[linearray[0]]:
			call="0/0"
		else:
			call="0/0"
	else:
		#print "WE ARE IN THE HAPSHASH But no SNP hash"
		if "nbred" in hapshash[linearray[0]]:
			call="0/1"
		elif "etero" in hapshash[linearray[0]]:
			call="0/2"
		else:
			print "time to DUMP!!!!"
			print "linearray[0]"
			print hapshash[linearray[0]]
			sys.exit("Oy! Neither hetero nor inbred found in hash")
	if "OOPS" in call:
		#print str(count)
		#print linearray[0]
		#sys.exit("Oy! We still have an OOPs")
		call="0/0"
	outfile.write(call)
	outfile.write("\n")

##### Get some stats too
#count=0				 
#for key in counthash.keys():
#	countfile.write(key)
#	countfile.write("\t")
#	#countfile.seek(0)
#	countfile.write(str(counthash[key]))
#	countfile.write("\n")
#	count=count+1
#print "The Final OVERALL count is ",count,"\n"

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

