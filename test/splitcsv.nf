params {
    samplesheet = "${projectDir}/samplesheet.csv"
}

workflow {

    channel.fromPath(params.samplesheet)
    .splitCsv(header: true)
    .view{ it -> "Class: ${it.getClass()}" }
    .view()


}
