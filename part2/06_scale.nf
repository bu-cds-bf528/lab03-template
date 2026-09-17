#!/usr/bin/env nextflow

// Stage 3: same linear chain as Stage 2, but scaled to every sample in the
// samplesheet instead of one hardcoded request. See 05_scale_request.nf in
// this same directory to build and check just the new channel on its own
// first.

include { NCBI_DATASETS_CLI } from '../modules/ncbi_datasets_cli'
include { PROKKA } from '../modules/prokka'
include { EXTRACT_REGION } from '../modules/extract_region'

workflow {

    // TODO: replace Stage 2's channel.of(...) with a samplesheet-driven
    // channel — one AssemblyRequest record per row. See 05_scale_request.nf.


    // GIVEN: identical to Stage 2, just fed by request_ch now.
    genome_ch = NCBI_DATASETS_CLI(request_ch)
    annot_ch = PROKKA(genome_ch)
    region_ch = EXTRACT_REGION(annot_ch)

    region_ch.view()

}
