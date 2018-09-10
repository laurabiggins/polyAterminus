using BioSequences
using GenomicFeatures

##
## function get_transcripts_from_gff(record::BioSequences.FASTA.Record,
##    transDict::Dict)::Array{BioSequences.FASTA.Record,1}
##

dcAll = Dict("Seq" => [String("1-5,8-12,+"), String("1-5,+"), String("1-20,+")])
append!(dcAll["Seq"],[String("1-5,8-12,-"), String("1-5,-"), String("1-20,-")])
outRecordsAll=Array{BioSequences.FASTA.Record,1}()

# + strand testing
record = FASTA.Record("Seq", dna"GTGGTGGCGCTCACCGACTG")
dc = Dict("Seq" => [String("1-5,8-12,+")])
recordOut = FASTA.Record("Seq", dna"GTGGTCGCTC")
outRecords = Array{BioSequences.FASTA.Record,1}()
push!(outRecords,recordOut)
push!(outRecordsAll,recordOut)
@test outRecords == get_transcripts_from_dict(record,dc)

dc = Dict("Seq" => [String("1-5,+")])
recordOut = FASTA.Record("Seq", dna"GTGGT")
outRecords = Array{BioSequences.FASTA.Record,1}()
push!(outRecords,recordOut)
push!(outRecordsAll,recordOut)
@test outRecords == get_transcripts_from_dict(record,dc)

dc = Dict("Seq" => [String("1-20,+")])
recordOut = FASTA.Record("Seq", dna"GTGGTGGCGCTCACCGACTG")
outRecords = Array{BioSequences.FASTA.Record,1}()
push!(outRecords,recordOut)
push!(outRecordsAll,recordOut)
@test outRecords == get_transcripts_from_dict(record,dc)

# - strand testing
dc = Dict("Seq" => [String("1-5,8-12,-")])
recordOut = FASTA.Record("Seq", dna"GAGCGACCAC")
outRecords = Array{BioSequences.FASTA.Record,1}()
push!(outRecords,recordOut)
push!(outRecordsAll,recordOut)
@test outRecords == get_transcripts_from_dict(record,dc)

dc = Dict("Seq" => [String("1-5,-")])
recordOut = FASTA.Record("Seq", dna"ACCAC")
outRecords = Array{BioSequences.FASTA.Record,1}()
push!(outRecords,recordOut)
push!(outRecordsAll,recordOut)
@test outRecords == get_transcripts_from_dict(record,dc)

dc = Dict("Seq" => [String("1-20,-")])
recordOut = FASTA.Record("Seq", dna"CAGTCGGTGAGCGCCACCAC")
outRecords = Array{BioSequences.FASTA.Record,1}()
push!(outRecords,recordOut)
push!(outRecordsAll,recordOut)
@test outRecords == get_transcripts_from_dict(record,dc)

# Test all records in list
@test outRecordsAll == get_transcripts_from_dict(record,dcAll)

##
##  function get_transcripts_from_gff(fa::String, gff::String)::Array{BioSequences.FASTA.Record,1}
##

# Creating Temp Files (gff and fasta) for testing.
f1,file_stream = mktemp(tempdir())

writer = GFF3.Writer(file_stream)
write(writer,GFF3.Record(b"chr1	HAVANA	gene	1	100	.	+	.	ID=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	transcript	1	100	.	+	.	ID=ENST00000456328.2;Parent=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	1	20	.	+	.	ID=exon:ENST00000456328.2:1;Parent=ENST00000456328.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	30	60	.	+	.	ID=exon:ENST00000456328.2:2;Parent=ENST00000456328.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	65	80	.	+	.	ID=exon:ENST00000456328.2:3;Parent=ENST00000456328.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	transcript	2	98	.	+	.	ID=ENST00000450305.2;Parent=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	2	15	.	+	.	ID=exon:ENST00000450305.2:1;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	20	35	.	+	.	ID=exon:ENST00000450305.2:2;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	37	45	.	+	.	ID=exon:ENST00000450305.2:3;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	50	65	.	+	.	ID=exon:ENST00000450305.2:4;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	70	80	.	+	.	ID=exon:ENST00000450305.2:5;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	85	95	.	+	.	ID=exon:ENST00000450305.2:6;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	gene	1	100	.	+	.	ID=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	transcript	1	100	.	-	.	ID=ENST00000456328.2;Parent=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	1	20	.	-	.	ID=exon:ENST00000456328.2:1;Parent=ENST00000456328.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	30	60	.	-	.	ID=exon:ENST00000456328.2:2;Parent=ENST00000456328.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	65	80	.	-	.	ID=exon:ENST00000456328.2:3;Parent=ENST00000456328.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	transcript	2	98	.	-	.	ID=ENST00000450305.2;Parent=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	2	15	.	-	.	ID=exon:ENST00000450305.2:1;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	20	35	.	-	.	ID=exon:ENST00000450305.2:2;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	37	45	.	-	.	ID=exon:ENST00000450305.2:3;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	50	65	.	-	.	ID=exon:ENST00000450305.2:4;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	70	80	.	-	.	ID=exon:ENST00000450305.2:5;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	85	95	.	-	.	ID=exon:ENST00000450305.2:6;Parent=ENST00000450305.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	transcript	2	98	.	-	.	ID=ENST00000450304.2;Parent=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	2	15	.	-	.	ID=exon:ENST00000450304.2:1;Parent=ENST00000450304.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	20	35	.	-	.	ID=exon:ENST00000450304.2:2;Parent=ENST00000450304.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	37	45	.	-	.	ID=exon:ENST00000450304.2:3;Parent=ENST00000450304.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	50	65	.	-	.	ID=exon:ENST00000450304.2:4;Parent=ENST00000450304.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	70	80	.	-	.	ID=exon:ENST00000450304.2:5;Parent=ENST00000450304.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	85	95	.	-	.	ID=exon:ENST00000450304.2:6;Parent=ENST00000450304.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	transcript	2	98	.	+	.	ID=ENST00000450303.2;Parent=ENSG00000223972.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	2	98	.	+	.	ID=exon:ENST00000450302.2:1;Parent=ENST00000450303.2;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	transcript	2	98	.	-	.	ID=ENST00000450300.2;Parent=ENST00000450300.5;gene_id=ENSG00000223972.5"))
write(writer,GFF3.Record(b"chr1	HAVANA	exon	2	98	.	-	.	ID=exon:ENST00000450300.2:1;Parent=ENST00000450300.2;gene_id=ENSG00000223972.5"))
close(writer)

f2,file_stream = mktemp(tempdir())
writer = FASTA.Writer(file_stream)
write(writer,FASTA.Record("chr1", dna"TACTGCCTGCATAAGGAGAACGGAGTTGCCAAGGACGAAAGCGACTCTAGGTTCTAACCGTCGACTTTGGCGGAAAGGTTTCACTCAGGAAGCAGACACT"))
close(writer)

outRecords = Array{BioSequences.FASTA.Record,1}()
push!(outRecords,FASTA.Record("Seq", dna"TACTGCCTGCATAAGGAGAACAAGGACGAAAGCGACTCTAGGTTCTAACCGCTTTGGCGGAAAGGTT"))
push!(outRecords,FASTA.Record("Seq", dna"ACTGCCTGCATAAGACGGAGTTGCCAAGGAGAAAGCGACGGTTCTAACCGTCGACGCGGAAAGGTTTCAGGAAGCAG"))
push!(outRecords,FASTA.Record("Seq", dna"AACCTTTCCGCCAAAGCGGTTAGAACCTAGAGTCGCTTTCGTCCTTGTTCTCCTTATGCAGGCAGTA"))
push!(outRecords,FASTA.Record("Seq", dna"CTGCTTCCTGAAACCTTTCCGCGTCGACGGTTAGAACCGTCGCTTTCTCCTTGGCAACTCCGTCTTATGCAGGCAGT"))
push!(outRecords,FASTA.Record("Seq", dna"ACTGCCTGCATAAGGAGAACGGAGTTGCCAAGGACGAAAGCGACTCTAGGTTCTAACCGTCGACTTTGGCGGAAAGGTTTCACTCAGGAAGCAGACA"))
push!(outRecords,FASTA.Record("Seq", dna"TGTCTGCTTCCTGAGTGAAACCTTTCCGCCAAAGTCGACGGTTAGAACCTAGAGTCGCTTTCGTCCTTGGCAACTCCGTTCTCCTTATGCAGGCAGT"))

# Testing
@test outRecords == get_transcripts_from_gff(f2, f1)
