#!/usr/bin/env nextflow

// Stage 5: the finished pipeline. Everything below the two GIVEN blocks is
// identical to Stage 4 — the only new task is combining the two independent
// branches (annot_ch/region_ch and faidx_ch) into SAMTOOLS_FAIDX_SUBSET.

include { NCBI_DATASETS_CLI } from './modules/ncbi_datasets_cli'
include { PROKKA } from './modules/prokka'
include { EXTRACT_REGION } from './modules/extract_region'
include { SAMTOOLS_FAIDX } from './modules/samtools_faidx'
include { SAMTOOLS_FAIDX_SUBSET } from './modules/samtools_faidx_subset'


workflow {

    // channel.fromPath makes the file available in the channel

    // splitCsv is an operator (https://docs.seqera.io/nextflow/reference/operator#splitcsv)

    // map is an operator that applies a function to each item from a channel
    // in this case, we are converting each row of the CSV into a record with
    // the elements found in the file
    main:
    download_ch = channel.fromPath(params.samplesheet)
    .splitCsv(header: true)
    .map{ row -> record(name: row.name, assembly: row.assembly)}

    // GIVEN: identical to Stage 4 — call each process, save its output to a
    // named channel, and pass that channel to the next process per
    // specifications.md > Pipeline steps.
    genome_ch = NCBI_DATASETS_CLI(download_ch)
    annot_ch = PROKKA(genome_ch)
    region_ch = EXTRACT_REGION(annot_ch)
    faidx_ch = SAMTOOLS_FAIDX(genome_ch)

    // TODO: Copy your working code from part2/09_join.nf for the join and save
    // it to a variable

    // TODO: Call the final process, SAMTOOLS_FAIDX_SUBSET on this joined channel

    publish:
    prokka_results = annot_ch

}

output {
    prokka_results {

    }
}
