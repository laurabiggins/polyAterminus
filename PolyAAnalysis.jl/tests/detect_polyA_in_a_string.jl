##
##  function detect_polyA_in_a_string(
##    fq_seq::String,
##    minimum_polyA_length::Int64,
##    maximum_non_A_symbols::Int64;
##    maximum_search_fragment_length::Int64=50,
##    debug=false
##    )::Bool
##

seq = "AGAGAATTACAAATCAGAAGGGGAAGATTGACTGTTTAATAAAATGTGCTGGGAATCAATGGCAAATATACAATAAAATAAAATTATATTTTTATTCATATTATACCCCAAATAAATTTCAGATATACATAAAACCCAAAGTAAAATATT"
@test !detect_polyA_in_a_string(seq,10,1,debug=true)

seq = "GAATGTATGGTAGGAATGTATTCTCTTGTAGGAATGTAAATCTGTATTAAAAGGGGGTCCAAGCCAGGCCCCCAGGTCTTCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAA"
@test detect_polyA_in_a_string(seq,10,1,debug=true)

seq = "AGAGAATTACAAATCAGAAGGGGAAGATTGACTGTTTAATAAAATGTGCTGGGAATCAATGGCAAATATACAATAAAATAAAATTATATTTTTATTCATATTATACCCCAAATAAATTTCAGATATACATAAAACCCAAAGTAAAATATT"
@test detect_polyA_in_a_string(seq,10,3,debug=true)

seq = "AGAGAATTACAAATCAGAAGGGGAAGATTGACTGTTTAATAAAATGTGCTGGGAATCAATGGCAAATATACAATAAAATAAAATTATATTTTTATTCATATTATACCCCAAATAAATTTCAGATATACATAAAACCCAAAGTAAAATATT"
@test !detect_polyA_in_a_string(seq,10,1,debug=true)

seq = "TCAAAAAAATAATATGGTAATAATAATAAAAGCAGTGCCCAGAGAACAAGGCTTGTTGGCTGTTCCACCCCAGGGGGCCCCTTGCACAGGCGGTGCCATCTCTGCCTCCCAAAGCTCTAAGAGCCACTGTCCCCCATCCCAAGAGA"
@test !detect_polyA_in_a_string(seq,10,1,debug=true)

seq = "TCAAAAAAATAATATGGTAATAATAATAAAAGCAGTGCCCAGAGAACAAGGCTTGTTGGCTGTTCCACCCCAGGGGGCCCCTTGCACAGGCGGTGCCATCTCTGCCTCCCAAAGCTCTAAGAGCCACTGTCCCCCATCCCAAGAGA"
@test !detect_polyA_in_a_string(seq,10,1,debug=true)

seq = "GGGGCGCGGCGGCGCGGGGGGGGAAAAAAAAACCCCCCCCCCCCCCCGGGGGGCCCC"
@test !detect_polyA_in_a_string(seq,10,1,debug=true)

seq = "GGGGCGCGGCGGCGCGGGGGGGGAAAATAAAAACCCCCCCCCCCCCCCGGGGGGCCCC"
@test detect_polyA_in_a_string(seq,10,1,debug=true)

seq = "TGTGTGTGTGTGTGGTAAAAAAAAAAGT"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGTAAAAAAAAAA"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGTAAAAAAAAATAGGGG"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGATAAAAAAAAA"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGAATAAAAAAAAA"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGAAAAAAAAATAA"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGAATAAAAAAAAATAA"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGAAAAAAAAAT"
@test !detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGTAAAAAAAAA"
@test !detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "TGTGTGTGTGTGTGGAAAAAAAAA"
@test !detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "AAAAAAAAAAAAAAATGTGTGTGTGTGTGGAAAAAAAAA"
@test !detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "AAAAAAAAAAAAAAA"
@test detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)

seq = "AAAAAAAAA"
@test !detect_polyA_in_a_string(seq,10,1,maximum_search_fragment_length=20)
#GAATGTATGGTAGGAATGTATTCTCTTGTAGGAATGTAAATCTGTATTAAAAGGGGGTCCAAGCCAGGCCCCCAGGTCTTCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAA
