params {
    samplesheet = "${projectDir}/samplesheet.csv"
}


workflow {



    channel.fromPath(params.samplesheet)
    .view()


}
