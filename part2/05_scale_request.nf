#!/usr/bin/env nextflow

// Stage 3, step 1: build request_ch from the samplesheet instead of a
// hardcoded value, and check it in isolation before wiring it into the
// rest of the chain in 06_scale.nf. Run part1/04_scale.nf first if you
// haven't — this is the same fromPath/splitCsv/map chain, applied to the
// real pipeline's samplesheet.

workflow {

    // TODO: build request_ch from params.samplesheet:
    // channel.fromPath(params.samplesheet) -> .splitCsv(header: true) ->
    // .map{ row -> record(name: row.name, assembly: row.assembly) }


    request_ch.view()

}
