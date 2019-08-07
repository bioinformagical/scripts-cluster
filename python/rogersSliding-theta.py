#!/usr/bin/python

import re
import sys
import die
#import rogersSlidingWindowCount
#from rogersTheta import getSegregatingSites 
#from rogersTheta import getA

######      This will read in a master freq table file and calculate the theta per 10KB window and it will slide 
	#   Let's add how often we see a segregating site (defined by does snp have a 1 and a 0 in the numerator).  Write a new table.
	#  For given set of rays, we needs # of segsites, n is equal to number of strain columns we have, e.g. green = 10 flies
	#   a = 1/1+1/2_1/3,,,,1/n-1
#	USAGE:		 python /users/rreid2/scripts/python/rogers-slidingtheta.py pos-green-cols-freqall.txt outname 
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
front=sys.argv[2]

### THE output file .......
outname = front+"-10KWindow-wtheta.txt"
outfile = open(outname, 'w')
print "OUr outname is ",outname

def gettheta(s,a):
        theta=s/a
        return theta

def getSegregatingSites(rowarray):
        ##      Returns whether segregating sites exists for this set of SNPs.
        ##      0/0     0/1     0/2     "1/0"   "2/0"   "1*/1"  "1/1"   "1/2"   "2/2"   
        ##      0       1       2       3       4       5       6       7       8       
        returnray=[0,0,0,0,0,0,0,0,0,0,0,0]
        segsite=0
        has1=0
        has2=0
        has0=0
        
	for j in rowarray:
                if ("0/0" in j):
                        has0=1
                if ("0/1" in j):
                        returnray[1]+=1
                        has0=1
                if ("0/2" in j):
                        returnray[2]+=1
                        has0=1
                if ("1/0" in j):
                        returnray[3]+=1
                        has1=1
                if ("2/0" in j):
                        returnray[4]+=1
                        has2=1
                if ("1*/1" in j):
                        returnray[5]+=1
                if ("1/1" in j):
                        returnray[6]+=1
                        has1=1
                if ("1/2" in j):
                        returnray[7]+=1
                        has1=1
                if ("2/2" in j):
                        returnray[8]+=1
                        has2=1
        if (has0==1 and has1==1):
                return 1
        elif (has0==1 and has2==1):
                return 1
        elif (has1==1 and has2==1):
                return 1
        else:
                return 0



#####  Printing a Header
#outfile.write("Chrom-Position\t0/0\t0/1\t0/2\t1/0\t2/0\t1*/1\t1/1\t1/2\t2/2")
outfile.write("Chrom\tStart\tStop\tn\ta\t#segSites\tw-theta\tNumberOfHaplotypes")
outfile.write("\n")

#####    Read in Master table, 
filemaster = open(sys.argv[1])
startcount=0
stopcount=10000
window=10000
currentcount=0
chrom = "2L"
tenkarray = []
## Thow away header
header=filemaster.readline()

summedSegSites=0.0
while 1:
	line = filemaster.readline()
	line = line.strip('\n')
	if len(line) == 0:
		print "Done reading master file, We out !!"
		break
	ray=line.split()
	#posray=int(ray[1])
	posray=ray[0].split("-")
	newchrom=posray[0]
	pos=posray[1]
	### make copy of ray, remove column 1 and the last 2 columns.
	snpcallray=ray[2:-3]
	numerdenom=ray[-2]
	numhap=int(numerdenom.split('/')[1])
	n=numhap
	issegsite=getSegregatingSites(snpcallray)
	i=1
	a=0
	while i < numhap-1:
        	tmp=float(i)
        	a+=(1.0/tmp)
        	i+=1
	
	if (a < 1):
		a=1
	#fraction=ray[-1].split('/')
	#print ray[-1]
	#numerator=int(fraction[0])
	#denominator=int(fraction[1])
	#if denominator > 1:
	#	print denominator
	#n = float(denominator)
	#k = float(numerator)
	#check if we are at end of chromosome and start a new one if need be
	if (newchrom not in chrom):
		startcount=0
		stopcount=10000
		currentcount=pos
		chrom=newchrom
		print chrom
	
	#print line
	#check if we have 10K range, and if not add array to test array
	if (pos < stopcount):
		if n> 1:
			summedSegSites += issegsite
			#summedSegSites = summedSegSites/a
		#tenkarray.append(ray)	
		#print ray[1:]
	elif	(pos > stopcount):
		outfile.write("%s\t"%chrom)
		outfile.write("%i\t"%startcount)
		outfile.write("%i\t"%stopcount)
		if n> 1:
			summedSegSites += issegsite
			#summedSegSites = summedSegSites/a
		#customWindow=pos-startcount
		#meanpi=summedPi/customWindow
		wtheta=summedSegSites/(a*window)
		outfile.write("%i\t"%n)
		outfile.write("%f\t"%a)
		outfile.write("%i\t"%summedSegSites)
		outfile.write("%f\t"%wtheta)
		outfile.write("%i\n"%numhap)	
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
		startcount+=1000
		#print startcount
		stopcount=startcount + window
		summedSegSites=0
		#print " Start, stop and Size of the tenkarray: %i,%i, %i " %(startcount, stopcount, len(tenkarray))
#print "The Final OVERALL count is ",count,"\n"
print "done\n"



def getA(n):
	a=1.0
	i=0
	while i < n-1:
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

