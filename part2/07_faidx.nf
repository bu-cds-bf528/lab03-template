#!/usr/bin/env nextflow

// Stage 4, step 1: add SAMTOOLS_FAIDX as a second branch off genome_ch and
// view just its own output before assembling both branches in main.nf.

include { NCBI_DATASETS_CLI } from '../modules/ncbi_datasets_cli'
include { SAMTOOLS_FAIDX } from '../modules/samtools_faidx'

workflow {

    // GIVEN: the samplesheet-driven channel from Stage 3.
    request_ch = channel.fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map{ row -> record(name: row.name, assembly: row.assembly) }

    genome_ch = NCBI_DATASETS_CLI(request_ch)

    // NEW: a second, independent branch off genome_ch.
    faidx_ch = SAMTOOLS_FAIDX(genome_ch)

    faidx_ch.view()

}
