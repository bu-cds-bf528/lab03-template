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
        region: file("${sample.name}_region_of_interest.txt")
    )

    script:
    // TODO: Make the script executable (chmod +x bin/extract_region.py)
    // Fill in the values after the -i and -o flags (By convention, -i  is the flag
    // used to pass the input to a script, and -o is the flag for passing how you
    // want the output file named

    // Use the values from the input record
    """
    extract_region.py -i -o 
    """

    stub:
    """
    touch ${sample.name}_region_of_interest.txt
    """

}
