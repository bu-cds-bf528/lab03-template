#!/usr/bin/env nextflow

nextflow.enable.types = true

record Genome {
    name: String
    fna: Path
}

record IndexedGenome {
    name: String
    fna: Path
    fai: Path
}

process SAMTOOLS_FAIDX {
    conda "envs/samtools_env.yml"

    // TODO: Fill in the input and output for this process

    // Hint: You can use the * in bash to capture any file ending in a certain
    // pattern. The index will end in ".fna"


    shell:
    """
    samtools faidx ${sample.fna}
    """

    stub:
    """
    touch ${sample.name}.stub.fai
    """
}
