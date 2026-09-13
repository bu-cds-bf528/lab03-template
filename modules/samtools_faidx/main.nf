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

    // TODO: declare input: (a Genome record, named `sample` — see the
    // script below) and output: (build an IndexedGenome record — see
    // SPEC.md > Pipeline steps). `fna` is just passed through from the
    // input; `fai` is produced by the command below.


    shell:
    """
    samtools faidx ${sample.fna}
    """

    stub:
    """
    touch ${sample.name}.stub.fai
    """
}
