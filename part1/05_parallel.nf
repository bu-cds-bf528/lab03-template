#!/usr/bin/env nextflow

// Part 1, step 5: branching. Sometimes you will need to send the same sample
// to different tasks. 

nextflow.enable.types = true

record Sample {
    name: String
    condition: String
}

process STEP_ONE_A {

    input:
    sample: Sample

    output:
    record(name: sample.name, condition: sample.condition, a_result: file("${sample.name}.step1a.log"))

    script:
    """
    echo "STEP_ONE_A processing ${sample.name} and ${sample.condition}" > ${sample.name}.step1a.log
    """
}

// TODO: declare a second branch process, STEP_ONE_B, structurally identical
// to STEP_ONE_A but with its own output field (e.g. b_result) and echo
// message — e.g. "STEP_ONE_B processing ${sample.name} and ${sample.condition}" > ${sample.name}.step1b.log
// Make sure you update all references to use the correct file generated (step1b)


workflow {

    // GIVEN: same samplesheet-driven channel as 04_scale.nf.
    csv_ch = channel.fromPath(params.part1_samplesheet).splitCsv(header: true).map{ row -> record(name: row.name, condition: row.condition) }

    // GIVEN: step1a
    step1a_results = STEP_ONE_A(csv_ch)
    step1a_results.view()


    // TODO: run STEP_ONE_B directly off the SAME sample_ch — a second,
    // independent branch, not chained after STEP_ONE_A. In theory, both
    // STEP_ONE_A and STEP_ONE_B should be able to run at the same time.


}
