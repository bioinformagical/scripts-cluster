#!/usr/bin/python

import re
import sys
import die
import vcfPytools
from vcfPytools import vcfClass

######      This s a class for vcf. It will define SNPs, locations, DP values, info values and define annotatoipns where possible.
		###  can return a list of VCF objects from a vcf file ideally.
	#	USAGE;   call this from other python scripts.

class VCFClass:
	""" This is the VCF class  """
	def __init__(self):
		self.data = []
 
 	def __init__(self,vcfline):
		splitty=vcfline.split()
		self.loc=splitty[0]
		self.position=int(splitty[1])
		self.id=splitty[2]
		self.refsnp=splitty[3]
		self.altsnp=splitty[4]
		self.qual=splitty[5]
		self.filter=splitty[6]
		self.info=splitty[7]
		self.vcf=vcfline

		inf=splitty[7]
		return 0

print vcfPytools

print vcfPytools.vcfClass

myvcf= vcfClass()

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

