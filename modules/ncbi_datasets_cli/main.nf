#!/usr/bin/env nextflow

nextflow.enable.types = true

// TODO: declare the AssemblyRequest record — see SPEC.md > Inputs
// Fields: name (String), assembly (String)


// TODO: declare the Genome record — see SPEC.md > Pipeline steps
// Fields: name (String), fna (Path)


process NCBI_DATASETS_CLI {
    conda 'envs/ncbidatasets_env.yml'

    input:
    request: AssemblyRequest

    output:
    record(
        name: request.name,
        fna: file('dataset/**/*.fna')
    )

    script:
    """
    datasets download genome accession ${request.assembly} --include genome
    unzip ncbi_dataset.zip -d dataset/
    """

    stub:
    """
    mkdir -p dataset/stub/
    touch dataset/stub/stub.fna
    """

}
