#!/usr/bin/env julia

"""
    function detect_polyA_in_a_string(fq_seq::String,minimum_polyA_length::Int64,maximum_non_A_symbols::Int64;maximum_search_fragment_length::Int64=50,debug=false)

    Checks if a string of a read contains polyA strechA starting seach from the 3'.
    Once a g search once a strech is found. A first and last symbol of a strech must be A.

    # Arguments
    - `fq_seq::String`: string for testing.
    - `minimum_polyA_length::Int64`: minimum length of polyA strech.
    - `maximum_non_A_symbols`::Int64: maximum numer of nonA symbols in polyA strech.
    - `re:Regex`: regex to search for polyA.

    # Keyword Arguments
    - `maximum_search_fragment_length::Int64=50`: fragment length from 3' end.
"""
function detect_polyA_in_a_string(
    fq_seq::String,
    minimum_polyA_length::Int64,
    maximum_non_A_symbols::Int64,
    re::Regex;
    maximum_search_fragment_length::Int64=50,
    debug=false
    )::Bool

    if maximum_non_A_symbols == 1
        return detect_polyA_in_a_string(fq_seq,minimum_polyA_length,maximum_search_fragment_length,re,debug)
    end
    has_poly_a = false
    fq_length = length(fq_seq)
    window_position_from_3_end = minimum_polyA_length
    startini = minimum_polyA_length

    while (window_position_from_3_end < maximum_search_fragment_length) && (startini  != fq_length)
        window_position_from_3_end += 1
        start = fq_length - startini + 1
        # skip searching for polyA far from the  right end
        substring = String(fq_seq[start:start+minimum_polyA_length-1])

        if substring[1] == 'A' && substring[minimum_polyA_length] == 'A' #first and last symbol of a polyA strech must be A
            ct = 0
            for symb in substring
                if symb != 'A'
                    ct += 1
                end
            end

            if ct <= maximum_non_A_symbols
                has_poly_a = true

                if debug
                    println("substring having at most than $maximum_non_A_symbols non A symbols")
                    println(substring)
                end
                break
            end
        end
        startini += 1
    end
    return has_poly_a
end


function detect_polyA_in_a_string(
    fq_seq::String,
    minimum_polyA_length::Int64,
    maximum_search_fragment_length::Int64,
    re::Regex,
    debug::Bool
    )::Bool

    fq_seq = uppercase(fq_seq)
    fq_length = length(fq_seq)

    if fq_length <= maximum_search_fragment_length
        if fq_length < minimum_polyA_length
            if debug
                println(STDERR,"ERROR! Sequence too short to detect polyA")
            end
            return false
        else
            maximum_search_fragment_length = fq_length - 1
        end
    end
    fq_seq = reverse(fq_seq[end-maximum_search_fragment_length:end])

    for m in eachmatch(re,fq_seq, true)
        if m[1] == nothing
            len1 = 0
        else
            len1 = length(m[1])
        end

        if m[3] == nothing
            len3 = 0
        else
            len3 = length(m[3])
        end

        len2 = length(m[2])

        if len2 >= minimum_polyA_length
            return true
        elseif len1 + len2 >= minimum_polyA_length || len3 + len2 >= minimum_polyA_length
            return true
        end
    end
    return false
end


"""
    extend_poly_A(fq_seq1::FASTQ.Record,fq_seq2::FASTQ.Record)

    Tries to merge and extend forward read.

    # Arguments
    - `fq_seq1::FASTQ.Record`: string of forward read.
    - `fq_seq2::FASTQ.Record`: string of reverse read reverse complement.
"""
function extend_poly_A(
    fq_seq1::FASTQ.Record,
    fq_seq2::FASTQ.Record)::FASTQ.Record

    return fq_seq1
end


"""
    check_polyA_prefixes(fqo_trimmed::FASTQ.Record,prefixes::FMIndexes.FMIndex{7,},maximum_distance_with_prefix_database::Int64,minimum_not_polyA::Int64)

    Check if the read is in pefixes list of naturall polyA sreches.

    # Arguments
    - `fqo_trimmed::FASTQ.Record,`: fastq record.
    - `prefixes::FMIndexes.FMIndex{7,}`: array of natural prefixes.
    - `maximum_distance_with_prefix_database::Int64`: maximum Levenstain distance.
    - `minimum_not_polyA::Int64`: Minimum of polyA lenght.
"""
function check_polyA_prefixes(
    fqo_trimmed::FASTQ.Record,
    prefixes::FMIndexes.FMIndex{7,},
    maximum_distance_with_prefix_database::Int64,
    minimum_not_polyA::Int64
    )::Bool

    read_substring_for_check=String(FASTQ.sequence(fqo_trimmed))[(end-minimum_not_polyA+1):end]

    has_no_match=(count(read_substring_for_check,prefixes)<1)
    return  has_no_match
end


"""
    trim_polyA_3end(seq::String, minimum_poly_A_between::Int64)

    Function that trimmes 3' end of polyA having sequence from non A symbols that might originate fue to reamins of adapters or sequencing artefacts

    # Arguments
    - `seq::String`: read sequence in String
    - `minimum_poly_A_between::Int64`: minimum length of polyA strech that might occure between non A symbols forming a fragment to be trimmed off (starting from the very 3' end)
"""
function trim_polyA_3end(seq::String,
    minimum_poly_A_between::Int64
    )::Tuple{String,Int64}

    length_sequence = length(seq)
    i = length(seq)
    trimming_position = 0
    polyA_strech_length = 0

    while (polyA_strech_length <= minimum_poly_A_between) && (i>0)
        symbol=seq[i]

        if symbol != 'A'
            trimming_position = i
            polyA_strech_length = 0
        else
            polyA_strech_length += 1
        end
        i -= 1
    end

    if trimming_position == 0
        out = (seq,0)
    else
        out = (seq[1:trimming_position-1],length_sequence-trimming_position+1)
    end
    return out
end


"""
    count_nona(seq::String)

    Counts not A in a string.
"""
function count_nona(seq::String)::Int64

    ct = 0

    for s in seq
        if s != 'A'
            ct += 1
        end
    end
    return ct
end


"""
    first_nona(seq::String)

    Finds first not A from the end (3')
"""
function first_nona(seq::String)::Int64

    ct = 0
    l = length(seq)

    for i in 1:l
        pos = l - ct

        if seq[pos] != 'A'
            break
        end
        ct += 1
    end
    return ct
end


"""
    Function that trimmes 3 polyA tail of a given fastq entry and outputs trimmed read with number of polyA indicated in read's name

    # Arguments
    - `minimum_not_polyA::Int64`: minimum length of not polyA strech in a read
    - `minimum_polyA_length::Int64`: minimum length of polyA strech
    - `minimum_poly_A_between::Int64`: minimum length of polyA strech that might occure between non A symbols forming a fragment to be trimmed off (starting from the very 3' end)

    # Keywords arguments
    - `debug::Bool`: turns out additional output
    - `window_length::Int64`: windows size for polyA trimming
    - `max_nonA_in_window::Int64`: tollerated nonA number per window

    # The algorithms works like
    1. Trimmes offs remains of adapters at the 3'
    2. Search for a window wich exceeds nonA limit and has no other high A content window towards 5' end
    3. Ajusts the A position in the window
"""
function trim_polyA_from_fastq_record(fq::FASTQ.Record,
    minimum_not_polyA::Int64,
    minimum_polyA_length::Int64,
    minimum_poly_A_between::Int64;
    debug=false,
    window_length=10,
    max_nonA_in_window=1,
    limit_for_3end_trimming=20
    )::Tuple{FASTQ.Record,Bool,Bool}

    has_proper_polyA = false
    polyA_detected = true
    seq_ini = String(FASTQ.sequence(fq),)
    seq,trimmed_to_polyA = trim_polyA_3end(seq_ini,minimum_poly_A_between)
    seq_len = length(seq)
    name = FASTQ.identifier(fq)

    if FASTQ.hasdescription(fq)
        description = FASTQ.description(fq)
    else
        description = nothing
    end

    quality = FASTQ.quality(fq)[1:seq_len]
    i = seq_len
    polyA_start = 0
    first_nona_position = 0

    if debug
        println("-----------------------------------------------------------------------------------------------------------------------------\nSequence for trimming:\n$seq_ini")
        println("Sequence with chopped 3'end adapter remains:\n$seq")

        if !(polyA_detected)
            println("WARNING! this sequence will be concidered as not having polyA tail due to trimming of 3end adapter remains too much (> $limit_for_3end_trimming bp)")
        end
    end

    # search for a polyA start with a sliding window from the 3' end
    #Analysis limit to the cases where we meet a new non A symbol (going from 3' end)
    initial_position = 0 # position of polyA start based on windows.
    first_nona_position = 0

    while i > 0 & initial_position == 0
        s = seq[i]

        if s != 'A'
            fragment_start = i
            fragment_end = i + window_length - 1
            # println("fragment_start:fragment_end-ini seq_len $fragment_start $fragment_end $seq_len")
            # println(seq)

            if fragment_end > seq_len #handle the cases when there are non A at the 3' end
                fragment_end_ajusted = seq_len
                fragment_start_ajusted = i - (fragment_end-seq_len)
                fragment_start = fragment_start_ajusted
                fragment_end = fragment_end_ajusted
            end

            if fragment_start < 1
                fragment_start = 1
            end
            # println("fragment_start:fragment_end $fragment_start $fragment_end")
            fragment = seq[fragment_start:fragment_end]
            number_of_nonA = count_nona(fragment)

            if debug
                println("Fragment with non A, starting position $i, with $number_of_nonA nonA symbols")
                println(fragment)
            end

            if max_nonA_in_window < number_of_nonA
                #test if a window towards 5' also contains non A sequences
                to_5end_frag_end=fragment_start - 1
                to_5end_frag_start=to_5end_frag_end - window_length + 1

                if to_5end_frag_start < 1
                     to_5end_frag_start = 1
                end

                if to_5end_frag_start == 1 || (count_nona(seq[to_5end_frag_start:to_5end_frag_end]) > max_nonA_in_window)
                    initial_position = fragment_end
                    first_nona_position = initial_position - first_nona(seq[1:initial_position])

                    if debug
                        println("Initial non A sequence:")
                        println(seq[1:initial_position])
                        println("Adjusted non A sequence:")
                        println(seq[1:first_nona_position])
                    end
                    break
                end
            end
        end
        i -= 1
    end

    polyA_start = first_nona_position + 1
    polyA_length = seq_len-polyA_start + 1

    if (polyA_start > 0) & (polyA_start > minimum_not_polyA)
        not_poly_a_seq = seq[1:polyA_start-1]
        nname = string(polyA_length) * ":A:" * name
        nquality = quality[1:polyA_start-1]

        if description != nothing
            fqo = FASTQ.Record(nname, description, not_poly_a_seq, nquality)
        else
            fqo = FASTQ.Record(nname, not_poly_a_seq, nquality)
        end

        has_proper_polyA = true
    end

    if (trimmed_to_polyA > limit_for_3end_trimming) || (polyA_length < minimum_polyA_length)
        polyA_detected = false
    end

    if has_proper_polyA
        return fqo,has_proper_polyA,polyA_detected
    else
        return fq,has_proper_polyA,polyA_detected
    end
end


"""
    get_polyA_prefixes(fasta_record::FASTA.Record,minimum_not_polyA::Int64,minimum_polyA_length::Int64)

    Returns minimum kmer streches of not polyA ins a supplied transcript sequences

    # Arguments
    - `sequence::FASTA.Record`: string with polyA streches (type - BioSequences reference seq)
    - `minimum_not_polyA::Int64`: minimum length of not polyA strech
    - `minimum_polyA_length::Int64`: minimum length of polyA strech
"""
function get_polyA_prefixes(fasta_record::FASTA.Record,
    minimum_not_polyA::Int64,
    minimum_polyA_length::Int64,
    re::Regex)::Array{String,1}

    output = Array{String,1}()

    for m in eachmatch(re, String(sequence(fasta_record)))
        push!(output,m[1])
    end
    return output
end


"""
    get_polyA_prefixes(fasta_record::FASTA.Record,minimum_not_polyA::Int64,minimum_polyA_length::Int64,counter::SharedArray)

    Returns minimum kmer streches of not polyA ins a supplied transcript sequences

    # Arguments
    - `sequence::FASTA.Record`: string with polyA streches (type - BioSequences reference seq)
    - `minimum_not_polyA::Int64`: minimum length of not polyA strech
    - `minimum_polyA_length::Int64`: minimum length of polyA strech
    - `counter`: shared array for tracking processed reads - length matches julia workers
"""
function get_polyA_prefixes(fasta_record::FASTA.Record,
    minimum_not_polyA::Int64,
    minimum_polyA_length::Int64,
    re::Regex,
    counter::SharedArray)::Array{String,1}

    output = get_polyA_prefixes(fasta_record,minimum_not_polyA,minimum_polyA_length,re)
    counter[(myid()-1)] += 1
    total_jobs = sum(counter)

    if mod(total_jobs,10000) == 0
      print(STDERR,"Number of parsed transcripts = $total_jobs\r")
    end
    return output
end


"""
    trim_polyA_from_fastq_pair(fastq1::FASTQ.Record,fastq2::FASTQ.Record,prefixes::FMIndexes.FMIndex{7,},minimum_not_polyA::Int64,minimum_polyA_length::Int64,maximum_non_A_symbols::Int64,maximum_distance_with_prefix_database::Int64,minimum_poly_A_between::Int64)

    Finds and trims polyA having reads from a pair of fastq records

    # Arguments
    - `fastq1::FASTQ.Record`: FASTQ record
    - `fastq2::FASTQ.Record`: FASTQ record
    - `prefixes::FMIndexes.FMIndex{7,}`: array of prefixes of natural polyA
    - `minimum_not_polyA::Int64`: minimum length of not polyA strech in a read
    - `minimum_polyA_length::Int64`: minimum length of polyA strech
    - `maximum_non_A_symbols::Int64`: maximum numer of nonA symbols in polyA strech
    - `maximum_distance_with_prefix_database::Int64`: allowed Levenshtein distance between prefix of natural polyA in transcripts and the read
    - `minimum_poly_A_between::Int64`: minimum length of polyA strech that might occure between non A symbols forming a fragment to be trimmed off (starting from the very 3' end)
"""
function trim_polyA_from_fastq_pair(
    fastq1::FASTQ.Record,
    fastq2::FASTQ.Record,
    prefixes::FMIndexes.FMIndex{7,},
    minimum_not_polyA::Int64,
    minimum_polyA_length::Int64,
    maximum_non_A_symbols::Int64,
    maximum_distance_with_prefix_database::Int64,
    minimum_poly_A_between::Int64,
    re::Regex;
    debug_id="None",
    debug=false
    )

    polyA_detected = false
    has_proper_polyA = false
    seq_for_read = String(FASTQ.sequence(fastq1))
    revseq_rev_read = String(reverse_complement!(FASTQ.sequence(fastq2)))

    if debug
        println("for_read:", "\n", fastq1, "\n")
        println("rev_read:", "\n", fastq2, "\n")
        println("seq_for_read", seq_for_read,"\n")
        println("revseq_rev_read", revseq_rev_read,"\n")
        println("Is polyA in seq_for_read: ", detect_polyA_in_a_string(seq_for_read,minimum_polyA_length,maximum_non_A_symbols,re))
        println("Is polyA in revseq_rev_read: ", detect_polyA_in_a_string(revseq_rev_read,minimum_polyA_length,maximum_non_A_symbols,re))
        println("used parameter: minimum_polyA_length $minimum_polyA_length, maximum_non_A_symbols $maximum_non_A_symbols")
    end

    if  detect_polyA_in_a_string(seq_for_read,minimum_polyA_length,maximum_non_A_symbols,re) &&
        detect_polyA_in_a_string(revseq_rev_read,minimum_polyA_length,maximum_non_A_symbols,re)
            #tries sto esxtend polyA
            cosensus_extended_fwd_read=extend_poly_A(fastq1,fastq2)
            fqo_trimmed, has_proper_polyA, polyA_detected = trim_polyA_from_fastq_record(cosensus_extended_fwd_read,
                minimum_not_polyA,
                minimum_polyA_length,
                minimum_poly_A_between,debug=debug)

            if debug
                println("Output of $trim_polyA_from_fastq_record")
                println("Input seq",cosensus_extended_fwd_read)
                println(fqo_trimmed, has_proper_polyA, polyA_detected)
                println(minimum_not_polyA)
                println(minimum_polyA_length)
                println(minimum_poly_A_between)
            end

            #check if the read is in pefixes list of natural polyA streches
            if has_proper_polyA  && (length(prefixes) != 1 )
                has_proper_polyA = check_polyA_prefixes(fqo_trimmed,prefixes,maximum_distance_with_prefix_database,minimum_not_polyA)

                if !has_proper_polyA
                    fqo_trimmed = cosensus_extended_fwd_read
                end
            end
    else
        fqo_trimmed = fastq1
    end
    return fqo_trimmed, has_proper_polyA, polyA_detected
end


function trim_polyA_from_fastq_pair_pararell(
        chunk_for_channels::Array{Tuple{NTuple{4,String},NTuple{4,String}},1},
        fastqo_1_2_s_d::RemoteChannel{Channel{NTuple{4,String}}},
        ct_all::SharedArray{Int64,1},
        ct_pair_without_polyA::SharedArray{Int64,1},
        ct_pair_with_proper_polyA::SharedArray{Int64,1},
        ct_pair_with_discarded_polyA::SharedArray{Int64,1},
        ct_finished::SharedArray{Int64,1},
        ct_output_chunks::SharedArray{Int64,1},
        prefixes::FMIndexes.FMIndex{7,},
        minimum_not_polyA::Int64,
        minimum_polyA_length::Int64,
        maximum_non_A_symbols::Int64,
        maximum_distance_with_prefix_database::Int64,
        minimum_poly_A_between::Int64,
        include_polyA::Bool,
        re::Regex;
        debug_id="None",
        debug=false,
        )

        # mark that task is not finished on this process
        ct_finished[(myid()-1)] = 0
        # initialise buffers for collect of processed read
        fastq1_b = IOBuffer()
        fastq2_b = IOBuffer()
        fastq_s_b = IOBuffer()
        fastq_d_b = IOBuffer()
        #counrer for processed fastq entries per a process
        ct_local = 0

        for chunk_for_channel in chunk_for_channels
            fastq1_4l=chunk_for_channel[1][1]*chunk_for_channel[1][2]*chunk_for_channel[1][3]*chunk_for_channel[1][4]
            fastq2_4l=chunk_for_channel[2][1]*chunk_for_channel[2][2]*chunk_for_channel[2][3]*chunk_for_channel[2][4]
            fastq1 = FASTQ.Record(fastq1_4l)
            fastq2 = FASTQ.Record(fastq2_4l)
            ct_local += 1
            ct_all[(myid()-1)] += 1
            has_proper_polyA = false
            polyA_detected = false

            if debug_id == FASTQ.identifier(fastq1)
                debug = true
            else
                debug = false
            end
            fqo_trimmed, has_proper_polyA, polyA_detected = trim_polyA_from_fastq_pair(
                                                            fastq1,
                                                            fastq2,
                                                            prefixes,
                                                            minimum_not_polyA,
                                                            minimum_polyA_length,
                                                            maximum_non_A_symbols,
                                                            maximum_distance_with_prefix_database,
                                                            minimum_poly_A_between,
                                                            re,
                                                            debug_id=debug_id,
                                                            debug=debug
                                                            )

            if debug
                println("trim_polyA_from_fastq_pair output for $debug_id")
                println("fqo_trimmed:\n $fqo_trimmed \n, has_proper_polyA: $has_proper_polyA, polyA_detected: $polyA_detected")
            end

            if !polyA_detected
                ct_pair_without_polyA[(myid()-1)] += 1
                println(fastq1_b,fastq1)
                println(fastq2_b,fastq2)
            else
                a = 1

                if has_proper_polyA
                    println(fastq_s_b,fqo_trimmed)
                    ct_pair_with_proper_polyA[(myid()-1)] += 1
                    #get reverse complement of the polyA read

                    if include_polyA
                        name = FASTQ.identifier(fqo_trimmed)

                        if FASTQ.hasdescription(fqo_trimmed)
                            description = FASTQ.description(fqo_trimmed)
                        else
                            description = nothing
                        end

                        rev_quality = reverse(FASTQ.quality(fqo_trimmed))
                        rev_seq = reverse_complement!(FASTQ.sequence(fqo_trimmed))

                        if description != nothing
                            fqo_trimmed_rev = FASTQ.Record(name, description, rev_seq, rev_quality)
                        else
                            fqo_trimmed_rev = FASTQ.Record(name, rev_seq, rev_quality)
                        end

                        println(fastq1_b,fqo_trimmed)
                        println(fastq2_b,fqo_trimmed_rev)
                    end
                else
                    println(fastq_d_b,fastq1)
                    ct_pair_with_discarded_polyA[(myid()-1)] += 1
                end
            end
            #write out
        end
    #put to output pipe the final fraction
    fastq1_b_s = String(fastq1_b)
    fastq2_b_s = String(fastq2_b)
    fastq_s_b_s = String(fastq_s_b)
    fastq_d_b_s = String(fastq_d_b)

    if fastq1_b_s != ""   fastq1_b_z=String(transcode(CodecZlib.GzipCompressor,fastq1_b_s)) else fastq1_b_z="" end
    if fastq2_b_s != ""   fastq2_b_z=String(transcode(CodecZlib.GzipCompressor,fastq2_b_s)) else fastq2_b_z="" end
    if fastq_s_b_s != ""   fastq_s_b_z=String(transcode(CodecZlib.GzipCompressor,fastq_s_b_s)) else fastq_s_b_z="" end
    if fastq_d_b_s != ""   fastq_d_b_z=String(transcode(CodecZlib.GzipCompressor,fastq_d_b_s)) else fastq_d_b_z="" end
    ct_output_chunks[(myid()-1)] += 1
    put!(fastqo_1_2_s_d,(fastq1_b_z,fastq2_b_z,fastq_s_b_z,fastq_d_b_z))
    close(fastq1_b)
    close(fastq2_b)
    close(fastq_s_b)
    close(fastq_d_b)
    #close input buffers
    ct_finished[(myid()-1)] = 1

end
