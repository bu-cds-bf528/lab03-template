#!/usr/bin/env nextflow

include {NCBI_DATASETS_CLI} from './modules/ncbi_datasets_cli'
include {PROKKA} from './modules/prokka'
include {EXTRACT_REGION} from './modules/extract_region'
include {SAMTOOLS_FAIDX} from './modules/samtools_faidx'
include {SAMTOOLS_FAIDX_SUBSET} from './modules/samtools_faidx_subset'


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

    // TODO: wire up NCBI_DATASETS_CLI, PROKKA, EXTRACT_REGION,
    // SAMTOOLS_FAIDX, and SAMTOOLS_FAIDX_SUBSET per SPEC.md > Pipeline steps.

    // TODO: Ensure you save the PROKKA outputs to `annot_ch`
    // TODO: Ensure you save the EXTRACT_REGION outputs to `region_ch`
    // TODO: Ensure you save the SAMTOOLS_FAIDX outputs to `faidx_ch`

    // GIVEN: We will talk in more detail later about what this is doing
    subset_ch = faidx_ch.join(region_ch, by: "name")
    faidx_out_ch = SAMTOOLS_FAIDX_SUBSET(subset_ch)

    publish:
    prokka_results = annot_ch

}

output {
    prokka_results {
        
    }
}
