#!/usr/bin/env nextflow

// Stage 1: one process, one hardcoded sample. The only goal here is to see
// a single process run end-to-end and to get comfortable reading its output
// record.

// This is conceptually similar to `import` in python and allows us to call the
// NCBI_DATASETS_CLI process located in modules/ncbi_datasets_cli/main.nf

include { NCBI_DATASETS_CLI } from '../modules/ncbi_datasets_cli'

// the workflow block defines how processes are connected to each other
// you call processes by their name as defined in `include`

workflow {

    // GIVEN: a single hardcoded request, wrapped in a channel of one item.
    // See 01_request.nf in this same directory to view this on its own.
    request_ch = channel.of(record(name: 'Klebsiella_pneumoniae', assembly: 'GCF_000240185.1'))

    // GIVEN: call the process, capture its output channel in a named variable.
    genome_ch = NCBI_DATASETS_CLI(request_ch)

    genome_ch.view()

}
