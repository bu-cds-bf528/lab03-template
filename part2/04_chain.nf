#!/usr/bin/env nextflow

// Stage 2: linear chain, still one hardcoded sample. Builds directly on
// Stage 1 — same request_ch and NCBI_DATASETS_CLI call — but now chains two
// more processes after it. No branching yet. See 03_prokka.nf in this same
// directory for a view of just the first new step (PROKKA) on its own.

include { NCBI_DATASETS_CLI } from '../modules/ncbi_datasets_cli'
include { PROKKA } from '../modules/prokka'
include { EXTRACT_REGION } from '../modules/extract_region'

workflow {

    // GIVEN: same as Stage 1.
    request_ch = channel.of(record(name: 'Klebsiella_pneumoniae', assembly: 'GCF_000240185.1'))
    genome_ch = NCBI_DATASETS_CLI(request_ch)

    // NEW: chain PROKKA and EXTRACT_REGION off genome_ch. Save each
    // process's output to its own named channel and pass it to the next.
    annot_ch = PROKKA(genome_ch)
    region_ch = EXTRACT_REGION(annot_ch)

    region_ch.view()

}
