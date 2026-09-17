#!/usr/bin/env nextflow

// Part 1, step 1: record types and construction — this will usually be the
// starting point for a pipeline. You will create a channel that contains the
// starting files (FASTQ) or information on how to download or obtain some starting
// data file. 

// In this lab, you have the information about the ID of a particular genome that 
// we want to download from a database. 

nextflow.enable.types = true

// GIVEN: a record type that bundles a sample's name together with its
// associated file — the same "name + file" shape you'll see throughout
// the real pipeline (e.g. a Genome record bundles a name with its .fna).

record Sample {
    name: String
    fastq: String
}

// TODO: declare your own record type here, called AlignedSample, that
// bundles a `name` field (String) with a `bam` field (Path) — the file
// that name's alignment would produce.



workflow {

    // GIVEN: constructs an instance of the Sample record. Note
    // how the fastq field is named after the sample — the record bundles
    // the two together as one unit instead of tracking them separately.
    example_ch = channel.of(record(name: 'sample1', fastq: 'sample1.fastq.gz'))
    example_ch.view()

    // TODO: construct an instance of an AlignedSample using sample2 as the name
    // found in the name field and the name of the bam field. 

    

    // Don't change any code following this line:
    your_ch.view()






}
