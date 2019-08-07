####A simple Biopython code to parse multiple fasta file to extract specific sequences

from Bio import SeqIO
"""
usage:
In python shell
Import split_hiseq_v4 as s
s.write_singles()
"""

def get_List():
        handle=open("test_PE_1.fa","rU")
        d={}
        k=0
        id_list=[]
        seq_list=[]
        for record in SeqIO.parse(handle,"fasta"):
                id=str(record.id).split("/")
                acc=id[0]
                seq=str(record.seq)
                id_list.append(acc)
                seq_list.append(seq)

        for id in id_list:
                d[id]=seq_list[k]
                k+=1
        handle.close()
        return d


def compare_ids(d=None):
        handle=open("test_PE_2.fa","rU")
        file1=open('test_PE2_final.fa','w')
        file2=open('test_PE1_final.fa','w')

        for record in SeqIO.parse(handle,"fasta"):
                id=str(record.id).split("/")
                acc=id[0]
                seq=str(record.seq)

                if acc in d.keys():
                        
                        file1.write(">" + str(record.id) + "\n" + seq + "\n")
                        file2.write(">" + acc + "/1" + "\n" + d[acc] + "\n")
                        del d[acc]
        handle.close()
        file1.close()
        file2.close()
        return d


def write_singles():
        d=get_List()
        d=compare_ids(d)
        singles=open('test_SE_final.fa','w')
        for acc in d:
                singles.write(">" + acc + "\n" + d[acc] + "\n")
        singles.close()
        

        
        

