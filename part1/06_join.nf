#!/usr/bin/env nextflow

// Part 1, step 6: join. Combine the outputs of two processes
// by joining their records together for a process that requires both
// We will join on a key, a matching field found in both records

nextflow.enable.types = true

record Sample {
    name: String
    condition: String
}

// GIVEN: two independent branches off the same starting channel

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

record StepOneA {
    name: String
    condition: String
    a_result: File
}


process STEP_ONE_B {

    input:
    sample: Sample

    output:
    record(name: sample.name, condition: sample.condition, b_result: file("${sample.name}.step1b.txt"))

    script:
    """
    echo "STEP_ONE_B processing ${sample.name} and ${sample.condition}" > ${sample.name}.step1b.txt
    """
}

record StepOneB {
    name: String
    condition: String
    b_result: File
}

process FINAL {

    input:
    sample: Final
    
    output:
    record(name: sample.name, out: file("final_file.txt"))

    script:
    """
    echo "THIS PROCESS CATS / COMBINES THE RESULT FROM STEP ONE A AND THE RESULT FROM STEP ONE B"
    cat ${sample.a_result} ${sample.b_result} > final_file.txt
    """

}

record Final {
    name: String
    condition: String
    a_result: File
    b_result: File
}

workflow {

    // GIVEN: same samplesheet-driven channel as 04_scale.nf.
    csv_ch = channel.fromPath(params.part1_samplesheet).splitCsv(header: true).map{ row -> record(name: row.name, condition: row.condition) }

    step1a_results = STEP_ONE_A(csv_ch)
    step1b_results = STEP_ONE_B(csv_ch)

    // TODO: Use the `join` operator to create and view the merged record — this
    // is exactly what Stage 5 needs to do with faidx_ch and region_ch. You'll
    // notice that the two output channels share a common key (name), which can be
    // used to join their contents together. After using .view() to determine
    // it has the right contents, save it to a variable called join_ch and call 
    // the FINAL process on it

    // Feel free to view both the joined_ch as well as the output from calling
    // FINAL

    

}
