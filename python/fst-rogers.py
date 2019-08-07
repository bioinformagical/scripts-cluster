#!/usr/bin/python

import re
import sys
import die

#########################    fst-rogers.py ---- Run FST stat between 2 groups        #########################################
##########################################################################################################
######
######		This will read in a "all4-num-denom" file that was created.  
	# 	We are going to:
	#		1. read the 4 columns of the table And pick a control and expt.
	#		2.  Cal the numerator and denominator and do some math FST gymnastics.
	#		3. Write results to table.
	#	USAGE:		 python /users/rreid2/scripts/python/fst-rogers.py /nobackup/rogers_research/rob/inbred/vcf-megatable/FST/all4-numeratordenominator.txt
Prefix = ""
print sys.argv[1]
print "The number of sys.argv given were; ",len(sys.argv),"\n"
if (len(sys.argv) > 2 or len(sys.argv) < 2 ):
	sys.exit("Exiting due to wrong # of arguments !!! ")
	#die.Die("Must specify 1 ARG. LaST ARG WAS ",str(sys.argv)," ")
	#Prefix = sys.argv[2]

###  making some OUTPUT FILES.
print sys.argv[1]
tmp=sys.argv[1]
tmparray=tmp.split(".")
front=tmparray[0]
### OUtfile
outname = "fst-controlVSdsanto.txt"
#sys.exit()
outfile = open(outname, 'w')


with open(sys.argv[1]) as afile:
	for line in afile:
		line =  line.strip()
		if not line:
			continue
		pattern=re.compile("^CHR")
		if pattern.match(line):
			continue
		else:
			linearray = line.split()
			coord=linearray[0]
			control = linearray[1]
			frac2 = linearray[2]
			frac3 = linearray[3]
			fracdsanto = linearray[4]
			
			controlray=control.split("/")
			numer1=float(controlray[0])
			denom1=float(controlray[1])

			frac2ray=frac2.split("/")
			numer2=float(frac2ray[0])
			denom2=float(frac2ray[1])

			frac3ray=frac3.split("/")
			numer3=float(frac3ray[0])
			denom3=float(frac3ray[1])
			
			## Dsanto is the 4rth column
			fracdsantoray=fracdsanto.split("/")
			numerdsant=float(fracdsantoray[0])
			denomdsant=float(fracdsantoray[1])

			numercontrol=float(numer1)   # +numer2+numer3
			denomcontrol=float(denom1)   # +denom2+denom3

			#Fst= [25/125*(1-25/125) - 50/125*(10/50)*(1-10/50) - 75/125*15/75*(1-15/75)] / [25/125*(1-25/125)]
			N=float(denomcontrol + denomdsant)
			bothnumer=float(numercontrol + numerdsant)

			top1=float((bothnumer/N)*(1-(bothnumer/N)))
			top2=-1.0
			if denomcontrol > 0:
				top2=float((denomcontrol/N)*(numercontrol/denomcontrol)*(1-(numercontrol/denomcontrol)))
			top3=float((denomdsant/N)*(numerdsant/denomdsant)*(1-(numerdsant/denomdsant)))
			top = top1-(top2+top3)
			bottom=(bothnumer/N)*(1-(bothnumer/N))
			fst=-0.0
			if bottom > 0 and denomcontrol > 0:
				fst=top/bottom
				if fst > 1:
					sys.exit(line)
			#print str(fst)
			outfile.write(line)
			outfile.write("\t")
			outfile.write(str(fst))
			outfile.write("\n")
#sys.exit()

print "The Final is done "

def search(values, searchFor,fpkm):
	for k in values:
        	for v in values[k]:
	    		if searchFor in v:
				return max(k,fpkm)
	return None


	

