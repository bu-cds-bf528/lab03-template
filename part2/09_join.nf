#!/usr/bin/env nextflow

// Stage 5, step 1: combine the two branches from Stage 4 and check the
// shape of the joined channel before calling SAMTOOLS_FAIDX_SUBSET on it
// in ../main.nf.

include { NCBI_DATASETS_CLI } from '../modules/ncbi_datasets_cli'
include { PROKKA } from '../modules/prokka'
include { EXTRACT_REGION } from '../modules/extract_region'
include { SAMTOOLS_FAIDX } from '../modules/samtools_faidx'

workflow {

    // GIVEN: identical to Stage 4.
    request_ch = channel.fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map{ row -> record(name: row.name, assembly: row.assembly) }

    genome_ch = NCBI_DATASETS_CLI(request_ch)
    annot_ch = PROKKA(genome_ch)
    region_ch = EXTRACT_REGION(annot_ch)
    faidx_ch = SAMTOOLS_FAIDX(genome_ch)

    // TODO: combine faidx_ch and region_ch into one channel keyed by name.
    // Nextflow's .join(by: "name") operator combines two channels on a
    // shared field — see
    // https://docs.seqera.io/nextflow/reference/operator#join


    subset_ch.view()

}
