# Lab 03 - Creating a nextflow workflow for multiple samples

## Objective

Today we are going to get more experience putting together a 
bioinformatics pipeline in nextflow. This pipeline will download
multiple bacterial genomic sequences, annotate them using Prokka
and choose a single gene's coordinates from the GFF created, make
a FASTA index of the genome, and extract out the genomic sequence
of the chosen gene. 

We will then use a jupyter notebook to generate a quick visualization
of the gene annotations in the form of a circos plot.

Practically, you will read a specification document of the pipeline
and then connect all the processes together in the `main.nf`. This
lab will expose you to a number of concepts and aspects of nextflow
that you will be using throughout the semester. 


## Key Concepts and Tools

A quick index of everything this lab introduces, and where to find it below.

**Modularization**
- You can see that we no longer have processes in `main.nf`. Instead, they are defined in their own directories under modules/. Each process gets a separate .nf file that defines its inputs, outputs, and command. 

**Tools this pipeline runs**
- `ncbi-datasets-cli` genome downloads — see "ncbi_datasets_cli"
- Prokka genome annotation, GFF files — see "prokka"
- `samtools faidx`, FASTA index (`.fai`), region coordinates (`chr:start-end`) — see "Small aside - FASTA Indexes", "samtools_faidx", and "samtools_faidx_subset"

**Static typing**
- Records and dot notation — see "Records and static typing"

**Running and configuring the pipeline**
- `stub` block, `-stub-run` flag — see "Stub runs (-stub-run)"
- `ext.args`, `task.ext.args ?: ''`, `withName:` process selector — see "Process configuration: ext.args and withName:"

**Debugging**
- `nextflow log`, `-f` fields, `-filter` expressions — see "Debugging with nextflow log and the work directory"
- `.command.sh`, `.command.err`, `.exitcode` in the work directory — see "Debugging with nextflow log and the work directory"

**Once your pipeline works** — quality-of-life features, not required for a working pipeline
- `-with-report`, `-with-timeline`, `-with-dag` — see "Once your pipeline works"
- `resume` in `nextflow.config` — see "Once your pipeline works"
- Process `label`s and resource requests in `nextflow.config` — see "Once your pipeline works"
- `nextflow lint`, `nextflow inspect`, and how `nf-core lint` differs — see "Once your pipeline works"

**Analysis**
- Jupyter notebooks, conda environments for analysis, circos plots (`pyCirclize`) — see "Lab03 Tasks - Jupyter Notebooks (Together)"

## Small aside - FASTA format

FASTA is a simple text format for representing nucleotide or protein
sequences. Each record starts with a header line beginning with `>`
containing an identifier and optional description, followed by one or more
lines of sequence characters. For example:

```
>NC_016845.1 Klebsiella pneumoniae subsp. pneumoniae chromosome
ATGGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGCTAGC...
```

We'll only need to know this much for today's lab — we'll cover the FASTA
format (and related formats like FASTQ) in much more detail later in the
course.

## Small aside - FASTA Indexes 

Though the genomes we are working with today are relatively
small, it can still be cumbersome to work with such large sequences.
For example, let's say we know that a specific region of the genome
should correspond to a specific gene and we want to extract out just that
sequence of gene. The most straightforward (and naive) method
would be to read through the entire genome until we find that sequence.

While this may finish quickly for smaller genomes, we can take
advantage of the regular structure of files and create an index that
allows us to more quickly retrieve sequences from a FASTA file by
its coordinates. This index contains information about the length of the
overall sequence, the position in the file where the sequence begins and
the number of characters and bytes per line. This information together
can allow us to extract a subsequence from the original by specifying it's
coordinates or range. Importantly, this index prevents us from having to 
read the file beginning to end. You can think of this as being akin to 
a table of contents in a book. 

This idea can also be extended to the problem of aligning short sequences
to a reference sequence. We will need to build a special index (data structure)
that allows us to more efficiently find the best alignment of a short read
in a much longer sequence. Every alignment algorithm will require you to first
build an index that will enable the algorithm to efficiently and more quickly
align reads. These indexes are unique to each tool and algorithm and are typically
created using a different command provided by the software. 

Returning to FASTA indexes, by convention, these indexes are a new file with
the .fai extension added directly to the end of the original name. Tools that
utilize these indexes expect that the original FASTA and the .fai index are in
the same location.

To extract out a random sequence by its location, you will need the original
FASTA, the index file, and the region you want the sequence of in the format of
`chr_name:start_pos-end_pos` or `NC_016845.1:18065-20962`. We will extract out
this region by looking at the GFF file of the genomes. 

## Background

## Records and static typing

This lab formally introduces Nextflow's static typing and `record` types. A
record is a named bundle of fields, declared like this:

```nextflow
record Genome {
    name: String
    fna: Path
}
```

As a general simplification, you can think of records as akin to dictionaries 
or named tuples in python, though there's obvious differences between all of 
these data structures. We will use records to "bundle" together important related
pieces of information. For us practically, records will typically hold some sort of
name or sample identifier, and files, either starting or generated. 

A process that uses records takes a single typed parameter:

```nextflow
input:
sample: Genome
```

and accesses fields by name (`sample.name`, `sample.fna`) rather than by
position. The name `sample` assigned in this input is specific and local
to this module. It will allow you to internally reference the elements
of the Genome record using sample.name or sample.fna, which are the corrresponding
elements in the named record `Genome`. 

Outputs are constructed with the `record(...)` function, e.g.:

```nextflow
output:
record(
    name: String = sample.name,
    fna: Path = file('some_output.fna')
)
```

Records are declared right at the top of each module file, next to the
process that uses them, so you can see the exact shape of the data flowing
in and out without having to trace it through the workflow. You'll notice the
same record (e.g. `Genome`) is declared independently in more than one
module — that's intentional. Nextflow records are duck-typed: a value
satisfies a record type as long as it has the required fields, so it doesn't
matter that the record was declared in a different file.

Every file that declares or calls a typed process needs the feature flag at
the top:

```nextflow
nextflow.enable.types = true
```

This is still a preview feature in Nextflow, so expect a warning printed at
runtime. 

## Setup

- [ ] Clone the provided classroom50 link

- [ ] As always, remember to activate your environment with nextflow installed

- [ ] Notice the new structure of our `main.nf`. We have made new scripts
for our processes in the modules/ directory and now will have to use
`include` to import those processes into our `main.nf` and use them
in our workflow. 

## Given vs. what you write

**Given, working — read but you don't need to edit these:**
- `modules/samtools_faidx_subset` — fully complete
- `bin/`, `envs/`, `nextflow.config`, `samplesheet.csv`

**You write:**
- [ ] `modules/ncbi_datasets_cli` — the `AssemblyRequest` and `Genome` record types
- [ ] `modules/prokka` — the output `record(...)` construction
- [ ] `modules/extract_region` — the `script:` command
- [ ] `modules/samtools_faidx` — the `input:`/`output:` block
- [ ] `main.nf` — the entire workflow: the starting channel and every process wired together

`specifications.md` describes what the pipeline as a whole needs to do — read it
before you start, and refer back to it for the exact record shapes each
step consumes and produces.

## Lab 03 Tasks - Nextflow

Read `specifications.md` first as it describes the whole pipeline (inputs,
outputs, per-step dependencies, environments, resource requirements)
independent of any code. Everything below assumes you've read it.

Four of the five modules are given complete except for one small piece
each and the fifth (`samtools_faidx_subset`) is given complete. `main.nf` is
given nothing but the `include`s and a starting-channel skeleton — that's
where most of the actual pipeline design happens.

### ncbi_datasets_cli — declare the record types

Everything in this module is given except the two `record` blocks at the
top: `AssemblyRequest` (its input) and `Genome` (its output). See
`specifications.md` for the field shapes each needs. Once declared, the rest of the
process (input/output/script/stub) references them as-is.

### prokka — construct the output record

The `Genome` and `Annotation` record *declarations* are given, along with
the input block, the script, and the stub. What's missing is the
`output:` block itself — construct an `Annotation` record from `sample`
(the input `Genome` in scope) using the `record(...)` syntax (see
"Records and static typing" above). The GFF file Prokka produces is named
after `sample.name` — look at the script to see exactly where.

### extract_region — write the script command

Records and the input/output blocks are given. What's missing is the
`script:` block: call `extract_region.py` with the right flags. Look
at the script's `argparse` block (`-i`/`--input`, `-o`/`--output`) to see
what it expects, and remember to make the script executable.

### samtools_faidx — declare input and output

The script (a `shell:` block using `samtools faidx ${sample.fna}`) and the
stub are given — that script tells you the input parameter must be named
`sample`. What's missing is the `input:`/`output:` block: declare
`sample` as a `Genome`, and construct the `IndexedGenome` output record.
`fna` is just passed through from the input; `fai` is produced by the
command.

### samtools_faidx_subset — given, read-only

This module is complete. Its input, `IndexedGenomeRegion`, doesn't come
from a single upstream process — it's the result of combining the
`IndexedGenome` from `samtools_faidx` with the `Region` from
`extract_region`. Read this module to see exactly what shape `main.nf`
needs to hand it; building that combined channel is part of the `main.nf`
task below.

### main.nf — build the whole workflow

This is the main task. You need to:

- [ ] **Ensure you understand the initial channel generation**, Look at the 
   provided lines in the main.nf from lines 20-22. Run the provided `test.nf`
   to see what these lines will produce.
- [ ] **Call each process**, wiring each one's output to the next process's
   input, per `specifications.md` > Pipeline steps.


## Stub runs are a feature in nextflow that will allow you to develop and troubleshoot your workflow logic

Now that we are developing real processes and will be submitting them
to the cluster, you have likely seen already that this can take a fair amount
of time to finish. For nextflow to work correctly, you will need both the `workflow`
to link the processes together and the commands in the `processes` to finish 
successfully. Since these processes can take a long time to potentially run, it 
can be difficult to figure out if we have constructed the `workflow` correctly. 

Nextflow offers a function called a stub run (-stub-run). This option
you can use when running nextflow will not run any of the commands in
the script, but instead run the commands found in the `stub` block. If
you look at the processes I have given you, you can see that the `stub`
block uses commands like `mkdir` and `touch`. `touch` is a linux command
that can be used to create an empty file with a specified name. 

If you setup your `stub` block smartly, you can mimic the outputs that 
a process should produce when it finishes running. This will allow you
to test if your workflow logic and channel manipulation is correct without
having to know the correct commands for each tool. `touch` happens instantaneously
so stub runs will finish in a matter of seconds no matter how complicated
your pipeline is. `touch` is also a basic utility in linux and generally comes
pre-installed.

For all the modules, I have provided you a working `stub` block that will
create the right outputs for you to quickly troubleshoot your workflow.

- [ ] When you have completed all the steps above, please run your pipeline with
`nextflow run main.nf -stub`

## Process configuration: ext.args and withName:

So far, every command in our `script:` blocks has been fully hard-coded. In
practice you'll often want to tweak a tool's flags per-run or per-process
without editing the module itself — that's what `ext.args` is for.

Inside a process, `task.ext.args` reads a value set from `nextflow.config`.
It isn't set by default, so always guard it with the Elvis operator (`?:`)
so the process still works if nobody configures it:

```nextflow
script:
def args = task.ext.args ?: ''
"""
sometool ${args} $input
"""
```

`?:` is Groovy's **Elvis operator** — shorthand for `x ? x : y`: "use `x` if
it's truthy, otherwise fall back to `y`." So `task.ext.args ?: ''` reads as 
"use whatever `ext.args` was configured to, or an empty string if it was never 
set." You'll see this pattern constantly anywhere Nextflow code reads an optional
config value, since almost none of them are set by default.

You set that value using a `withName:` selector in `nextflow.config`, which
targets one specific process by name — as opposed to `withLabel:`, which you
already used to target every process sharing a label:

```nextflow
process {
    withName: 'PROKKA' {
        ext.args = '--kingdom Bacteria'
    }
}
```

- [ ] **Try it yourself:** `modules/prokka/main.nf` reads `task.ext.args ?: ''`,
and `nextflow.config` sets `--kingdom Bacteria` for `PROKKA` via `withName:`.
Run the **full pipeline** (not `-stub-run` — a `stub:` block replaces
`script:` entirely, so `ext.args` never gets substituted into it) and then
check `.command.sh` for the `PROKKA` task (see "Debugging with nextflow log
and the work directory" below) — you should see `--kingdom Bacteria` in the
command that actually ran.

## Debugging with nextflow log and the work directory

Every process execution happens in its own isolated directory under `work/`,
and Nextflow keeps a record of every run you've done. These two tools are
how you find out what actually happened when something fails — or, like
above, how you confirm a config change actually took effect.

`nextflow log` on its own lists every run you've executed in this directory,
by its randomly-generated run name (e.g. `tiny_leavitt`). To see which
fields are available, use `-list-fields`. To print specific fields for a
run's tasks:

```bash
nextflow log <run_name> -f process,status,exit,duration,workdir
```

You can narrow this down with `-filter`, using a Groovy boolean expression
over those fields:

```bash
nextflow log <run_name> -filter 'process == "PROKKA"'
```

The `workdir` field above gives you the exact path to inspect. Every task's
work directory contains, among other things:

- `.command.sh` — the exact script Nextflow generated and ran (or would have
  run, for a stub run). This is where you go to confirm `ext.args` was
  actually substituted into the command.
- `.command.run` — the wrapper script Nextflow actually submits to the
  executor. It sets up the environment (e.g. activating the conda env) and
  invokes `.command.sh` inside it, wrapped with the bookkeeping Nextflow
  needs to detect completion.
- `.command.out` — stdout from the task.
- `.command.err` — stderr from the task; usually the first place to look
  when a task fails.
- `.command.log` — the merged stdout+stderr stream Nextflow polls to know
  when the task has finished.
- `.command.begin` — an empty marker file written the instant the task
  starts running (used to compute start time / wait time).
- `.exitcode` — the exit status of the task's command.
- `.command.trace` — periodic resource-usage samples (CPU, memory, I/O)
  collected while the task ran; this is the raw data behind `-with-report`.

If you've submitted jobs to the SCC directly with `qsub` before, `.command.out`
and `.command.err` are Nextflow's equivalent of the `.o<jobid>`/`.e<jobid>`
files a bare SGE job writes — same idea, different naming convention.

```bash
cd $(nextflow log <run_name> -filter 'process == "PROKKA"' -f workdir | head -1)
cat .command.sh
cat .command.out
cat .command.err
cat .exitcode
```

## Once your pipeline works

The features below are mostly conveniences and production-pipeline
hygiene, not things a working pipeline strictly needs. Get your full run
passing first (see "Definition of done" below), then come back and layer
these on.

- [ ] **Execution reports** — generate `-with-report`, `-with-timeline`, and
      `-with-dag` output for a run and look at what each one shows you.
- [ ] **Resume** — understand what `resume = true` in `nextflow.config` does
      and when you'd want to turn it off.
- [ ] **Labels** — add a resource `label` to each process in your pipeline.
- [ ] **Custom label** — define and size your own label for one process,
      using the SCC's resource request documentation.
- [ ] **Linting** — run `nextflow lint` (and `nextflow lint -format`) on your
      pipeline.

### Execution reports (-with-report, -with-timeline, -with-dag)

Nextflow can generate several different reports about a run, each showing
you something different:

- `-with-report report.html` — resource usage per process: CPU, memory, and
  time, in a sortable HTML table.
- `-with-timeline timeline.html` — a Gantt-chart-style view of when each task
  started and finished, useful for spotting bottlenecks.
- `-with-dag pipeline.png` — a diagram of how your processes and channels
  connect. Rendering a `.png` requires Graphviz to be installed; use a
  `.html` or `.mmd` extension instead if it isn't.

You can combine all three on the same run:

```bash
nextflow run main.nf -profile local,conda -with-report report.html -with-timeline timeline.html -with-dag pipeline.png
```

Open the generated files and see what they show you.

### Resume

If you look at the last line of the `nextflow.config`, you can see an option specified
`resume = true`. When nextflow runs, it caches information about jobs that have successfully
finished. With this option, if your pipeline failed at a later step, nextflow will not re-run
steps that have already finished. 

There are times when you want your pipeline to start from the beginning, in which case, you will
want to change this value to `resume = false` or you can delete the directories in `work/` to
force nextflow to re-run everything. You can avoid deleting the `conda/` directory in `work/` so
nextflow doesn't have to remake the environments. 

### Labels

Add a resource `label` (`process_single`, `process_low`, `process_medium`,
or `process_high`) to each process — these are a way to ensure that your
jobs request the right number of CPUs or the right amount of memory. We
define the resources that are requested by these labels in the
`nextflow.config`. You'll notice these are the same options you would
specify in a `qsub` command. See `specifications.md` > Resource
requirements for which processes need more than the default.

A label isn't just documentation — under `-profile cluster`, the
`withLabel:` blocks in `nextflow.config` (see the `cluster` profile) are
what Nextflow translates into the actual `qsub` resource request for that
task (`cpus`, and `clusterOptions` for memory via `mem_per_core`). Pick the
wrong label and you're either starving a job of resources or wasting a
shared queue slot the rest of the class needs.

#### Labels and job tracking on the SCC

Once a process has a label and you run with `-profile cluster,conda`, each
task becomes a real SGE job, and you can inspect it the same way you would
any job you submitted by hand:

- Get the SGE job ID for a task via `nextflow log`, using the `native_id`
  field (this is the job ID Nextflow got back from `qsub`):

  ```bash
  nextflow log <run_name> -f process,native_id,workdir
  ```

- While the job is queued or running, `qstat -j <native_id>` shows you what
  was actually requested — queue, requested slots/memory — which should
  match the label you assigned.
- Once the job has finished, `qstat` won't show it anymore, but
  `qacct -j <native_id>` will — and this is the important one: it reports
  *actual* usage (`maxvmem`, `cpu`, `ru_wallclock`, exit status), the ground
  truth to compare against what the label requested. (`qacct` accounting
  data can take a few seconds to appear after a job finishes — don't worry
  if it's not there instantly.)

- [ ] **Try it yourself:** after a full `-profile cluster,conda` run, find
  the `PROKKA` task's `native_id` and run `qacct -j` on it. Compare
  `maxvmem`/`cpu` against the `process_medium`/`process_high` label you
  gave it in `nextflow.config` — was it sized appropriately, over-, or
  under-provisioned?

#### Make your own label

`process_single`/`process_low`/`process_medium`/`process_high` are the four
labels this template ships with — nothing requires you to stop there.
Define one additional, custom label sized specifically for what you
observed `PROKKA` actually use in the exercise above, instead of reusing
one of the four defaults.

- [ ] **Read the resource requests section of the SCC documentation
  first** (covered in lecture). You need the correct syntax for requesting
  a specific number of cores and a specific amount of memory on the
  cluster — get either wrong and your job either won't schedule or will
  silently reserve far more of a shared queue than it needs.
- [ ] **Add a new `withLabel:` block** for your custom label under the
  `cluster` profile in `nextflow.config`, alongside the existing four,
  sized from what you actually measured rather than a guess.
- [ ] **Apply it** to `PROKKA` in place of its current label, and re-run
  with `-profile cluster,conda`.
- [ ] **Verify it** the same way as above: pull the task's `native_id` and
  check `qacct -j` — does actual usage now sit close to what you requested,
  instead of comfortably inside a wider default bucket?

### Linting, formatting, and inspecting pipelines

A few commands help you sanity-check a pipeline without actually running it:

- `nextflow lint <path>` — parses your scripts and config with the strict
  parser and reports errors, without executing anything:

  ```bash
  nextflow lint .
  ```

- `nextflow lint -format <path>` — the same linter, but also rewrites your
  files to a consistent style (this is the current replacement for what used
  to be a separate `nextflow fmt` command). Useful to run before committing:

  ```bash
  nextflow lint -format modules/prokka/main.nf
  ```

- `nextflow inspect <path>` — resolves each process's `container` directive
  (including anything set via `withName:`/`withLabel:` and profiles) and
  prints it, without running the pipeline. Handy for confirming a profile
  picks up the container/conda environment you expect before submitting a
  real job:

  ```bash
  nextflow inspect main.nf -profile cluster,conda
  ```

## Lab03 Tasks - Jupyter Notebooks (Together)

Jupyter notebooks are a convenient environment for bioinformatics analysis. They allow you
to intersperse code along with text and figures in the same document. It is very common
for many analyses in bioinformatics to be done entirely within a jupyter notebook. 

In order for us to utilize these notebooks to their fullest potential, we usually
want to make use of different software libraries. We will create a conda environment
for our notebooks in a very similar fashion as we have done for every other environment
in this class but with a few modifications. 

Once we have created this environment, we can open a jupyter notebook in either the same
VSCode session or a dedicated JupyterLab session (OnDemand Interactive app). This will
allow us to use any software installed in these environments in our notebook.

We will then use the results generated from our pipeline and create a quick visualization
of the genome annotations that were created in the form of a [circos plot](https://moshi4.github.io/pyCirclize/circos_plot/).
