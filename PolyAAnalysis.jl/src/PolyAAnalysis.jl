#!/usr/bin/env julia

# PolyAAnalysis.jl
# =======
#
# A julia package for the representation and manipulation of biological sequences.
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/BioSequences.jl/blob/master/LICENSE.md

__precompile__()

module PolyAAnalysis

export
    trim_polyA_file_records,
    trim_polyA_from_fastq_record,
    get_polyA_prefixes,
    BamRead,
    Clust!,
    PolACalculus,
    ParseGFF3,
    ParseRecord,
    GetIntervalSet,
    ItsectCollection,
    rmdups!,
    WrFrame

import BioAlignments: BAM
import DataFrames: DataFrame, DataFrameRow
import DataFrames: eachrow, deleterows!
import DataStructures
import CSV
import GenomicFeatures: GFF3
import GenomicFeatures: Interval
import GenomicFeatures: Strand
import GenomicFeatures: IntervalCollection
import GenomicFeatures: eachoverlap, isoverlapping, strand, metadata, seqname, first, last
import BioSequences: FASTQ
import BioSequences

include("MapPolyA.jl")
include("TrimmPolyA.jl")

end  # module PolyAAnalysis
