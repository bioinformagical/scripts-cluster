#!/usr/bin/python

import re
import sys
import die
#import rogersSlidingWindowCount
#from rogersTheta import getSegregatingSites 
#from rogersTheta import getA

######      This will read in a master table file and calculate the frequency of SNPs per 10KB window and it will slide 
	#   Let's add how often we count a He or a Ho. Then divide that by 10K. Add that 2 a new table.
#	USAGE:		 python /users/rreid2/scripts/python/10k-hehoFreq.py 01_S19-noref.txt 
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
### THE output file .......
outname = front+"-HeHoFreq.txt"
outfile = open(outname, 'w')
print "OUr outname is ",outname

def gettheta(s,a):
        theta=s/a
        return theta

#####  Printing a Header
#outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
outfile.write("Chrom\tStart\tStop\the\tho\the/10k\tho/10k")
outfile.write("\n")

#####    Read in heho table, 
filemaster = open(sys.argv[1])
startcount=0
stopcount=10000
currentcount=0
chrom = "2L"
tenkarray = []
## Thow away header
header=filemaster.readline()

numhe=0.0
numho=0.0
while 1:
	line = filemaster.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done reading master file, We out !!"
		break
	ray=line.split()
	posray=ray[0].split("-")
	pos=int(ray[1])
	newchrom=ray[0]
	heho=ray[-1]
	print ray[-1]
	#if denominator > 1:
	
	#check if we are at end of chromosome and start a new one if need be
	if (newchrom not in chrom):
		startcount=0
		stopcount=10000
		currentcount=pos
		chrom=newchrom
		numhe=0.0
		numho=0.0
	#print line
	#check if we have 10K range, and if not add array to test array
	if (pos < stopcount):
		if "he" in heho:
			numhe += 1
		elif "ho" in heho:
			numho += 1
		else:
			sys.exit("HeHo Broke")

		#print ray[1:]
	elif	(pos > stopcount):
		outfile.write("%s\t"%chrom)
		outfile.write("%i\t"%startcount)
		outfile.write("%i\t"%pos)
		outfile.write("%f\t"%numhe)
		outfile.write("%f\t"%numho)
		he10k=numhe/10000.0
		ho10k=numho/10000.0
		outfile.write("%f\t"%he10k)
		outfile.write("%f\n"%ho10k)
		numhe=0.0
		numho=0.0
		#printray=GetSNPTallies(tenkarray)
		#print printray
		#for cb in printray:
		#	outfile.write("%s\t"%cb)
		#outfile.write(printray)
		#outfile.write("\n")
		#del tenkarray[:]
		#tenkarray.pop(0)
		#tenkarray.append(ray)
		#print len(tenkarray)
		#print tenkarray[0]
		#startcount=int(tenkarray[0][0].split("-")[1])
		#while (startcount < (pos-10000)):
		#	tenkarray.pop(0)
		#startcount=int(tenkarray[0][0].split("-")[1])
		#startcount=pos-10000
		startcount+=10000
		#print startcount
		stopcount=startcount + 10000
	
		#print " Start, stop and Size of the tenkarray: %i,%i, %i " %(startcount, stopcount, len(tenkarray))
#print "The Final OVERALL count is ",count,"\n"
print "done\n"



def getA(n):
	a=1.0
	i=0
	while i < n:
		tmp=float(i)
		a+=(1.0/tmp)
		i+=1
	return a

def gettheta(s,a):
	theta=s/a
	return theta

def GetSNPTalliesDeprecated(tenkarray):
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

