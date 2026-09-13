#!/usr/bin/env nextflow

nextflow.enable.types = true

record IndexedGenomeRegion {
    name: String
    fna: Path
    fai: Path
    region: Path
}

record Subset {
    name: String
    subset_fna: Path
}

process SAMTOOLS_FAIDX_SUBSET {

    conda 'envs/samtools_env.yml'
    publishDir params.outdir, mode: 'copy'

    input:
    sample: IndexedGenomeRegion

    output:
    record(
        name: sample.name,
        subset_fna: file("${sample.name}_region.subset.fna")
    )

    shell:
    """
    samtools faidx ${sample.fna} -r ${sample.region} > ${sample.name}_region.subset.fna
    """

    stub:
    """
    touch ${sample.name}_region.subset.fna
    """
}
