params {
    samplesheet = "${projectDir}/samplesheet.csv"
}


workflow {

    channel.fromPath(params.samplesheet)
    .splitCsv(header: true)
    .map{ row -> record(name: row.name, assembly: row.assembly)}
    .view{ it -> "Class: ${it.getClass()}" }
    .view()


}
