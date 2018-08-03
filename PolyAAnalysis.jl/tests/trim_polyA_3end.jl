using BioSequences
using Base.Test
push!(LOAD_PATH, "../../")
using PolyAAnalysis

# """
# function that trimmes 3' end of polyA having sequence from non A symbols that might originate fue to reamins of adapters or sequencing artefacts
# Arguments:
#     seq - read sequence in String
#     minimum_poly_A_between - minimum length of polyA strech that might occure between non A symbols forming a fragment to be trimmed off (starting from the very 3' end)
# """

#test set 1

for (seq,trimmed,trimmed_length) in [("GAATGTATGGTAGGAATGTATTCTCTTGTAGGAATGTAAATCTGTATTAAAAGGGGGTCCAAGCCAGGCCCCCAGGTCTTCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAA",
    "GAATGTATGGTAGGAATGTATTCTCTTGTAGGAATGTAAATCTGTATTAAAAGGGGGTCCAAGCCAGGCCCCCAGGTCTTCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAA",
    0)]
    @test trim_polyA_3end(seq,4)  == (trimmed,trimmed_length)
end

for (seq,trimmed,trimmed_length) in [("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATAAAATTCCCCCCCCCGCCC",
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    20)]
    @test trim_polyA_3end(seq,4)  == (trimmed,trimmed_length)
end

for (seq,trimmed,trimmed_length) in [("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATAAAATTCCCCCCCCCGCCC",
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATAAAA",
    15)]
    @test trim_polyA_3end(seq,3)  == (trimmed,trimmed_length)
end

for (seq,trimmed,trimmed_length) in [("CCGGTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "CCGGTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    0)]
    @test trim_polyA_3end(seq,3)  == (trimmed,trimmed_length)
end

for (seq,trimmed,trimmed_length) in [("AAATACATTTTCTGACATTGTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    "AAATACATTTTCTGACATTGTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    0)]
    @test trim_polyA_3end(seq,3)  == (trimmed,trimmed_length)
end

for (seq,trimmed,trimmed_length) in [("GAATGTATGGTAGGAATGTATTCTCTTGTAGGAATGTAAATCTGTATTAAAAGGGGGTCCAAGCCAGGCCCCCAGGTCTTC",
    "",
    81)]
    @test trim_polyA_3end(seq,4)  == (trimmed,trimmed_length)
end



#AAATACATTTTCTGACATTGTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
