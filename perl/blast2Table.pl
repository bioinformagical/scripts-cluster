#!/usr/local/bin/perl -w

use Bio::SeqIO;
use Bio::SearchIO;

# Blast2table - program to parse Blast output using BioPerl's
# Bio::Tools::Blast.pm and to write the data from each HSP in tabular
# form in a variety of formats.  For some formats, the data may be
# modified to display the hit name as an HTML link to Genbank.  The
# data optionally can be sorted in various ways.  Blast2table
# processes a list of files named on the command line, or uses
# standard input if no filename is given.  Output is written to
# standard output.

# NOTE: Requires the module Bio::SearchIO.pm from BioPerl to be
# installed.  See <http://www.bioperl.org/> for more information.


# Modified from Todd Smith's Blast2table by James D. White (jdw@ou.edu)
# to add seq2beg and seq2end variables to output tables for locating
# hit locations within the data base, as well as within the queries.
# This is useful in finding markers in a contig data base.
# Also modified to allow longer Contig names. (Jun 9, 1999)
# Also modified to reverse seq1beg and seq1end for complemented
# sequence matches. (Aug 19, 1999)
#
# Added error message - JDW - (Jun 19, 2000)
#
# Fixed calls for retrieving $identity and $similarity - JDW (Aug 22, 2000)
#
# Fixed $evalue, so small values returned from blastall blastx (e.g., 'e-101')
# are numeric ('1e-101') - JDW (Oct 30, 2000)
#
# Completely rewritten to use Bio::Tools:Blast, instead of Todd Smith's
# Blast.pm.  Also combined several variants into one program (Blast2table,
# Blast2table_blastn_html, Blast2table_blastx_html, Blast2table_exbldb,
# Blast2table_jdw) - JDW (Nov. 7, 2001)
#
# Added -score and -expect flags to filter out poor hits - JDW (Jan. 4, 2002)
#
# Added -numhsps option to limit number of hits per query - JDW (May 16, 2002)
#
# Rewritten using BioPerl's Bio::SearchIO module, because Bio::Tools:Blast
# does not handle multiple query blast output files with failed searches
# at the beginning or end of a file.  In addition, Bio::Tools:Blast is
# deprecated and produces lots of annoying messages in version BioPerl 1.0.
# Added -long option to allow full length query name strings to be output.
# Changed output of '-format 7' to add %identity and %similarity.  Added
# more detail to help.  NOTE - Needs BioPerl 1.01 to get fixes for a bug in
# Bio::SearchIO which does not properly return multi-line hit descriptions.
# - JDW (May 23, 2002)
#
# Changed to use printf instead of write to avoid truncating fields, except
# for '-format 4' (for EST submissions) - JDW (Jun 18, 2002)
#
# Add '-bits' option to return the bits value, instead of the score.  Added
# -tophsp option to use only the first HSP for each hit.  Changed -numhits
# to -numhsps - JDW (Aug 21, 2002)
#
# Add '-make_match' option to make dummy HSPs for non-matching queries - JDW
# (Jan 30, 2003)
#
# Add '-desc_len' option to specify length for truncating descriptions that
# are too long - JDW (Jan 30, 2003)
#
# Add total_hits counter to verbose summary - JDW (Aug 19, 2003)
#
# Fix handling of strand information to show direction of hit (beginning
# and ending base locations of query and hit. - JDW (Sep 19, 2003)
#
# Add support for TimeLogic tab-delimited input - JDW (March 24, 2004)
#
# Fix TimeLogic support to handle frame/strand fields properly. - JDW
# (June 10, 2004)
#
# Fix NCBI Entrez HTML_link and spacing between columns in -html
# output - Scott R. Santos, Auburn University (Aug 31, 2005)
#
# Fix comments, including adding my email address to source - JDW
# (Sep 1, 2005)
#
# Add format 8 which includes length fields - JDW (Nov 22, 2005)
#
# Add -h as abbreviation for -help - JDW (Mar 14, 2007)
#
# Add -i to create index files of the names of queries with Hits,
# Misses, or Both - JDW (May 14, 2007)
#
# Add -header to output column headings and -format 9, which adds
# number of Newbler assembled 454 reads to -format 7 - JDW
# (Oct 10, 2007)
#
# Add -tophit and -top options - JDW (Mar 4, 2008)
#
# Add HTML headers for formats 1 and 4 when -html requested - JDW
# (June 24, 2008)
#
# Add -format 10, which is the same as -format 9, but adds frame
# information - JDW
#
# Make frame report NCBI style (+/-1, +/-2, +/-3), instead of Bioperl
# style (0, 1, 2) modified by strand (+/-1) - JDW (February 4, 2009)
#
# Change help to refer to select_contigs, which is preferable to
# sort_contigs, unless you really want the sorting - JDW (August 5, 2009)
#
# Allow case flexibility in recognizing number of 454 reads for
# -format 10 - JDW (August 6, 2010)
#
$::Date_Last_Modified = "August 6, 2010";

($::my_name) = $0 =~ m"[\\/]?([^\\/]+)$";
$::my_name ||= 'Blast2table';

$::DESC_LEN = 250;	# maximum description length to be output
$::MAX_FORMATS = 10;	# maximum value allowed for -format
$::MIN_SCORE   = 0;	# default value for -min_score
$::BITS_SCORE = 0;	# report the bits value instead of the score (-bits)
$::MAX_EXPECT  = 10;	# default value for -max_expect
$::NUM_HSPS = 0;	# default for -numhsps (0 for no limit)
$::extra_HSPs = 50;	# extra HSPs to process before sorting and limiting
			#   to -numhsps
$::INDEX_TYPE = 'N';	# type(s) of index file(s) to create

$::USAGE = <<USAGE;

USAGE:  $::my_name [-format 1-$::MAX_FORMATS] [-html] [-long]
                    [-expect max_expect] [-score min_score] [-bits]
                    [-make_match] [-numhsps max_hsps_per_query]
                    [-sort expect/pos/score] [-timelogic]
		    [-top] [-tophit] [-tophsp] [-verbose]
                    [-desc_len max_description_length]
		    [-index H/M/B/N] [-header] [file1 ...]
            or
        $::my_name -help           <== for more info

USAGE

use strict;
use Bio::SearchIO;
use Bio::Search::Result::GenericResult;

use Getopt::Long;
$::FORMAT = '1';
$::HEADER = $::HELP = $::HTML = $::LONG_QUERY = $::SORT_TYPE =
  $::TOP = $::TOP_HIT = $::TOP_HSP = $::MAKE_MATCH = $::VERBOSE =
  $::TIMELOGIC = '';
my @opts = (
    'desc_len=i' => \$::DESC_LEN,	# maximum description length
    'format=i'  => \$::FORMAT,		# output format
    header      => \$::HEADER,		# print column headings
    help        => \$::HELP,		# print full help to STDOUT
    h           => \$::HELP,		# print full help to STDOUT
    html        => \$::HTML,		# output HTML hdr & trlr in
    					#   some formats
    long        => \$::LONG_QUERY,	# output full query name, not
    					#   1st word
    'expect=f'  => \$::MAX_EXPECT,	# only keep hits & HSPs with
    					#   E-value <= $::MAX_EXPECT
    'score=f'   => \$::MIN_SCORE,	# only keep hits & HSPs with
					#   score >= $::MIN_SCORE
    bits        => \$::BITS_SCORE,	# output bits value, instead
					#   of score
    'index=s'	=> \$::INDEX_TYPE,	# create index files of names
					#   of queries with
					#   Hits, No hits, or Both
    'numhsps=i' => \$::NUM_HSPS,	# only examine top $::NUM_HSPS hits
    'sort=s'    => \$::SORT_TYPE,	# is output sorted and how?
    timelogic	=> \$::TIMELOGIC,	# input file(s) are TimeLogic
					#   tab-delimited
    top		=> \$::TOP,		# use only top HSP of the top
					#   hit for each query?
    tophit	=> \$::TOP_HIT,		# use only top hit for each query?
    tophsp	=> \$::TOP_HSP,		# use only top HSP for each hit?
    make_match	=> \$::MAKE_MATCH,	# make dummy HSPs for
					#   non-matching queries
    verbose     => \$::VERBOSE,		# print progress msgs to STDERR
        );
die $::USAGE unless( GetOptions(@opts) );
display_more_help() if ($::HELP);
if ($::FORMAT !~ /^\d+$/ || $::FORMAT < 0 || $::FORMAT > $::MAX_FORMATS)
    {
    die "\nInvalid value for -format '$::FORMAT'\n$::USAGE";
    }
#elsif ($::FORMAT == 1)	# select format for write, if needed
#    {
#    select((select(STDOUT), $~ = "BLAST2TABLE")[0]);
#    }
#elsif ($::FORMAT == 2)
#    {
#    select((select(STDOUT), $~ = "BLAST2TABLE_BLASTN_HTML")[0]);
#    }
#elsif ($::FORMAT == 3)
#    {
#    select((select(STDOUT), $~ = "BLAST2TABLE_BLASTX_HTML")[0]);
#    }
elsif ($::FORMAT == 4)
    {
    select((select(STDOUT), $~ = "BLAST2TABLE_EST")[0]);
    }

if ($::HTML && $::FORMAT > 4)
    {
    die "\nCannot use -html, except with -format 1, 2, 3, or 4\n$::USAGE";
    }

$::SORT_SUB = '';
if ($::SORT_TYPE =~ /^e/i)
    {
    $::SORT_SUB = \&by_expect;
    }
elsif ($::SORT_TYPE =~ /^p/i)
    {
    $::SORT_SUB = \&by_pos;
    }
elsif ($::SORT_TYPE =~ /^s/i)
    {
    $::SORT_SUB = \&by_score;
    }
elsif ($::SORT_TYPE ne '')
    {
    die "\nInvalid -sort type '$::SORT_TYPE'\n$::USAGE";
    }

if ($::DESC_LEN !~ /^\d+$/)
    {
    die "\nInvalid value for -desc_len '$::DESC_LEN'\n$::USAGE";
    }

if ($::INDEX_TYPE !~ /^[HMBN]$/i)
    {
    die "\nInvalid -index '$::INDEX_TYPE'\n$::USAGE";
    }
if ($::INDEX_TYPE ne 'N' && ! @ARGV)
    {
    die "\nInput filename must be specified with -index '$::INDEX_TYPE'.\n" .
        "Standard input is not allowed.\n$::USAGE";
    }
$::INDEX_TYPE = "\U$::INDEX_TYPE";
$::INDEX_TYPE =~ s/B/HM/;

$::total_hsps = $::total_hits = $::total_queries = $::total_files =
  $::html_header_printed =  $::dummy_hsps= 0;
my @hsp_list = ();

# Allow reading extra HSPss before sorting and -numhsps limiting, if -sort
#   specified
$::NUM_HSPS_EXTRAS = $::NUM_HSPS + ($::SORT_SUB ? $::extra_HSPs : 0);
$::TOP_HIT = $::TOP_HSP = 1 if ($::TOP);

push @ARGV, 'Standard Input' unless @ARGV;	# Handle STDIN if no files
# process list of file names from command line
foreach my $file (@ARGV)
    {
    my ($searchin, $query, $infile);
    $::file_queries = 0;
    $::total_files++;
    if ($::TIMELOGIC)
      {
      if ($file eq 'Standard Input')
        {
        $infile = 'STDIN';
        }
      else
        {
        # open the tab-delimited input file
        unless (defined(open(INFILE, "<$file")))
          {
          print STDERR "cannot open input tab-delimited file '$searchin',\n" .
                       "  skipping this file, $!\n";
          next;
          }
        $infile = 'INFILE';
        # create index files, if needed
        if ($::INDEX_TYPE =~ /H/)
	  {
	  open(HITS, ">$file.hits") or
	    die "Cannot create hits index file '$infile.hits', !$\n";
	  }
        if ($::INDEX_TYPE =~ /M/)
	  {
	  open(MISSES, ">$file.misses") or
	    die "Cannot create misses index file '$infile.misses', !$\n";
	  }
        }
      process_file_tab($infile);
      close(INFILE) unless $infile eq 'STDIN';
      }
    else # (!$::TIMELOGIC)	# use BioPerl to parse Blast output file
      {
      # create the blast object and get the parsed list
      if ($file eq 'Standard Input')
        {
        $searchin = new Bio::SearchIO( -format => 'blast', -fh => \*STDIN );
        }
      else
        {
        $searchin = new Bio::SearchIO( -format => 'blast', -file => $file );
        }
      # $searchin should be a Bio::SearchIO object
      unless ($searchin)
        {
        print STDERR "Call to new Bio::SearchIO failed for file: '$file'\n";
        next;
        }
      # create index files, if needed
      if ($::INDEX_TYPE =~ /H/)
	{
	open(HITS, ">$file.hits") or
	  die "Cannot create hits index file '$infile.hits', !$\n";
	}
      if ($::INDEX_TYPE =~ /M/)
	{
	open(MISSES, ">$file.misses") or
	  die "Cannot create misses index file '$infile.misses', !$\n";
	}
      while ( $query = $searchin->next_result() ) # next query within output file
        {
        # $query is a Bio::Search::Result::ResultI object
        $::file_queries++;
        process_blast($query);
        }
      }
    print STDERR "  $::file_queries blast queries parsed from file: $file\n"
      if $::VERBOSE;
    close HITS if ($::INDEX_TYPE =~ /H/);
    close MISSES if ($::INDEX_TYPE =~ /M/);

    } # end foreach $file (@ARGV)

if ($::total_queries)
    {
    if ($::HTML && ($::FORMAT >= 1 || $::FORMAT <= 4))
        {
        print "<head>\n";
        print "<pre>\n";
        $::html_header_printed = 1;
        }

    print_header() if ($::HEADER);

    if ($::SORT_SUB)
        {
        my @temp_hsps = @hsp_list;
        @hsp_list = sort $::SORT_SUB @temp_hsps;
        }

    # print the table
    foreach my $hsp (@hsp_list)
        {
        output_hsp($hsp)
        }

    if ($::html_header_printed)
        {
        print "</pre>\n";
        print "</head>\n";
        }
    }
if ($::VERBOSE)
  {
  print STDERR "\n$::total_files files containing $::total_queries queries were found with $::total_hsps HSPs for $::total_hits hits\n";
  print STDERR "$::dummy_hsps additional dummy HSPs were created for non-matching queries\n"
    if ($::MAKE_MATCH);
  }


###########################################################################
# process blast object from query
###########################################################################

sub process_blast
    {
    my ($bl) = @_;	# $bl is a Bio::Search::Result::ResultI object
    my $hit;
    my (@temp_hsp_list, @sorted_hsps);
    $::total_queries++;
    my($hsps, $hits, $index_hits, $index_misses) = (0) x 4;
#    my $date     = $bl->date();	# from Bio::Tools::SeqAnal.pm
#    $date ||= '';
#    my $program  = $bl->algorithm();	# BLASTN, BLASTP, ...
#    my $DB       = $bl->database_name();
    # Short or long query name?  query_accession is first word of query_name
    my $seq1name = $::LONG_QUERY ? $bl->query_name() : $bl->query_accession();
    my $seq1len  = $bl->query_length();	# length of query sequence
    my $seq1desc = $bl->query_description();
    my $seq2len = 0;	# we don't know seq2len yet
    my $hsplen = 0;	#   or hsplen
    my $fake_hsp = 0;

    while ($hit = $bl->next_hit()) # returns Bio::Search::Hit::HitI objects
        {
        $hits++;
       	# max num of hits/query before sorting and limiting
        last if $::NUM_HSPS && $hsps >= $::NUM_HSPS_EXTRAS;

        my $seq2name    = $hit->name();
        $seq2len     = $hit->length();		# length of hit sequence
        $hsplen = 0;				# we don't hsplen know yet
        my $acc         = $hit->accession();
        my $description = $hit->description() || $acc;
        # truncate descriptions that are too long
        substr($description, $::DESC_LEN) = ' ...'
          if ($::DESC_LEN && length($description) > $::DESC_LEN);

        my $score  = $hit->raw_score();
#        my $bits   = $hit->bits();	# There is no bits() for a Hit
        my $evalue = $hit->significance();
        $evalue =~ s/^([eE][-+]?\d+)$/1$1/;		# 'E-123' => '1E-123'
#        $evalue =~ s{(\d+)\.[5-9]\d*([eE])}
#                    {sprintf"%d$3", $2 + 1}e;	# '6.78e-90' => '7e-90'
#        $evalue =~ s/\.\d*([eE])/$1/e;		# '1.23E-45' => '1E-45'
        next if ($evalue > $::MAX_EXPECT ||
                 ($score < $::MIN_SCORE && ! $::BITS_SCORE));

        my $hsp;
        while ($hsp = $hit->next_hsp()) # $hsp is a Bio::Search::HSP::HSPI object
            {
            last if $::NUM_HSPS && $hsps >= $::NUM_HSPS_EXTRAS;
            my $score  = $hsp->score();
            my $bits   = $hsp->bits();
            $score = $bits if $::BITS_SCORE;	# return bits, not score?
            my $evalue = $hsp->evalue();
            $evalue =~ s/^([eE][-+]?\d+)$/1$1/;	# 'E-123' => '1E-123'
#            $evalue =~ s{(\d+)\.[5-9]\d*([eE])}
#                        {sprintf"%d$3", $2 + 1}e;	# '6.78e-90' => '7e-90'
#            $evalue =~ s/\.\d*([eE])/$1/e;		# '1.23E-45' => '1E-45'
            # filter out poor hsps
            next if ($score < $::MIN_SCORE || $evalue > $::MAX_EXPECT);
	    $hsps++;

            my $query_object = $hsp->query(); # a Bio::SeqFeature::Similarity object,
            my $hit_object = $hsp->hit();     # is also a Bio::SeqFeature::Generic obj
            $hsplen = $hsp->length();	# length of alignment
            my $seq1beg = $query_object->start();
            my $seq1end = $query_object->end();
            my $qstrand = $query_object->strand();
            my $qframe  = $query_object->frame();
            my $seq2beg = $hit_object->start();
            my $seq2end = $hit_object->end();
            my $strand  = $hit_object->strand();
            my $frame   = $hit_object->frame();
            $query_object = $hit_object = undef;

	    # convert Bioperl (strand:frame) = (+/-1:(0, 1, 2)) back to
	    #   NCBI (frame) = (+/-1, +/-2, +/-3)
	    if ($qstrand > 0)
	      {
	      $qframe += 1;
	      }
	    elsif ($qstrand < 0)
	      {
	      $qframe = -1 * ( $qframe + 1);
	      }
	    if ($strand > 0)
	      {
	      $frame += 1;
	      }
	    elsif ($strand < 0)
	      {
	      $frame = -1 * ( $frame + 1);
	      }

            my $identity   = sprintf "%.0f", $hsp->frac_identical * 100;
            my $similarity = sprintf "%.0f", $hsp->frac_conserved * 100;
            push @temp_hsp_list,
                [$evalue, $score,
                 $seq1beg, $seq1end, $seq1name, $qstrand, $qframe,
		 $seq1desc,
                 $seq2beg, $seq2end, $seq2name, $strand, $frame,
                 $description, $identity, $similarity,
                 $seq1len, $seq2len, $hsplen];
            last if $::TOP_HSP;	# skip rest of HSPs for this hit?
            } # end while ($hsp = ... )
        $hsp = undef;
        last if $::TOP_HIT;	# skip rest of hits for this query?
        } # end while ($hit =  ... )
    print HITS "$seq1name\n"
      if ($::INDEX_TYPE =~ /H/ && @temp_hsp_list);
    print MISSES "$seq1name\n"
      if ($::INDEX_TYPE =~ /M/ && ! @temp_hsp_list);
    if ($::MAKE_MATCH && ! @temp_hsp_list)
      {
      # if $::MAKE_MATCH and we found no HSPs, fake up a dummy, very
      # bad, HSP to record the fact that $seq1name was searched for in
      # the database, but no match was found.
#      push @temp_hsp_list, [$evalue, $score,
#                 $seq1beg, $seq1end, $seq1name, $qstrand, $qframe,
#		  $seq1desc,
#                 $seq2beg, $seq2end, $seq2name, $strand, $frame,
#                 $description, $identity, $similarity,
#                 $seq1len, $seq2len, $hsplen];
      push @temp_hsp_list, [99, 0,
                 0, 0, $seq1name, 0, '.',
		 $seq1desc,
                 0, 0, '-No-Hit-', 0, '.',
                 'No Matching Hit found', 0, 0,
                 $seq1len, 0, 0];
      $fake_hsp = 1;
      }
    if ($::SORT_SUB)
      {
      @sorted_hsps = sort $::SORT_SUB @temp_hsp_list;
      if ($::NUM_HSPS && (scalar @sorted_hsps) > $::NUM_HSPS)
        {
        @temp_hsp_list = splice @sorted_hsps, 0, $::NUM_HSPS;
        }
      else
        {
        @temp_hsp_list = @sorted_hsps;
        }
      }
    $hsps = scalar @temp_hsp_list;
    push @hsp_list, @temp_hsp_list;	# add new HSPs to global list
   
    $::total_hits += $hits;
    if ($fake_hsp)
      {
      print STDERR "  For query=$seq1name, 1 fake HSP was created for $hits hit\n"
        if ($::VERBOSE);
      $::dummy_hsps++;
      }
    else
      {
      print STDERR "  For query=$seq1name, $hsps HSPs were found for $hits hits\n"
        if ($::VERBOSE);
      $::total_hsps += $hsps;
      }
    $bl = $hit = undef;
    } # end process_blast


###########################################################################
# process blast info from tab-delimited input file
###########################################################################

sub process_file_tab
    {
    my ($infile) = @_;	# $infile is the file handle to read
    my (@temp_hsp_list, $hsp);
    my ($hsps, $hits, $skipping_hsps, $fake_hsp) = (0) x 4;
    my ($seq1beg, $seq1end, $seq1name, $qstrand, $qframe,
        $seq1desc,
        $seq2beg, $seq2end, $seq2name, $strand, $frame,
        $acc, $description, $identity, $similarity,
        $seq1len, $seq2len, $hsplen);
    my ($old_query, $old_hit, $query, $hit);
    $old_query = ' force new query ';
    $seq1len  = 0;	# we don't have this information for this type of file
    $seq2len  = 0;	#  *
    $hsplen  = 0;	#  *
        
    while (defined($hsp = <$infile>)) # read next input line
        {
        chomp($hsp);

        # split out TimeLogic fields from input line
        my($status, $domainsignificance, $domainscore,
           $querystart, $queryend, $queryaccession, $querytext,
           $queryframe, $targetstart, $targetend, $targetlocus,
           $targetframe, $targetdescription, $targetaccession,
           $percentalignment, $simpercentalignment) = split ("\t", $hsp);

        # check for valid input line
#        if ($status ne 'OK')
#          {
#          print STDERR "unusual tab-delimited input line, status='$status'\n  '$hsp'\n";
#          }

        # convert TimeLogic fields to old Blast2table fields
        $queryaccession ||= $querytext;	# make sure we have a query accession
        $query = $queryaccession . $querytext;
        $hit = $targetlocus . $targetdescription . $targetaccession;

        # check for new query
        if ($query ne $old_query)
          {
          $::file_queries++;
          $::total_queries++;
          process_query_tab($hsps, $hits, $seq1name, $seq1desc,
			    \@temp_hsp_list, $seq1len)
            if ($old_query ne ' force new query ');
          $skipping_hsps = $hsps = $hits = 0;
          $seq1name = '';
          @temp_hsp_list = ();
          $old_query = $query;
          $old_hit = ' force new hit ';
          }

	$seq1desc = $querytext;
        $seq1name = $::LONG_QUERY ? $querytext : $queryaccession;
        # skip to next input line if not OK, probably no hits for query
        next if ($status ne 'OK');

        # check for new hit
        if ($hit ne $old_hit)
          {
          $hits++;
          $old_hit = $hit;
          }

       	# max num of hits/query before sorting and limiting
        $skipping_hsps = 1 if ($::NUM_HSPS && $hsps >= $::NUM_HSPS_EXTRAS);
        next if $skipping_hsps;
        $skipping_hsps = 1 if $::TOP_HSP;	# skip rest of HSPs for this hit?

        # continue converting TimeLogic fields to old Blast2table fields
        my $evalue = $domainsignificance;
        $evalue =~ s/^([eE][-+]?\d+)$/1$1/;	# 'E-123' => '1E-123'
        my $bits = $domainscore;	# this is always a bit score, so score
        my $score = $bits;		#   is bits, if -bits is used or not
        $seq1beg = $querystart;
        $seq1end = $queryend;
        $qframe = $queryframe;
          $qframe = +1 if $qframe eq 'D';
          $qframe = -1 if $qframe eq 'C';
        $qstrand = $qframe > 0 ? +1 : $qframe < 0 ? -1 : 0;
        $seq2beg = $targetstart;
        $seq2end = $targetend;
        $seq2name = $targetlocus;
        $frame = $targetframe;
          $frame = +1 if $frame eq 'D';
          $frame = -1 if $frame eq 'C';
        $strand = $frame > 0 ? +1 : $frame < 0 ? -1 : 0;
        $acc = $targetaccession;
        $description = $targetdescription || $acc;
        # truncate descriptions that are too long
        substr($description, $::DESC_LEN) = ' ...'
          if ($::DESC_LEN && length($description) > $::DESC_LEN);
        $identity = $percentalignment;
        $similarity = $simpercentalignment;

        # filter out poor hsps
        next if ($score < $::MIN_SCORE || $evalue > $::MAX_EXPECT);
        $hsps++;

        # save this hsp
        push @temp_hsp_list,
            [$evalue, $score,
             $seq1beg, $seq1end, $seq1name, $qstrand, $qframe,
	     $querytext,
             $seq2beg, $seq2end, $seq2name, $strand, $frame,
             $description, $identity, $similarity,
             $seq1len, $seq2len, $hsplen];
        } # while (defined($hsp = <$infile>)) # read next input line

    process_query_tab($hsps, $hits, $seq1name, $seq1desc,
		      \@temp_hsp_list, $seq1len);
    $skipping_hsps = $hsps = $hits = 0;
    $seq1name = '';
    @temp_hsp_list = ();
    $old_query = ' force new query ';
    $old_hit = ' force new hit ';
    } # end process_file_tab


###########################################################################
# process query info from tab-delimited input file
###########################################################################

sub process_query_tab
    {
    my ($hsps, $hits, $seq1name, $seq1desc, $temp_hsp_list_ref,
        $seq1len, $querytext) = @_;
    my (@temp_hsp_list, @sorted_hsps);
    my $fake_hsp = 0;
    print HITS "$seq1name\n"
      if ($::INDEX_TYPE =~ /H/ && scalar @{$temp_hsp_list_ref});
    print MISSES "$seq1name\n"
      if ($::INDEX_TYPE =~ /M/ && ! scalar @{$temp_hsp_list_ref});
    if ($::MAKE_MATCH && ! scalar @{$temp_hsp_list_ref})
      {
      # if $::MAKE_MATCH and we found no HSPs, fake up a dummy, very
      # bad, HSP to record the fact that $seq1name was searched for in
      # the database, but no match was found.
#      push @temp_hsp_list, [$evalue, $score,
#                 $seq1beg, $seq1end, $seq1name, $qstrand, $qframe,
#                 $seq2beg, $seq2end, $seq2name, $strand, $frame,
#		  $querytext,
#                 $description, $identity, $similarity,
#                 $seq1len, $seq2len, $hsplen];
      push @{$temp_hsp_list_ref}, [99, 0,
                 0, 0, $seq1name, 0, '.',
		 $seq1desc,
                 0, 0, '-No-Hit-', 0, '.',
                 'No Matching Hit found', 0, 0,
                 , $seq1len, 0, 0];
      $fake_hsp = 1;
      }

    if ($::SORT_SUB)
      {
      @sorted_hsps = sort $::SORT_SUB @{$temp_hsp_list_ref};
      if ($::NUM_HSPS && (scalar @sorted_hsps) > $::NUM_HSPS)
        {
        @temp_hsp_list = splice @sorted_hsps, 0, $::NUM_HSPS;
        }
      else
        {
        @temp_hsp_list = @sorted_hsps;
        }
      }
    else
      {
      @temp_hsp_list = @{$temp_hsp_list_ref};
      }
    push @hsp_list, @temp_hsp_list;	# add new HSPs to global list
   
    $::total_hits += $hits;
    if ($fake_hsp)
      {
      print STDERR "  For query=$seq1name, 1 fake HSP was created for $hits hits\n"
        if ($::VERBOSE);
      $::dummy_hsps++;
      }
    else
      {
      print STDERR "  For query=$seq1name, $hsps HSPs were found for $hits hits\n"
        if ($::VERBOSE);
      $::total_hsps += scalar @temp_hsp_list;
      $hsps = 0;
      }
    @temp_hsp_list = ();
    } # end process_query_tab


###########################################################################
# output_hsp - Output an HSP in a variety of formats
###########################################################################

sub output_hsp
    {
    my ($hsp) = @_;
    my( $evalue, $score,
        $seq1beg, $seq1end, $seq1name, $qstrand, $qframe,
	$seq1desc,
        $seq2beg, $seq2end, $seq2name, $strand, $frame,
        $description, $identity, $similarity,
        $seq1len, $seq2len, $hsplen ) = @{ $hsp };
    my($id, $giNum);
    
    ($seq1beg, $seq1end) = ($seq1end, $seq1beg)
      if ($qstrand < 0 && $seq1beg < $seq1end);
    ($seq2beg, $seq2end) = ($seq2end, $seq2beg)
      if ($strand  < 0 && $seq2beg < $seq2end);

    if ($::FORMAT == 1)
        {
        $seq2name = &HTML_link($seq2name, 's') if $::HTML;
#         write STDOUT;
#         format BLAST2TABLE =
# @####  @<<<<<<<< @<<<<<<<<<< @###### @###### @<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        printf STDOUT "%5d  %-9s %-11s %7d %7d %-20s %s\n",
          $score,  $evalue, $seq1name, $seq1beg, $seq1end,  $seq2name,
          $description;
# .
        }
    elsif ($::FORMAT == 2)	# Blast2table_blastn_html
        {
        $seq2name =~ s/^gi\|g/gi\|/;
        $seq2name = &HTML_link($seq2name, 'n') if $::HTML;
#         write STDOUT;
#         format BLAST2TABLE_BLASTN_HTML =
# @####  @<<<<<<<< @<<<<<<<<<< @###### @######  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        printf STDOUT "%5d  %-9s %-11s %7d %7d  %-93s %s\n",
          $score, $evalue, $seq1name, $seq1beg, $seq1end, $seq2name,
          $description;
# .
        }
    elsif ($::FORMAT == 3)	# Blast2table_blastx_html
        {
        ($id, $giNum) = split (/\|/, $seq2name);
        ($id, $id, $giNum) = split (/\|/, $seq2name) if (! $giNum);
        $seq2name = &HTML_link($giNum, 'p_r') if ($::HTML && $giNum);
#         write STDOUT;
#         format BLAST2TABLE_BLASTX_HTML =
# @####  @<<<<<<<< @<<<<<<<<<< @###### @######  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        printf STDOUT "%5d  %-9s %-11s %7d %7d  %-93s %s\n",
          $score, $evalue, $seq1name, $seq1beg, $seq1end, $seq2name,
          $description;
# .
        }
    elsif ($::FORMAT == 4)	# Blast2table_est
        {
        $seq2name = &HTML_link($seq2name, 's') if ($::HTML);
        my $hit = 1;
        write STDOUT;
        format BLAST2TABLE_EST =
        @<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  @<< @###  @<<<<<<<< @<
$seq2name, $description, $frame, $score, $evalue, $hit
.
        }
    elsif ($::FORMAT == 5)	# exbldb output, like "MSPcrunch -d"
        {
        printf STDOUT "%4d %.2f %5d %5d %10s %5d %5d %s %s\n",
            $score, $identity, $seq1beg, $seq1end, $seq1name,
            $seq2beg, $seq2end,  $seq2name, $description;
        }
    elsif ($::FORMAT == 6)	# Blast2table_jdw format with hit
        {				# positions/direction
        printf "%4d  %-9s %-30s %7d %7d %-30s %7d %7d %s\n",
            $score, $evalue, substr($seq1name, 0, 30),
            $seq1beg, $seq1end, substr($seq2name, 0, 30),
            $seq2beg, $seq2end, substr($description, 0, 90);
        }
    elsif ($::FORMAT == 7)	# tab-delimited table
        {
        print join("\t", $score, $evalue, "$identity%", "$similarity%",
                   $seq1name, $seq1beg, $seq1end,
                   $seq2name, $seq2beg, $seq2end, $description),
              "\n";
        }
    elsif ($::FORMAT == 8)	# tab-delimited table
        {
        print join("\t", $score, $evalue,
                   $hsplen, "$identity%", "$similarity%",
                   $seq1name, $seq1len, $seq1beg, $seq1end,
                   $seq2name, $seq2len, $seq2beg, $seq2end,
		   $description),
              "\n";
        }
    elsif ($::FORMAT == 9)	# tab-delimited table
        {
	my $num_reads = ($seq1desc =~ /\snumReads=(\d+)/i) ?
	  $1 : '-';
        print join("\t", $score, $evalue,
                   $hsplen, "$identity%", "$similarity%",
                   $seq1name, $num_reads, $seq1len, $seq1beg,
		   $seq1end, $seq2name, $seq2len, $seq2beg, $seq2end,
		   $description),
              "\n";
        }
    elsif ($::FORMAT == 10)	# tab-delimited table
        {
	my $num_reads = ($seq1desc =~ /\snumReads=(\d+)/i) ?
	  $1 : '-';
        print join("\t", $score, $evalue,
                   $hsplen, "$identity%", "$similarity%",
                   $seq1name, $num_reads, $seq1len, $seq1beg,
		   $seq1end, $qframe, $seq2name, $seq2len, $seq2beg,
		   $seq2end, $frame, $description),
              "\n";
        }
    elsif ($::FORMAT eq '0')	# tab-delimited table
        {
        print join("\t", "qs=$qstrand", "qf=$qframe", "ss=$strand",
                   "sf=$frame", $score, $evalue, $seq1name, $seq1beg,
                   $seq1end,  $seq2name, $seq2beg, $seq2end), "\n";
        }
    else
        {
        die "\nInvalid -format '$::FORMAT'\n$::USAGE";
        }
    } # end output_hsp


###########################################################################
# print_header() - print column headings
###########################################################################

sub print_header
    {
    my $score = $::BITS_SCORE ? 'Bits' : 'Score';
    if ($::FORMAT == 1)
        {
# @####  @<<<<<<<< @<<<<<<<<<< @###### @###### @<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        printf STDOUT "%5s  %-9s %-11s %7s %7s %-20s %s\n",
          $score,  'E-Value', 'Query-Name', 'Q-Start', 'Q-End',
	  'Hit-Name', 'Description';
        }
    elsif ($::FORMAT == 2 ||	# Blast2table_blastn_html
    	   $::FORMAT == 3)	# Blast2table_blastx_html
        {
# @####  @<<<<<<<< @<<<<<<<<<< @###### @######  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        printf STDOUT "%5s  %-9s %-11s %7s %7s  %-93s %s\n",
          $score,  'E-Value', 'Query-Name', 'Q-Start', 'Q-End',
	  'Hit-Name', 'Description';
        }
    elsif ($::FORMAT == 4)	# Blast2table_est
        {
#         write STDOUT;
#         format BLAST2TABLE_EST =
#         @<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  @<< @###  @<<<<<<<< @<
# $seq2name, $description, $frame, $score, $evalue, $hit
# .
        printf STDOUT "        %-20s  %-34s  %-3s %4s  %-9s %s\n",
          'Hit-Name', 'Description', 'Frm', substr($score, 0, 4),
	  'E-Value', 'Hit';
        }
    elsif ($::FORMAT == 5)	# exbldb output, like "MSPcrunch -d"
        {
        printf STDOUT "%4s %5s %5s %5s %10s %5s %5s %s %s\n",
            substr($score, 0, 4), 'Ident', 'Q-Beg', 'Q-End',
	    'Query-Name', 'H-Beg', 'H-End', 'Hit-Name',
	    'Description';
        }
    elsif ($::FORMAT == 6)	# Blast2table_jdw format with hit
        {				# positions/direction
        printf STDOUT "%4s  %-9s %-30s %7s %7s %-30s %7s %7s %s\n",
            substr($score, 0, 4), 'E-Value', 'Query-Name',
            'Q-Begin', 'Q-End', 'Hit-Name',
            'H-Begin', 'H-End', 'Description';
        }
    elsif ($::FORMAT == 7)	# tab-delimited table
        {
        print STDOUT join("\t", $score, 'E-Value', '%-Ident',
	    '%-Simil', 'Query-Name', 'Q-Begin', 'Q-End',
	    'Hit-Name', 'H-Begin', 'H-End', 'Description'),
	  "\n";
        }
    elsif ($::FORMAT == 8)	# tab-delimited table
        {
        print join("\t", $score, 'E-Value', 'HSP-Len', '%-Ident',
	    '%-Simil', 'Query-Name', 'Q-Len', 'Q-Begin', 'Q-End',
            'Hit-Name', 'H-Len', 'H-Begin', 'H-End',
	    'Description'),
          "\n";
        }
    elsif ($::FORMAT == 9)	# tab-delimited table
        {
        print join("\t", $score, 'E-Value', 'HSP-Len', '%-Ident',
	    '%-Simil', 'Query-Name', 'Num-Rds', 'Q-Len', 'Q-Begin',
	    'Q-End',
            'Hit-Name', 'H-Len', 'H-Begin', 'H-End',
	    'Description'),
          "\n";
        }
    elsif ($::FORMAT == 10)	# tab-delimited table
        {
        print join("\t", $score, 'E-Value', 'HSP-Len', '%-Ident',
	    '%-Simil', 'Query-Name', 'Num-Rds', 'Q-Len', 'Q-Begin',
	    'Q-End', 'Q-Frame',
            'Hit-Name', 'H-Len', 'H-Begin', 'H-End', 'H-Frame',
	    'Description'),
          "\n";
        }
    elsif ($::FORMAT eq '0')	# tab-delimited table
        {
        print join("\t", "qs=strd", "qf=fram", "ss=strd", "sf=fram",
	    $score, 'E-Value', 'Query-Name', 'Q-Begin', 'Q-End',
	    'Hit-Name', 'H-Begin', 'H-End'), "\n";
        }
    } # end print_header


###########################################################################
# convert blast hit id into HTML hot link
###########################################################################

sub HTML_link
    {
    my($seq2name, $db) = @_;
    "<A HREF = http://www.ncbi.nlm.nih.gov/gquery/gquery.fcgi?term=$seq2name>$seq2name</A>";
    } # end HTML_link


###########################################################################
# by_expect - sort comparison routine to sort by increasing expect value
#   or by decreasing score if expect values match
###########################################################################

sub by_expect
    {
    my($evaluea, $scorea) = @{ $a };
    my($evalueb, $scoreb) = @{ $b };
    $evaluea <=> $evalueb or $scoreb <=> $scorea;
    } # end by_expect


###########################################################################
# by_pos - sort comparison routine to sort by hit position within query
###########################################################################

sub by_pos
    {
    my($evaluea, $scorea, $seq1bega, $seq1enda, $seq1namea) = @{ $a };
    my($evalueb, $scoreb, $seq1begb, $seq1endb, $seq1nameb) = @{ $b };
    $seq1namea cmp $seq1nameb or	# query name
        $seq1bega <=> $seq1begb or	#   then beginning base position
        $seq1enda <=> $seq1endb;	#   then ending base position
    } # end by_pos


###########################################################################
# by_score - sort comparison routine to sort by decreasing score
#   or by increasing expect value if scores match
###########################################################################

sub by_score
    {
    my($evaluea, $scorea) = @{ $a };
    my($evalueb, $scoreb) = @{ $b };
    $scoreb <=> $scorea or $evaluea <=> $evalueb;
    } # end by_score


###########################################################################
# display full help info
###########################################################################

sub display_more_help
    {
    print STDOUT <<HELP;

$::my_name - program to parse Blast output using BioPerl's
    Bio::Tools::Blast.pm and to write the data from each HSP in tabular
    form in a variety of formats.  For some formats, the data may be
    modified to display the hit name as an HTML link to Genbank.  The
    data optionally can be sorted in various ways.  $::my_name
    processes a list of files named on the command line, or uses
    standard input if no filename is given.  Output is written to
    standard output.


USAGE:  $::my_name [-format 1-$::MAX_FORMATS] [-html] [-long]
                    [-expect max_expect] [-score min_score] [-bits]
                    [-make_match] [-numhsps max_hsps_per_query]
                    [-sort expect/pos/score] [-timelogic]
		    [-top] [-tophit] [-tophsp] [-verbose]
                    [-desc_len max_description_length]
		    [-index H/M/B/N] [-header] [file1 ...]
            or
        $::my_name -help           <== What you are reading


OPTIONS:

  -bits  Return the value of 'bits', instead of 'score'.  Also screen
      based upon 'bits' >= 'min_score', if '-score min_score' is
      used.

  -desc_len <max_description_length>  Specify the maximum length of
      hit description to be output.  Descriptions longer than
      <max_description_length> are truncated and have " ..." appended
      to indicate the truncation.  (The actual output length is then
      <max_description_length> + 4.)  The default value for
      <max_description_length> is $::DESC_LEN.  If <max_description_length> is
      set to zero, then no truncation occurs.

  -expect <max_expect>  Specify the maximum allowed value for the expect
      value.  HSPs with larger expect values are discarded.  For example,
      '-expect 1E-5' would discard all HSP with an expect value greater
      than 0.00001.  The default value of 'max_expect' is $::MAX_EXPECT.

  -format <format>  Select output format.  Default is '-format 1'.

      '-format 1' - Create a table with descriptions and hit names.
      May be used with '-html' to output the hit names as HTML links.
      This is the same format used by the previous Blast2table and is
      the default, which may be omitted.  '-format 1' is useful for
      finding the locations of matching genes in long query contigs.

      Fields are written in a fixed column format, but long field values
      are extended to avoid truncation.  The fields are: Score,
      E-value, Query Name, Starting Position of Match in Query, Ending
      Position of Match in Query,  Hit Name, Hit Description.  '-format 1'
      allows a short Hit Name and a very long Hit Description.

      '-format 2' - Create a table with descriptions and hit names.
      The hit name is modified to be a valid query key for the Genbank
      nucleotide database and would normally be used with '-html' to
      output the hit names as HTML links and to encapsulate the entire
      file in HTML tags.  This is the same format used by
      Blast2table_blastn_html.  '-format 2' is useful for finding the
      locations of matching genes in long query contigs.

      Fields are written in a fixed column format, but long field values
      are extended to avoid truncation.  The fields are: Score,
      E-value, Query Name, Starting Position of Match in Query, Ending
      Position of Match in Query,  Hit Name, Hit Description.  The
      format is similar to '-format 1', but it allows a longer Hit Name
      while preserving column formatting.

      '-format 3' - Create a table with descriptions and hit names.
      The hit name is modified to be a valid query key for the Genbank
      protein database and would normally be used with '-html' to output
      the hit names as HTML links and to encapsulate the entire file in
      HTML tags.  This is the same format used by Blast2table_blastx_html.
      '-format 3' is useful for finding the locations of matching genes
      in long query contigs.

      Fields are written in a fixed column format, but long field values
      are extended to avoid truncation.  The fields are: Score,
      E-value, Query Name, Starting Position of Match in Query, Ending
      Position of Match in Query,  Hit Name, Hit Description.  The format
      is very similar to '-format 2'.

      '-format 4' - Create a table of hits in a format used to include in
      sequenced EST data submitted to Genbank.  This is the format
      produced by Blast2table_est.

      Fields are written in a fixed column format:  The fields are:  Hit
      Name, Hit Description, Frame, Score,  E-value, and a '1'.

      '-format 5' - Produces exbldb output, similar to \"MSPcrunch -d\",
      also like Blast2table_exbldb.  Percent identical bases is reported
      with two digits after the decimal point to match the format of
      MSPcrunch.

      Fields are printed in a fixed column format:  The fields are:
      Score, %-Identical, Starting Position of Match in Query, Ending
      Position of Match in Query, Query Name, Starting Position of
      Match in Hit, Ending Position of Match in Hit,  Hit Name, Hit
      Description.

      '-format 6' - Create a table with longer descriptions and hit
      names.  This format includes positions of matching sequences from
      both the query and each HSP, indicating the direction of each
      match.  This is the format produced by Blast2table_jdw and is
      useful for matching overlapping sequences for gap closure.

      Fields are printed in a fixed column format:  The fields are:
      Score, E-Value, Query Name (up to 30 chars), Starting Position
      of Match in Query, Ending Position of Match in Query, Hit Name
      (up to 30 chars), Starting Position of Match in Hit, Ending
      Position of Match in Hit, Hit Description (up to 90 chars).

      '-format 7' - Create a tab-delimited table with full-length
      descriptions and hit names.  Uses tabs as field separators,
      instead of using spaces to separate into fixed-length fields.
      This format is also useful for matching overlapping sequences for
      gap closure.

      Fields are printed in a tab-delimited format:  The fields are:
      Score, E-Value, Percentage of Identical Bases in Match, Percentage
      of Similar Bases in Match, Query Name, Starting Position of Match
      in Query, Ending Position of Match in Query, Hit Name, Starting
      Position of Match in Hit, Ending Position of Match in Hit, Hit
      Description.

      '-format 8' - Create a tab-delimited table with full-length
      descriptions and hit names.  Uses tabs as field separators,
      instead of using spaces to separate into fixed-length fields.
      This format is also useful for matching overlapping sequences for
      gap closure.

      Fields are printed in a tab-delimited format:  The fields are:
      Score, E-Value, Length of Match, Percentage of Identical Bases in
      Match, Percentage of Similar Bases in Match, Query Name, Total
      Length of Query Sequence, Starting Position of Match in Query,
      Ending Position of Match in Query, Hit Name, Total Length of Hit
      Sequence, Starting Position of Match in Hit, Ending Position of
      Match in Hit, Hit Description.

      '-format 9' - Create a tab-delimited table with full-length
      descriptions and hit names.  Uses tabs as field separators,
      instead of using spaces to separate into fixed-length fields.
      This format is also useful for matching overlapping sequences
      for gap closure of 454 newbler assembled contigs, because it
      adds the number of reads assembled to produce the query contig.
      If the query contig was not newbler produced (does not have
      " numReads=" in the query header), then the "Number of Reads
      Assembled for Query Contig" field will contain "-".

      Fields are printed in a tab-delimited format:  The fields are:
      Score, E-Value, Length of Match, Percentage of Identical Bases
      in Match, Percentage of Similar Bases in Match, Query Name,
      Number of Reads Assembled for Query Contig, Total Length of
      Query Sequence, Starting Position of Match in Query, Ending
      Position of Match in Query, Hit Name, Total Length of Hit
      Sequence, Starting Position of Match in Hit, Ending Position of
      Match in Hit, Hit Description.

      '-format 10' - Create a tab-delimited table with full-length
      descriptions and hit names.  Uses tabs as field separators,
      instead of using spaces to separate into fixed-length fields.
      This format is also useful for matching overlapping sequences
      for gap closure of 454 newbler assembled contigs, because it
      adds the number of reads assembled to produce the query contig.
      If the query contig was not newbler produced (does not have
      " numReads=" in the query header), then the "Number of Reads
      Assembled for Query Contig" field will contain "-".  This format
      is the same as '-format 9', but with the addition of frame
      fields.

      Fields are printed in a tab-delimited format:  The fields are:
      Score, E-Value, Length of Match, Percentage of Identical Bases
      in Match, Percentage of Similar Bases in Match, Query Name,
      Number of Reads Assembled for Query Contig, Total Length of
      Query Sequence, Starting Position of Match in Query, Ending
      Position of Match in Query, Query Frame, Hit Name, Total Length
      of Hit Sequence, Starting Position of Match in Hit, Ending Position of
      Match in Hit, Hit Frame, Hit Description.

  -header  Print column headers.

  -help  Print a help message.  -help may be abbreviated as -h.

  -html  Output hit name as an HTML tag.  May be used with
      '-format 1', '-format 2', '-format 3', or '-format 4'.

  -index H/M/B/N	The type(s) of index file(s) to create
      which contain the names of the query sequences which (1) have a
      matching hit ("H"), (2) do not have a hit which meets the -score
      and/or -expect specifications ("M"), (3) both types ("B"), or
      (4) neither type ("N").  These index files are suitable for use
      as order files for "select_contigs -n" (or "sort_contigs -o") to
      extract the query sequences that did or did not have good hits.
      When "H" is specified, an index file named "<input_file>.hits"
      is created listing the names of the queries which had matching
      hits.  When "M" is specified, an index file named
      "<input_file>.misses" is created listing the names of the
      queries which had no matching hits.  When "B" is specified, both
      index files are created.  When "N" is specified, neither file is
      created.  The default value for index type is "$::INDEX_TYPE".
      A value for -index other than "N" may not be used when the input
      is provided from standard input.

  -long     Output full long version of query name.  If -long is omitted,
      then only the first word of the query name (the accession) is used.

  -make_match	If there is no match for a query, then make up a dummy
      HSP to record the fact that no match was made.  The dummy HSPs will
      have a Score value of 0 and an E-value of 99.  

  -numhsps <max_hsps_per_query>  Specify the maximum number of hsps
      returned for each query string.  Note that there may be multiple
      HSPs per hit, so fewer than <max_hsps_per_query> different hits may
      be returned for a query, unless '-tophsp' was specified.  If
      <max_hsps_per_query> is zero, then all hsps are returned.  If
      -numhsps is not specified, then the default value is $::NUM_HSPS.      

  -score <min_score>  Specify the minimum allowed value for the score
      value.  HSPs with smaller score values are discarded.  For example,
      '-score 100' would discard all HSP with an score value smaller
      than 100.  Note that if '-bits' was specified, then 'min_score'
      refers to the minimum allowed bits value, not the score.  The
      default value of 'min_score' is $::MIN_SCORE.

  -sort <type>  Specify the type of sorting of output HSPs.  If '-sort'
      is omitted, then no sorting is performed.  The output lines are
      in the original order from Blast -- query by query, decreasing
      score value for each hit within a query, then decreasing score
      value for each HSP within each hit that has more than one HSP.  If
      '-numhsps max_hsps_per_query' is specifed, then extra HSPs are
      read before sorting the results of each query.  After sorting
      the HSPs for each query, then only the top 'max_hsps_per_query'
      HSPs for each query are returned.  The output of all queries is
      sorted together before the HSPs are output.

      '-sort expect' - Sort the output HSPs by increasing value of
      'expect'.  If multiple queries are processed, HSPs from all
      queries are sorted together.

      '-sort pos'    - Sort the output HSPs by the query name and then
      by the location of the match in the query string from beginning
      to end.  If multiple queries are processed, the HSPs from each
      query are grouped together and sorted by location within the
      query.

      '-sort score'  - Sort the output HSPs by decreasing value of
      'score'.  If multiple queries are processed, HSPs from all
      queries are sorted together.

  -timelogic  Input file(s) are in TimeLogic tab-delimited format,
	      instead of NCBI or WU Blast output format.
	      The following TimeLogic fields should be written into
	      the file(s): status, domainsignificance, domainscore,
	      querystart, queryend, queryaccession, querytext,
	      queryframe, targetstart, targetend, targetlocus,
	      targetframe, targetdescription, targetaccession,
	      percentalignment, and simpercentalignment.

  -top  Use only the first HSP of the first hit for each query.
	Ignore the rest.  Equivalent to -tophit and -tophsp together.

  -tophit  Use only the first hit for each query.  Ignore the rest.

  -tophsp  Use only the first HSP for each hit.  Ignore the rest.

  -verbose  Verbose mode - Print progress messages to STDERR.


DATE LAST MODIFIED: $::Date_Last_Modified

HELP
    exit 1;
    } # end display_more_help


##################################################################
# _format_hash(\%hash) - returns formatted string for printing
#    contents of a hash
##################################################################

sub _format_hash
  {
  my($hashref, $string, $key);
  if (@_ == 1)
    {
    $hashref = shift;
    }
  else
    {
    %$hashref = @_;
    }
  if (! defined $hashref)
    {
    $string = "<undef>";
    }
  elsif (ref $hashref)# eq 'ARRAY')
    {
    $string = "{";
    foreach $key (sort keys %$hashref)
      {
      $string .= ", " if $string ne "{";
      $string .= "$key=";
      $string .= (defined $$hashref{$key}) ? "'" . $$hashref{$key} . "'" :
        "<undef>";
      $string .= "=" . _format_hash($$hashref{$key}) if $string =~ /HASH\(0x/;
      }
    $string .= "}";
    }
  else
    {
    $string = $hashref;
    }
  return $string;
  } # end _format_hash
