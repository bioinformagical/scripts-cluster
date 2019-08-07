import sys

f=open(sys.argv[1]).read().split(">")[1:]
for s in f:
  seqid, seq = s.split("\n",1)
  print ">"+seqid
  seq = seq.replace("*","")
  print seq.replace("\n","")
