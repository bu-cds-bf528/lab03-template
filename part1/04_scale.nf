#!/usr/bin/env nextflow

// Part 1, step 4: scale to a CSV.
// This is exactly the fromPath/splitCsv/map pattern the real pipeline
// uses to read samplesheet.csv. This will make channels containing multiple
// records. In our case, it will usually be 1:1 (1 record for every row of data
// in our CSV)

nextflow.enable.types = true

record Sample {
    name: String
    condition: String
}

// GIVEN: same two-step chain as 03_chain.nf. We have added one more field,
// condition, to hold the value from the condition column of the CSV

process STEP_ONE {

    input:
    sample: Sample

    // Note how we are just passing the same name and condition in the output
    // that came from the initial record from the CSV
    output:
    record(name: sample.name, condition: sample.condition, log: file("${sample.name}.log"))

    script:
    """
    echo "STEP_ONE processing ${sample.name} and ${sample.condition}"  > ${sample.name}.log
    """
}

record StepOne {
    name: String
    condition: String
    log: Path
}

process STEP_TWO {

    input:
    sample: StepOne

    output:
    record(name: sample.name, condition: sample.condition, log: file("${sample.name}.step2.log"))

    script:
    """
    cat $sample.log > ${sample.name}.step2.log
    echo "STEP_TWO processing ${sample.name} and ${sample.condition}" >> ${sample.name}.step2.log
    """
}

workflow {

    // TODO: read every row of the samplesheet
    // into a channel of records: channel.fromPath(params.part1_samplesheet),
    // .splitCsv(header: true), .map{ row -> record(name: row.name, condition:
    // row.condition) }.

    // channel.fromPath creates a channel with the toy_samplesheet.csv
    // .splitCsv() is a built-in function that parses each row of the CSV
    // .map() transforms the output of .splitCsv() to the record type. Chain them
    // together one after another

    // Use .view() to see the channel first. When it has the correct structure,
    // remove the .view() operator and save this to a variable called `csv_ch`.


    // GIVEN: run the same chain from 03_chain.nf, now driven by
    // sample_ch's multiple rows instead of one hardcoded sample.
    step1_ch = STEP_ONE(csv_ch)
    step2_ch = STEP_TWO(step1_ch)
    step2_ch.view()

}
