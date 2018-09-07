#!/usr/bin/env julia

using ArgParse.ArgParseSettings    #=                                    =#
using ArgParse.@add_arg_table      #= For parsing command-line options   =#
using ArgParse.parse_args          #=                                    =#
using BioSequences
using FastaIO
using GenomicFeatures


"""
returns array of transcripts from reference genome and gff3 file
Arguments:
    fa - reference genome file in fasta format
    gff - reference genome gff3 file
"""
function get_transcripts_from_gff(fa::String, gff::String)::Array{BioSequences.FASTA.Record,1}

    #Reads Gff file generates dict chr => [transcriptsPositions]
    println("Reading GFF")
    reader = open(GFF3.Reader, gff)
    transDict = Dict{String,Array{String,1}}()
    ct = 0
    num = 0
    currTrans = ""
    coordex = ""
    strnd = ""
    chr = ""
    tic()
    for record in reader
        featureType=GenomicFeatures.GFF3.featuretype(record)
        # Check if new feature found, then push exons
        if (featureType=="transcript" || featureType=="mRNA")
            if (currTrans != string(GenomicFeatures.GFF3.attributes(record, "ID")[1]) && currTrans != "")
                if (coordex == "")
                    println(STDERR,"ERROR! Exon is empty!")
                else
                    coordex = coordex * strnd
                end
                if !(in(coordex, transDict[chr]))
                    push!(transDict[chr],coordex)
                    num = num + 1
                else
                    ct+=1
                end
            end
            chr = string(GenomicFeatures.GFF3.seqid(record))
            currTrans = string(GenomicFeatures.GFF3.attributes(record, "ID")[1])
            strnd = string(GenomicFeatures.GFF3.strand(record))
            #check if chr exist in dict
            if !(haskey(transDict,chr))
                transDict[chr]=[]
            end
            coordex = ""

        elseif (featureType=="exon")
            strPos = string(GenomicFeatures.GFF3.seqstart(record))
            endPos = string(GenomicFeatures.GFF3.seqend(record))

            if (currTrans == GenomicFeatures.GFF3.attributes(record, "Parent")[1])
                coordex = coordex * strPos * "-" * endPos * ","
            else
                println(record)
                println(STDERR,"ERROR! Exon before transcript.")
            end
        end
    end
    toc()
    println(STDERR,"Dublicated transcripts count in gff = ",ct)
    println(STDERR,"Number of transcripts in gff = ",num)
    close(reader)

    tic()
    #Read ref genome FASTA File
    # reader = open(FASTA.Reader, fa)
    # record = FASTA.Record()
    # outRecords = Array{BioSequences.FASTA.Record,1}()
    # ct=1

    # for record in reader
    #     append!(outRecords, get_transcripts_from_gff(record, transDict))
    # end
    file_stream=open(fa,"r")
    result= @parallel (vcat) for record in collect(FASTA.Reader(file_stream))
        get_transcripts_from_gff(record, transDict)
    end
    println(result)
    toc()
    close(file_stream)
    return(result)
end


function get_transcripts_from_gff(record::BioSequences.FASTA.Record,
    transDict::Dict)::Array{BioSequences.FASTA.Record,1}
    outRecords = Array{BioSequences.FASTA.Record,1}()
    chr = FASTA.identifier(record)
    if (haskey(transDict,chr))
        # Reads transcripts in Chromosome from transcripts dict
        d = transDict[chr]
        for trans in d
            transSeq = dna""
            transCoordsAndStrand = split(trans,",")
            transCoords = transCoordsAndStrand[1:end-1]
            strand = transCoordsAndStrand[end]
            for coords in transCoords
                coords = split(coords, "-")
                coor1 = parse(Int, coords[1])
                coor2 = parse(Int, coords[2])
                transSeq = transSeq * FASTA.sequence(record,coor1:coor2)
            end
            # If strand - makes reverse complement
            if (strand == "-")
                transSeq = reverse_complement!(transSeq)
            end
            push!(outRecords, FASTA.Record("Seq", transSeq))
            #println(vcat(outRecords))
            #println(STDERR,"$strand $chr ",length(transCoords)," ", length(transSeq))
        end
    else
        println(STDERR,"ERROR! Chromosome '",chr, "' is not in Gff file.")
    end
    return(outRecords)
end
