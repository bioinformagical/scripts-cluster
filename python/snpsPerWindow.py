#!/usr/bin/python

import re
import sys
import die

######      This will read in a master table file and calculate the number of SNPs per 10KB window. 
	#   Let's add how often we see each type of SNP call (0/1, 2,2, 1*/1), etc.   As a new table.
	#    0 10000	cavendish	mc1	mc2	mc3	2/3 3/3	all 4	
#	USAGE:		 python /users/rreid2/scripts/python/snpsPerWindow.py ./combined4-sorted.txt 
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  Read Table in, parse the line.
file1 = open(sys.argv[1])
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### Load hash with chrom-position
outname = front+"-10KWindow-SNPFreq.txt"
outfile = open(outname, 'w')

def GetSNPTallies(tenkarray):
        ##      Make the line we need for printing
        ##      cavendish       mc1     mc2     mc3     2/3 3/3 all 4 justCavendish
        ##      2389    1000    899     998     1500
        returnray=[0,0,0,0,0,0,0,0,0]
	#print len(tenkarray)
	#print tenkarray
        #for j in range(0,len(tenkarray)):
	#for j in range(0,20):
	#j=0
	#while j < len(tenkarray):
	for j in tenkarray:
		mcsums=0
                gotcavendish=0
		#print j
		#sys.exit()
                if ("/" in j[0]):
                        returnray[0]+=1
                        mcsums+=1
                if ("/" in j[1]):
                        returnray[1]+=1
                        mcsums+=1
                if ("/" in j[2]):
                        returnray[2]+=1
                        mcsums+=1
                if ("/" in j[3]):
                        returnray[3]+=1
                        gotcavendish+=1
                if (mcsums==0) and (gotcavendish==1):
                        returnray[7]+=1
                elif (mcsums == 3) and (gotcavendish==0):
                        returnray[6]+=1
                elif (mcsums == 2) and (gotcavendish==0):
                        returnray[5]+=1
                elif (mcsums == 1) and (gotcavendish==0):
                        returnray[4]+=1
                elif (mcsums > 0) and (gotcavendish==1):
			returnray[8]+=1
		else:
                        print >> sys.stderr, "Some error in our tenkarray: " + j[0]
                        sys.exit(1)
		#J += 1

        return returnray



#####  Printing a Header
#outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
#outfile.write("\n")

#####    Read in Master table, 
filemaster = open(sys.argv[1])
startcount=0
stopcount=100000
currentcount=0
chrom = "chr01"
tenkarray = []
## Thow away header
header=filemaster.readline()

while 1:
	line = filemaster.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done reading master file, We out !!"
		break
	ray=line.split()
	posray=ray[0].split("-")
	pos=int(posray[1])
	newchrom=posray[0]
	#check if we are at end of chromosome and start a new one if need be
	if (newchrom not in chrom):
		startcount=0
		stopcount=100000
		currentcount=pos
		chrom=newchrom
	
	#print line
	#check if we have 10K range, and if not add array to test array
	range = pos - startcount
	if (pos < stopcount):
		tenkarray.append(ray[1:])
		#print ray[1:]
	elif	(pos > stopcount):
		outfile.write("%s\t"%chrom)
		outfile.write("%i\t"%startcount)
		outfile.write("%i\t"%stopcount)
		stopcount = range+stopcount
		startcount=range
		printray=GetSNPTallies(tenkarray)
		for cb in printray:
			outfile.write("%s\t"%cb)
		#outfile.write(printray)
		outfile.write("\n")
		del tenkarray[:]
		startcount=pos
		stopcount=startcount + 100000
#print "The Final OVERALL count is ",count,"\n"
print "done\n"


def GetSNPTallies(tenkarray):
	## 	Make the line we need for printing
	##	cavendish       mc1     mc2     mc3     2/3 3/3 all 4 justCavendish  
	##	2389	1000	899	998	1500	
	returnray=[0,0,0,0,0,0,0,0]
	for i in range(len(tenkarray)):
		mcsums=0
		gotcavendish=0
		if ("\/" in tenkarray[i][0]):
		 	returnray[0]+=1
			mcsums+=1
		if ("\/" in tenkarray[i][1]):
			returnray[1]+=1
			mcsums+=1
		if ("\/" in tenkarray[i][2]):
			returnray[2]+=1
			mcsums+=1
		if ("\/" in tenkarray[i][3]):
			returnray[3]+=1
			gotcavendish+=1
		if (mcsums==0) and (gotcavendish==1):
			returnray[7]+=1
		elif (msums == 3) and (gotcavendish==0):
			returnray[6]+=1
		elif (msums == 2) and (gotcavendish==0):
			returnray[5]+=1
		elif (msums == 1) and (gotcavendish==0):
			returnray[4]+=1
		else:
			print >> sys.stderr, "Some error in our tenkarray: " + tenkarray[i]
			sys.exit(1)
	
		
	return returnray

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

