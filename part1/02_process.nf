#!/usr/bin/env nextflow

// Part 1, step 2: your process. This process creates a new file with the info
// passed in from the original channel. Note that the process's output record 
// carries that newly created file forward, the same way the real pipeline's 
// NCBI_DATASETS_CLI carries its downloaded .fna forward in a Genome record.

nextflow.enable.types = true

record Sample {
    name: String
}

process STEP_ONE {

    // TODO: declare this process's input (a Sample record, named `sample`
    // — see the script below) and output. 
    

    // TODO: Declare an output record that contains both the name and the newly
    // created file.

    // Records declared in the output do not need to specify type (it is inferred)
    //
    // record(example_string: example_value, 
    //        example_file: file("${input.variable}.log")
    //  )
    // in the record, include `name: sample.name` (look at the record at the top)
    // Also include the new file created, `log: file("${sample.name}.log")
    


    // GIVEN: When this runs, it will print the value held in sample.name to the
    // file named sampleA.log
    script:
    """
    echo "STEP_ONE processing ${sample.name}" > ${sample.name}.log
    """

}

workflow {

    // GIVEN: one hardcoded sample, run through STEP_ONE.
    sample_ch = channel.of(record(name: 'sampleA'))
    step_one_ch = STEP_ONE(sample_ch)
    step_one_ch.view()

}
