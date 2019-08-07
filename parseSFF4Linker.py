import sys
from Bio import SeqIO
 
#====================================================================#
# check the command-line arguments:
if len(sys.argv) != 2:
    print("Usage: %s sff_file") % sys.argv[0]
    sys.exit(1)
 
#====================================================================#
# parse the sff file, following examples from
# http://biopython.org/DIST/docs/api/Bio.SeqIO.SffIO-module.html:
 
# This takes the first 100000 records from the sff file and counts how
# many reads have a FLX linker, and how many a Titanium linker:
sff_file = sys.argv[1]
flx_cnt = 0
ti_cnt = 0
read_cnt = 0
for record in SeqIO.parse(sff_file, "sff"):
    # get the sequence of the read:
    read = record.seq
    read = read.upper()
    # check if the sequence has a FLX linker:
    # (sequences from http://sourceforge.net/apps/mediawiki/wgs-assembler/index.php?title=SffToCA)
    if 'GTTGGAACCGAAAGGGTTTGAATTCAAACCCTTTCGGTTCCAAC' in read:
        flx_cnt += 1
    if 'TCGTATAACTTCGTATAATGTATGCTATACGAAGTTATTACG' in read or 'CGTAATAACTTCGTATAGCATACATTATACGAAGTTATACGA' in read:
        ti_cnt += 1
    read_cnt += 1
    if read_cnt == 100000:
        break
print("read_cnt:",read_cnt,", flx_cnt:",flx_cnt,", ti_cnt:",ti_cnt)
