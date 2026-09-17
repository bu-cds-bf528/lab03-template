#!/usr/bin/env nextflow

// Stage 1, step 1: just the starting channel — a single hardcoded request,
// wrapped in a channel of one item. Run this on its own first to see
// exactly what it produces.

// Notice that we have no processes, just a starting channel that contains
// some information

workflow {

    // Most of our workflows will start by making a channel that contains either
    // existing files (sequencing data) or information on how to download particular
    // samples (in this case, the genomic sequence of klebsiella)


    // We make a channel that contains a record with the fields name and assembly
    // assembly (GCF_XXX) will be used by the first tool to download this specific
    // genome and the `name` will be used for us to name files for identification
    // and tracking

    // We save this channel to a variable called request_ch
    request_ch = channel.of(record(name: 'Klebsiella_pneumoniae', assembly: 'GCF_000240185.1'))

    // .view() will print the contents of this channel to your terminal
    request_ch.view()

}
