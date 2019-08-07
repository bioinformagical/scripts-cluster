#!/usr/bin/env python
#
# BioLite - Tools for processing gene sequence data and automating workflows
# Copyright (c) 2012-2013 Brown University. All rights reserved.
# 
# This file is part of BioLite.
# 
# BioLite is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# BioLite is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with BioLite.  If not, see <http://www.gnu.org/licenses/>.


import dendropy
import numpy as np
import os
import random
import sys

from Bio import SeqIO
from collections import OrderedDict

from biolite import diagnostics


def get_species(taxon):
        """
        Parses the species from a taxon name in the format 'species@sequence_id'.
        """
        return str(taxon).partition('@')[0]


def get_taxa(nodes):
        """
        Returns a list of taxa names given a list of nodes.
        """
        return [node.get_node_str() for node in nodes]  


def count_orthologs(taxa):
        """
        Returns the count of orthologs given a list of taxon names. If there are as
        many species as there are taxon names, then the count is the number of
        taxon names. If there are less species than taxon names, then the count is
        0 since there must be some paralogs.
        """
        species = map(get_species, taxa)
        return len(species) * int(len(species) == len(set(species)))


def monophyly_masking(tree):
        """
        Takes a tree and identifies clades that have more than one sequence per
        taxon and prunes tip at random leaving a single representative sequence per
        taxon.
        """
        for node in tree.internal_nodes():
                if node.parent_node:
                        tree.reroot_at_node(node)
                        for leaf in tree.leaf_nodes():
                                sister = leaf.sister_nodes()[0]
                                if get_species(leaf.taxon) == get_species(sister.taxon):
                                        tree.prune_taxa([leaf.taxon], update_splits=False)
        return tree     
                 

def split_tree(tree, nodes):
        """
        Takes a rooted tree and a non-root internal node, and returns the two
        subtrees on either side of that node.
        """
        assert tree.is_rooted
        root = tree.seed_node

        out = [tree]

        for node in nodes:
                assert node != root
                if node.parent_node:

                        # Prune the child subtree from the original tree and reroot it.
                        tree.prune_subtree(node, update_splits=False)
                        #tree.reroot_at_node(root, update_splits=False)

                        # Move the node to a new subtree.
                        subtree = dendropy.Tree()
                        subtree.seed_node = node
                        if node.is_internal():
                                subtree.reroot_at_node(node, update_splits=False)

                        out.append(subtree)

        # Return both the modified tree and the subtree.
        return out


def paralogy_prune(tree, pruned_trees):
        """
        Takes a tree and loops through the internal nodes (except root) and gets
        the maximum number of orthologs on either side of each node.
        """     
        # A dictionary will keep track of node (key) and maximum number of
        # orthologs at this node (value). Internal nodes are reported by dendropy
        # in prefix order, so by using an OrderedDict, we will split the tree as
        # close to the root as possible.
        counts = OrderedDict()
        all_leaves = set(get_taxa(tree.leaf_nodes()))

        # Stop at any trees that only have two leaves.
        if len(all_leaves) <= 2:
                pruned_trees.append(tree)
                #print tree.as_newick_string()
                return

        for node in tree.postorder_node_iter():
                child_leaves = set(get_taxa(node.leaf_nodes()))
                other_leaves = all_leaves - child_leaves
                counts[node] = max(
                                                count_orthologs(child_leaves),
                                                count_orthologs(other_leaves))
                node.label = str(counts[node])

        #print tree.as_ascii_plot(show_internal_node_labels=True)

        # Calculate the maximum number of orthologs across all nodes.
        all_max = max(counts.itervalues())

        # Create a list of the nodes that have this max value, where we might split
        # the tree.
        splits = filter(lambda node : counts[node] == all_max, counts)
        assert splits

        if splits[0] == tree.seed_node:
                assert len(splits) == 1
                # The tree is pruned and only contains orthologs.
                pruned_trees.append(tree)
        else:
                assert not tree.seed_node in splits
                # Split the tree at the first non-root split node. Because the nodes
                # are in prefix order, this should be close to the root.
                subtrees = split_tree(tree, splits)
                for subtree in subtrees:
                        paralogy_prune(subtree, pruned_trees)


def supermatrix(clusters, taxa, outdir, partition_prefix='DNA', proportion):
        """
        Build a supermatrix from a list of clusters (as FASTA file names)
        and a list of taxa.
        """

        superseq = dict([(taxon, []) for taxon in taxa])
        nuc_coverage = np.zeros((len(clusters), len(taxa)))
        gene_coverage = np.zeros((len(clusters), len(taxa)))
        partition = [0]
        clus_len = []
        
        for cluster in clusters:
                record_dict = SeqIO.index(cluster, "fasta")
                clus_len.append(len(record_dict))
        clusters = [cluster for (num,cluster) in sorted(zip(clus_len,clusters))]
        clusters.reverse()      

        for i, cluster in enumerate(clusters):
                # Build a dictionary of taxa/sequences in this cluster
                seqs = {}
                for record in SeqIO.parse(open(cluster), 'fasta'):
                        seqs[record.id.partition('@')[0]] = str(record.seq)

                # Find the maximum sequence length
                maxlen = max(map(len, seqs.itervalues()))
                partition.append(maxlen)

                # Append sequences to the super-sequence, padding out any that
                # are shorter than the longest sequence
                for j, taxon in enumerate(taxa):
                        seq = seqs.get(taxon, '')
                        if seq:
                                superseq[taxon].append(seq)
                                nuc_coverage[i,j] = sum(1.0 for c in seq if c != '-') / maxlen
                                gene_coverage[i, i] = 1.0
                        if len(seq) < maxlen:
                                superseq[taxon].append('-' * (maxlen - len(seq)))
                                
        # Sort matrix of gene occupancy and calculate cummulative gene occupancy
        gene_sort = np.argsort(np.sum(coverage, axis=0))[::-1]
        coverage = coverage[:,gene_sort]

        num_genes = 0
        len_matrix = 0  
        cum_occupancy = []      
        for i in coverage:
                num_genes += sum(i)
                len_matrix += len(i)
                cum_occupancy.append(num_genes / len_matrix)
        
        # TO DO: by default construct supermatrix with gene occupany == cum_occupancy[-1]
        # Use indices in cum_occupancy and superseq to slice superseq and cosntruct supermatrix
        # based on user-defined occupancy (defined with argument "proportion")  

        # Write out supersequence for each taxon

        fasta = os.path.join(outdir, 'supermatrix.fa')
        with open(fasta, 'w') as f:
                for taxon in taxa:
                        print >>f, ">%s" % taxon
                        print >>f, ''.join(superseq[taxon])

        partition_txt = os.path.join(outdir, 'supermatrix.partition.txt')
        with open(partition_txt, 'w') as f:
                cumulative = partition[0]
                for i in xrange(1, len(partition)):
                        print >>f, \
                                '%s, gene%d = %d-%d' % (
                                partition_prefix, i, cumulative+1, cumulative+partition[i])
                        cumulative += partition[i]

        coverage_txt = os.path.join(outdir, 'supermatrix.coverage.txt')
        with open(coverage_txt, 'w') as f:
                print >>f, '\t'.join(taxa)
                for row in nuc_coverage.tolist():
                        print >>f, '\t'.join(map(str, row))

        diagnostics.prefix.append('supermatrix')
        diagnostics.log('fasta', fasta)
        diagnostics.log('partition', partition_txt)
        diagnostics.log('nuc_coverage', coverage_txt)
        diagnostics.prefix.pop()
