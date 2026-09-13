# Lab 03 Pipeline Specification

## Objective

A Nextflow pipeline that takes a samplesheet of bacterial genome accessions
and produces, for each genome, the extracted genomic sequence of a single
gene of interest. It downloads the assembly, annotates it, picks a random
gene location, and extracts out that specific sequence. 

### Inputs

Samplesheet (CSV: `name`, `assembly`) — one row per bacterial genome, giving
a short name for the organism and its NCBI assembly accession
(e.g. `GCF_000287275.1`). The samplesheet is what drives the workflow and 
enables it to scale to any number of genomes if needded. 

### Outputs

- Per-sample: Prokka GFF annotation, genome FASTA index (`.fai`), a
  `region_of_interest.txt` coordinate file, and a subset FASTA containing
  the extracted gene sequence

### Pipeline steps

| Step | Input type | Depends on |
|---|---|---|
| `NCBI_DATASETS_CLI` | Samplesheet row (name + assembly accession) | None |
| `PROKKA` | Genome FASTA | `NCBI_DATASETS_CLI` |
| `EXTRACT_REGION` | GFF annotation | `PROKKA` |
| `SAMTOOLS_FAIDX` | Genome FASTA | `NCBI_DATASETS_CLI` |
| `SAMTOOLS_FAIDX_SUBSET` | Indexed genome (FASTA + `.fai`) + region coordinates | `SAMTOOLS_FAIDX`, `EXTRACT_REGION` |

Note that `PROKKA`/`EXTRACT_REGION` and `SAMTOOLS_FAIDX` form two
independent branches off the same downloaded genome — both must complete
before `SAMTOOLS_FAIDX_SUBSET` can run.

### Development workflow — build with stub-run first

Every process must define a `stub:` block producing placeholder output
files that match the real process's expected output names and types.
Build and validate the entire pipeline DAG using
`nextflow run main.nf -stub-run` before running on real data — this
verifies channel wiring, process dependencies, and record shapes in
seconds rather than waiting on real compute.


### Environment & reproducibility

Every process must declare its software environment explicitly via a
conda environment — pinning the exact tool version required. 

Conda environments are defined per-tool in `envs/*.yml`, referenced via
each process's `conda` directive, and invoked with `-profile local,conda`
(or `-profile cluster,conda` on the SCC). Tool versions: Nextflow (types
preview build), `ncbi-datasets-cli` 16.30.1, Prokka 1.14.6, samtools 1.20,
Biopython 1.78.

### Resource requirements

Each process must declare a resource `label` (`process_single`,
`process_low`, `process_medium`, or `process_high`, as defined in
`nextflow.config`) sized appropriately for its workload. 

Prokka is the most compute-intensive step here; the rest are light,
single-CPU, short-running tasks.

On the cluster, a label choice should be validated, not just guessed: after
a `-profile cluster,conda` run, use `qacct -j <native_id>` (job ID from
`nextflow log -f native_id`) on a completed task to check its actual
`maxvmem`/`cpu` against what the label requested.

### Success criteria

- **Stub-run milestone:** `nextflow run main.nf -stub-run -profile local,conda`
  completes end-to-end for both samples (`Carsonella_ruddii`,
  `Klebsiella_pneumoniae`) without errors, producing correctly-named
  placeholder outputs at every step, including `SAMTOOLS_FAIDX_SUBSET`.
- **Full-run milestone:** Pipeline runs end-to-end on both samples with
  `-profile local,conda` without manual intervention, producing a
  non-empty `<name>_region.subset.fna` for each genome.

### Out of scope

- **Gene selection logic:** which gene's coordinates get extracted is
  fixed by the provided `bin/extract_region.py` script and is not
  something the pipeline chooses or validates.
- **Read alignment / short-read indexing:** building an aligner index and
  mapping reads is a related but separate problem (discussed later in the
  course) — not part of this pipeline.
- **Circos plot visualization:** generated separately in a Jupyter
  notebook against the pipeline's outputs, not orchestrated by Nextflow.
