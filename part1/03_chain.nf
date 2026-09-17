#!/usr/bin/env nextflow

// Part 1, step 3: chaining. Pass one process' output to the next

nextflow.enable.types = true

record Sample {
    name: String
}

// GIVEN: same as 02_process.nf — note the output carries forward the
// .log file this process actually creates as well.

process STEP_ONE {

    input:
    sample: Sample

    output:
    record(name: sample.name, log: file("${sample.name}.log"))

    script:
    """
    echo "STEP_ONE processing ${sample.name}" > ${sample.name}.log
    """
}

record StepOne{
    name: String
    log: File

}

// TODO: Complete the STEP_TWO process output based on the file created in the
// script

// It should take the StepOne record as input

process STEP_TWO {

    input:
    sample: StepOne

    // TODO: Make a record that has the fields name and log. The name should be the 
    // same name from the input record. The name of the file created can be seen
    // in the script command
    

    script:
    """
    cat $sample.log > ${sample.name}.step2.log
    echo "STEP_TWO processing ${sample.name}" >> ${sample.name}.step2.log
    """
}

workflow {

    sample_ch = channel.of(record(name: 'sampleA'))

    // GIVEN: run STEP_ONE.
    step1_ch = STEP_ONE(sample_ch)

    // TODO: chain STEP_TWO after STEP_ONE — call it on step1_ch, save the
    // result to its own named channel, and view it.
    

}
