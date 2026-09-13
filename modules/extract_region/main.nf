#!/usr/bin/env nextflow

nextflow.enable.types = true

record Annotation {
    name: String
    gff: Path
}

record Region {
    name: String
    region: Path
}

process EXTRACT_REGION {
    conda 'envs/biopython_env.yml'
    container 'ghcr.io/bf528/biopython:latest'

    input:
    sample: Annotation

    output:
    record(
        name: sample.name,
        region: file("{sample.name}_region_of_interest.txt")
    )

    script:
    // TODO: call extract_region.py with the right flags. Look at its
    // argparse block (-i/--input, -o/--output) to see what it expects, and
    // use ${sample.gff} as the input. Remember to make the script executable.
    """

    """

    stub:
    """
    touch ${sample.name}_region_of_interest.txt
    """

}
