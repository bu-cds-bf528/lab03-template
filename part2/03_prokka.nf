#!/usr/bin/env nextflow

// Stage 2, step 1: chain PROKKA off Stage 1's genome_ch and view just its
// own output before adding EXTRACT_REGION in main.nf.

include { NCBI_DATASETS_CLI } from '../modules/ncbi_datasets_cli'
include { PROKKA } from '../modules/prokka'

workflow {

    // GIVEN: same as Stage 1.
    request_ch = channel.of(record(name: 'Klebsiella_pneumoniae', assembly: 'GCF_000240185.1'))
    genome_ch = NCBI_DATASETS_CLI(request_ch)

    // NEW: chain PROKKA off genome_ch.
    annot_ch = PROKKA(genome_ch)

    annot_ch.view()

}
