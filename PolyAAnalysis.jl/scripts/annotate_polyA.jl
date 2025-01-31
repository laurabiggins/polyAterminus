#!/usr/bin/env julia

using ArgParse.ArgParseSettings
using ArgParse.@add_arg_table
using ArgParse.parse_args

NEW_PATH=join(split(Base.source_path(),"/")[1:end-3],"/")
push!(LOAD_PATH, NEW_PATH)
using PolyAAnalysis

function main(args)
    arg_parse_settings = ArgParseSettings(description = "Finds mapping positions of polyA sites, annotations and writes tsv and bed files.
                                                        Presumptions: 1) SE reads is used for alignment; 2) Reads were trimmed with PolyATerminus
                                                        PolyAAnalysis trimmer which adds tags to the read names. 3) Reads are sorted.
                                                        If cluster option is selected -> cluster is defined by  <= k distance from center and
                                                        > m distance between clusters.")
    @add_arg_table arg_parse_settings begin
        "--bam", "-b"
            arg_type = String
            help = "Bam file."
            required = true
            dest_name = "bam"
        "--out", "-o"
            arg_type = String
            help = "Prefix of output file."
            required = false
            dest_name = "outfile"
            default = "output"
        "--gff", "-g"
            arg_type = String
            help = "GFF3 file"
            required = true
            dest_name = "gff3file"
        "--strandness", "-s"
            arg_type = String
            help = "Strandness.
                    If R1 read is the same as a gene sequence: +;
                    If R2 read is the same as a gene sequence: -"
            dest_name = "strandness"
            default = "+"
        "--k", "-k"
            arg_type = Int64
            help = "Distance allowed from cluster center.
                    With default 0 no clustering is done."
            dest_name = "k"
            default = 0
        "--m", "-m"
            arg_type = Int64
            help = "Minimum distance between clusters.
                    With default 0 merge of two adjacent clusters is not done."
            dest_name = "m"
            default = 0
        "--cluster", "-c"
            arg_type = Bool
            help = "Do clustering."
            dest_name = "cluster"
            action = :store_true
        "--q", "-q"
            arg_type = Int64
            help = "Mapping quality of a read. Only greater than provided mapping
                    quality will be considered as correctly aligned read."
            dest_name = "mapq"
            default = 0
        "--verbose", "-v"
            arg_type = Bool
            help = "Verbose for clustering."
            dest_name = "verbose"
            action = :store_true
    end

    parsed_args = parse_args(arg_parse_settings)

    println("Arguments used for analysis:")
    for i in keys(parsed_args)
        println("$i ==> ", parsed_args[i])
    end

    tic()
    gffcollection = parseGFF3(parsed_args["gff3file"])
    println("Parsed gff: ")
    toc()

    bam = parsed_args["bam"]
    str = parsed_args["strandness"]
    k = parsed_args["k"]
    m = parsed_args["m"]
    mapq = parsed_args["mapq"]
    cluster = parsed_args["cluster"]
    verbose = parsed_args["verbose"]

    if parsed_args["k"] == 0
        cluster = false
    end

    tic()
    treads, passreads, pareads, pclus, pclus2 = readbam(bam, str, k, cluster;
                                                        mappingquality=mapq,
                                                        verbose=verbose)
    println("Parsed bam $bam: ")
    toc()

    tic()
    statdframe = stats_poly_a(pclus)
    println("Gen dataframe: ")
    toc()

    if cluster
        tic()
        if m != 0
            merge_adj_clusters!(pclus2, m; verbose=verbose)
        end
        statdframe2 = stats_clusters(pclus2)
        println("Gen dataframe from cluster: ")
        statdframe2[:Smaple] = basename(bam)
        statdframe2[:TotalReads] = treads
        statdframe2[:PassedReads] = passreads
        statdframe2[:PolyAReads] = pareads
        statdframe2 = sort!(statdframe2, [:Chrmosome, :Start])
        CSV.write(parsed_args["outfile"]*"_detected_clusters_polyA.tsv",
                  statdframe2, delim='\t')
        toc()
    end

    statdframe[:Smaple] = basename(bam)
    statdframe[:TotalReads] = treads
    statdframe[:PassedReads] = passreads
    statdframe[:PolyAReads] = pareads
    statdframe = sort!(statdframe, [:Chrmosome, :Position])
    CSV.write(parsed_args["outfile"]*"_detected_polyA.tsv",
              statdframe, delim='\t')
    tic()
    intervalcolection = getintervals(statdframe)
    println("Got intervals in: ")
    toc()
    tic()
    joinedcollection = annotate_polya_sites(intervalcolection, gffcollection;
                                            verbose=verbose)
    println("Annotated polyA sites in: ")
    toc()

    CSV.write(parsed_args["outfile"]*"_annotated_polyA.bed", joinedcollection,
              delim='\t', header=false)

    if cluster
        tic()
        joinedcollection = annotate_clusters(statdframe2, gffcollection;
                                             verbose=verbose)
        println("Annotated polyA clusters in: ")
        toc()
        CSV.write(parsed_args["outfile"]*"_annotated_polyA_clusters.bed", joinedcollection,
                  delim='\t', header=false)
    end

end

main(ARGS)
