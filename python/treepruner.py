#!/usr/bin/env python
#
# Agalma - Tools for processing gene sequence data and automating workflows
# Copyright (c) 2012-2013 Brown University. All rights reserved.
# 
# This file is part of Agalma.
# 
# Agalma is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Agalma is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Agalma.  If not, see <http://www.gnu.org/licenses/>.

"""
For each gene tree generated in genetree, it prunes the tree to
include only one representative sequence per taxon when sequences
form a monophyletic group (here called 'monophyly masking').  It then
prunes the monophyly-masked tree into maximally inclusive subtrees with
no more than one sequence per taxon (here called 'paralogy pruning').
"""

import glob
import os
import numpy
import shutil

from dendropy import Tree

import database

from biolite import diagnostics
from biolite import report
from biolite import utils
from biolite import workflows

from biolite.pipeline import Pipeline

pipe = Pipeline('treeprune', __doc__) 

# Command-line arguments
pipe.add_argument('tree_id', default=None, metavar='ID', help="""
        Use the trees from a previous genetree run.""")
pipe.add_argument('tree_dir', default=None, metavar='DIR', help="""
        Use an explicit path to a directory containing a 'RAxML_bipartitions.*'
        file for each cluster.""")


# Pipeline stages
@pipe.stage
def setup_path(id, tree_id, tree_dir):
        """Determine the path of the input genetree"""

        if not tree_id:
                prev = diagnostics.lookup_last_run(id, 'genetree')
                if prev:
                        tree_id = int(prev.run_id)
                        utils.info("using previous 'genetree' run id %d" % tree_id)
        
        if tree_dir:
                tree_dir = os.path.abspath(tree_dir)
        elif tree_id:
                # Lookup values for a previous run
                values = diagnostics.lookup(tree_id, diagnostics.EXIT)
                try:
                        tree_dir = values['filtered_trees_dir']
                except KeyError:
                        utils.die("No 'filtered_trees_dir' entry found in run %s" % tree_id)
        else:
                utils.die(
                        "No directory or run id provided: use --tree_dir or --tree_id")

        ingest('tree_dir')


@pipe.stage
def prune_trees(tree_dir, outdir):
        """Prune each tree using monophyly masking and paralogy pruning"""

        prune_dir = os.path.join(outdir, 'pruned-trees')
        utils.safe_mkdir(prune_dir)

        # RAxML generates by default 4 files for each alignment; here we only need
        # the best trees
        for tree_path in glob.glob(os.path.join(tree_dir, 'RAxML_bipartitions.*')):
                basename = os.path.basename(tree_path)
                tree = Tree(stream=open(tree_path), schema='newick')
                masked_tree = workflows.phylogeny.monophyly_masking(tree)
                masked_tree.write_to_path(
                                                        os.path.join(prune_dir, basename + '.mm'),
                                                        'newick', as_unrooted=True)
                pruned_trees = []
                workflows.phylogeny.paralogy_prune(masked_tree, pruned_trees)
                for i, tree in enumerate(pruned_trees):
                        tree.write_to_path(
                                                        os.path.join(prune_dir, '%s.pp.%d' % (basename, i)),
                                                        'newick', as_unrooted=True)

        ingest('prune_dir')


@pipe.stage
def parse_trees(prune_dir, _run_id):
        """Parse the tips of each tree to create a cluster in the database"""

        hist = {}
        rows = []
        nseqs = 0

        # Parse each paralogy pruned tree, and create a cluster from the tips
        cluster_id = 0
        for tree_path in glob.glob(os.path.join(prune_dir, '*.pp.*')):
                tree = Tree(stream=open(tree_path), schema='newick', as_unrooted=True)
                nodes = tree.leaf_nodes()
                size = len(nodes)
                # Only keep trees with 3 or more tips
                if size >= 3:
                        hist[size] = hist.get(size, 0) + 1
                        for node in nodes:
                                seq_id = node.get_node_str().partition('@')[-1]
                                rows.append((_run_id, cluster_id, seq_id))
                        cluster_id += 1
                        nseqs += size

        # Write clusters to the database
        database.execute("BEGIN")
        database.execute("DELETE FROM homology WHERE run_id=?;", (_run_id,))
        homology_sql = """
                INSERT INTO homology (run_id, component_id, sequence_id)
                VALUES (?,?,?);"""
        for row in rows:
                database.execute(homology_sql, row)
        database.execute("COMMIT")

        utils.info("histogram of gene cluster sizes:")
        for k in sorted(hist):
                print "%d\t:\t%d" % (k, hist[k])

        diagnostics.log('histogram', hist)
        diagnostics.log('nseqs', nseqs)


if __name__ == "__main__":
        # Run the pipeline.
        pipe.run()
        # Push the local diagnostics to the global database.
        diagnostics.merge()

# Report. #
class Report(report.BaseReport):
        def init(self):
                self.name = pipe.name
                # Lookups
                self.lookup('histogram', 'treeprune.parse_trees', 'histogram')
                self.str2list('histogram')
                # Gener`ators
                self.generator(self.cluster_histogram)
                self.generator(self.threshold_table)

        def cluster_histogram(self):
                """
                Distribution of the number of orthologs in each gene cluster.
                """
                if self.check('histogram'):
                        hist = self.data.histogram
                        hist = [(k,hist[k]) for k in sorted(hist)]
                        if len(hist) > 10:
                                # Use a histogram
                                imgname = "%d.cluster.hist.png" % self.run_id
                                props = {
                                        'title': "Distribution of Cluster Sizes",
                                        'xlabel': "# Orthologs in Cluster",
                                        'ylabel': "Frequency"}
                                return [self.histogram_overlay(imgname, [numpy.array(hist)], props=props)]
                        else:
                                # Use a table
                                return self.table(hist, ('Cluster Size', 'Frequency'))


        def threshold_table(self):
                """

                """
                sql = """
                        SELECT homology.component_id,
                               COUNT(homology.component_id),
                                   GROUP_CONCAT(sequences.catalog_id)
                        FROM homology JOIN
                             sequences ON homology.sequence_id = sequences.sequence_id
                        WHERE homology.run_id=?
                        GROUP BY homology.component_id;"""
                genes = {}
                clusters = {}
                for id, count, catalog_ids in database.execute(sql, (self.run_id,)):
                        threshold = len(set(catalog_ids.split(',')))
                        for i in xrange(3, threshold+1):
                                genes[i] = genes.get(i, 0) + count
                                clusters[i] = clusters.get(i, 0) + 1
                if genes:
                        headers = ('Threshold', '# Clusters', '% Missing Genes')
                        rows = []
                        ntaxa = max(genes.iterkeys())
                        for i in sorted(genes.iterkeys()):
                                full = clusters[i] * ntaxa
                                missing = 100.0 * (full - genes[i]) / full
                                rows.append((str(i), str(clusters[i]), '%.1f%%' % missing))
                        return self.table(rows, headers)
