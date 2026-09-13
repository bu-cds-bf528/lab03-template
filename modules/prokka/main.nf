#!/usr/bin/env nextflow

nextflow.enable.types = true

record Genome {
    name: String
    fna: Path
}

record Annotation {
    name: String
    gff: Path
}

process PROKKA {
    conda 'envs/prokka_env.yml'
    publishDir params.outdir, mode: 'copy'

    input:
    sample: Genome

    output:
    // TODO: construct an Annotation record (see "Records and static typing"
    // in the README). It should contain the name that was passed in the input
    // and the GFF file that was created by Prokka when it finishes

    // Hint: PROKKA creates a new directory inside this working directory. Inside
    // of that directory is a file ending in .gff. The answer will use a combination
    // of file(), **, and *.gff. Look up the usage of * and ** in bash.


    script:
    def args = task.ext.args ?: ''
    """
    prokka --cpus 1 --outdir ${sample.name} --prefix ${sample.name} ${args} ${sample.fna}
    """

    stub:
    """
    mkdir -p ${sample.name}/
    touch ${sample.name}/stub.gff
    """
}
