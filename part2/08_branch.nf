#!/usr/bin/env nextflow

// Stage 4: add a second, independent branch off genome_ch. PROKKA/
// EXTRACT_REGION and SAMTOOLS_FAIDX both consume NCBI_DATASETS_CLI's output,
// but neither branch depends on the other — run and inspect them separately.
// They get combined into one branch in Stage 5 (../main.nf). See
// 07_faidx.nf in this same directory for a view of just the new branch on
// its own.

include { NCBI_DATASETS_CLI } from '../modules/ncbi_datasets_cli'
include { PROKKA } from '../modules/prokka'
include { EXTRACT_REGION } from '../modules/extract_region'
include { SAMTOOLS_FAIDX } from '../modules/samtools_faidx'

workflow {

    // GIVEN: identical to Stage 3.
    request_ch = channel.fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map{ row -> record(name: row.name, assembly: row.assembly) }

    genome_ch = NCBI_DATASETS_CLI(request_ch)
    annot_ch = PROKKA(genome_ch)
    region_ch = EXTRACT_REGION(annot_ch)

    // NEW: a second branch off genome_ch, independent of the annotation
    // branch above.
    faidx_ch = SAMTOOLS_FAIDX(genome_ch)

    region_ch.view{ it -> "annotation branch: ${it}" }
    faidx_ch.view{ it -> "faidx branch:      ${it}" }

}
