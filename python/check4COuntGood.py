#!/usr/bin/python

import re
import sys
import die

######      This will 1.   read in just7-14-locations.txt (SNPs that in gene region and we see at least 7-14  SNPs across the 18 vatietiesl
######		2.    Read in VCF file to get Banana ID   and the coords.
######		3.    Read in GOI file and read in the ID.
######		4.    If there is a match to the VCF ID, we then check each postion within the range of the VCF to see if it matches the just7-14 hash. If yes, PRINT !!
######		We will aso track how many of each count we get and print that to a new file at the end. 
	#	USAGE:		 python ~/scripts/python/check4COuntGood.py just7-14-locations.txt 3master.txt /nobackup/banana_genome/scratch/db/bananagenomehub/pahang-v2/geneID-mRNA-musa_acuminata_v2.gff3 


Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 4 or len(sys.argv) < 4 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]


#### Read in the just7-14 file into a dict by coord in this format:   chr01-10156575
file1 = open(sys.argv[1])
print sys.argv[1]
nameray=sys.argv[1].split('/')
#print nameray[7]
#name=nameray[7].split("-")[0]
counthash = {}
poshash={}
idhash={}
outname = sys.argv[2]+"-just7-14.txt"
heatmapname = sys.argv[2]+"-heatmap.txt"
outfile = open(outname, 'w')
heatfile = open(heatmapname, 'w')

#header=file1.readline().strip('\n')
#outfile.write(header)
#outfile.write("\tCOUNT")
#outfile.write("\n")

######################     just7-14
while 1:
	line = file1.readline()
	line = line.strip('\n')
	if len(line) == 0:
        	print "Done loading just7-14 file !!"
          	break
	linearray = line.split()
	pos=linearray[0]
	#print pos
	poshash[pos]=line
#sys.exit(0)
print " The just7-14 posh hash should be 829276 and the size is  ", len(poshash)
#### Load in GFF file, 



outname2 = sys.argv[2]+"-ChromosomeCount.txt"
outfile2 = open(outname2, 'w')
file3 = open(sys.argv[3])

#####################	  Original GFF FILE LOAD	
while 1:
	line = file3.readline()
	line = line.strip('\n')
 	if len(line) == 0:
      		print "Done loading master file !!"
                break
        linearray = line.split()
        pos=linearray[0]
	start=int(linearray[3])
	stop=int(linearray[4])
	info=linearray[8]
	id=info.split("=")[1].split(";")[0]
	idhash[id]=[start,stop]
	#print id
#sys.exit(0)
#### open the 3master and get all the cords for that gene, and then check if the cords exist in the just7-14.
file2=open(sys.argv[2])
while 1:
	line = file2.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done loading master file !!"
		break
	linearray = line.split()
	pos=linearray[0]
	chr=pos.split("-")[0]
	id=linearray[14].split("=")[1].split(";")[0]
	#print id
	#sys.exit(0)
	if id in idhash:
		count=idhash[id][0]
		stoop=idhash[id][1]
		while (count < stoop):
			tmpid=chr+"-"+str(count)
			#print tmpid
			if tmpid in poshash:
				#count = idhash[id][1]
				del idhash[id]
				outfile.write(tmpid)
				outfile.write("\t")
				therest='\t'.join(linearray[1:])
				outfile.write(therest)
				outfile.write("\n")
				heatfile.write(poshash[tmpid])
				heatfile.write("\n")
				chr=pos.split("-")[0]
				if chr in counthash:
					tmp = counthash[chr]
					tmp += 1
					counthash[chr] = tmp
				else:
					counthash[chr] = 1
				count = stoop + 1
				del poshash[tmpid]
			count += 1
#sys.exit(0)			

for c in counthash:
	outfile2.write(c)
	outfile2.write("\t")
	outfile2.write(str(counthash[c]))
	outfile2.write("\n")

	
print "Done writing Hisotgram File , FIN."

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

