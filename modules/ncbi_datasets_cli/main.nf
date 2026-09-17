#!/usr/bin/env nextflow

nextflow.enable.types = true

// TODO: declare the AssemblyRequest record with fields name (String), and
// assembly (String)


// TODO: declare the Genome record with fields name (String), and fna (Path)


process NCBI_DATASETS_CLI {
    conda 'envs/ncbidatasets_env.yml'

    input:
    request: AssemblyRequest

    output:
    record(
        name: request.name,
        fna: file("dataset/**/*.fna")
    )

    script:
    """
    datasets download genome accession ${request.assembly} --include genome
    unzip ncbi_dataset.zip -d dataset/
    """

    stub:
    """
    mkdir -p dataset/stub/
    touch dataset/stub/${request.name}.fna
    """

}
