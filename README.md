# Lab 03 - Creating a nextflow workflow for multiple samples

## Objective

Today we are going to get more experience putting together a 
bioinformatics pipeline in nextflow. This pipeline will download
multiple bacterial genomic sequences, annotate them using Prokka
and choose a single gene's coordinates from the GFF created, make
a FASTA index of the genome, and extract out the genomic sequence
of the chosen gene. 

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
- `stub` block, `-stub` flag — see "Stub runs (-stub)"
- `ext.args`, `task.ext.args ?: ''`, `withName:` process selector — see "Process configuration: ext.args and withName"

**Debugging**
- `nextflow log`, `-f` fields, `-filter` expressions — see "Debugging with nextflow log and the work directory"
- `.command.sh`, `.command.err`, `.exitcode` in the work directory — see "Debugging with nextflow log and the work directory"

**Once your pipeline works** — quality-of-life features, not required for a working pipeline
- `-with-report` — see "Process configuration: ext.args and withName"
- `resume` in `nextflow.config` — see "Resume"
- Process `label`s and resource requests in `nextflow.config` — see "Labels"
- `nextflow lint` — see "Linting, formatting, and inspecting pipelines"
- `results` directory, `publish:` block — see "Results - moving important files outside of the work directory"

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

- [ ] As always, remember to activate your `nextflow_latest` environment

- [ ] Notice the new structure of our `main.nf`. We have made new scripts
for our processes in the modules/ directory and now will have to use
`include` to import those processes into our `main.nf` and use them
in our workflow. 

## Given vs. what you write

**Given, working — read but you don't need to edit these:**
- `modules/samtools_faidx_subset` — fully complete
- `bin/`, `envs/`, `nextflow.config`, `samplesheet.csv`, `specifications.md`

`specifications.md` describes what the pipeline as a whole needs to do — read it
before you start, and refer back to it for the exact record shapes each
step consumes and produces.

**You write:**
- [ ] `modules/ncbi_datasets_cli` — the `AssemblyRequest` and `Genome` record types
- [ ] `modules/prokka` — the output `record(...)` construction
- [ ] `modules/extract_region` — the `script:` command
- [ ] `modules/samtools_faidx` — the `input:`/`output:` block
- [ ] `main.nf` — the entire workflow: the starting channel and every process wired together


## Lab 03 Tasks - Nextflow

If you want, you can right click on the README.md and select "Open Preview", which
will open a slightly nicer, mostly formatted version of this document.

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

Please look at the `test/` directory and run each of the `.nf` files in 
order:

1. frompath.nf
2. splitcsv.nf
3. map.nf

Each script will print out what each step on lines 20-22 produces. Observe
how they connect and what the final channel resembles. 

Once done, please do the following main tasks:

- [ ] **Ensure you understand the initial channel generation**, Look at the 
   provided lines in the main.nf from lines 20-22. Run the provided
   `frompath.nf`, `splitcsv.nf`, and `map.nf` test scripts
   to see what these lines will produce.
- [ ] **In the main.nf, call each process**, wiring each one's output to the
  next process's input, per `specifications.md` > Pipeline steps. Remember to 
  save the output of a process to a named variable and use that to pass the outputs
  to the next process.


## Stub runs (-stub)

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

## Running your pipeline for real

[Advanced SCC Usage](https://bu-bioinfo.github.io/bf528/lectures/week-03/)

Once you've confirmed that your pipeline works with a stub run, you should see
all of your processes finish. Check to make sure that the appropriate number
of processes run based on how many samples are in your `samplesheet.csv`. 

Once you have, run the following command to run your pipeline for real:

```bash
nextflow run main.nf -profile conda,cluster
```

Feel free to run `qstat -u <your-username>` during this time. You can see
all your different jobs run on compute nodes as the workflow progresses.

You can also use `qstat -j <job-id-from-qstat>` to see more details about your
job.

When the pipeline has finished, use `nextflow log` and find the `RUN NAME` of the
most recent pipeline run. Once you've found the most recent run, use the following
command:

```bash
nextflow log <run_name> -filter 'process == "PROKKA"'
```

This will show you the directory where the PROKKA processes ran. Navigate to one
and make note of the `.command.sh` and observe the command that was actually 
executed. 

- [ ] Find the directory where one PROKKA process ran and observe the command.
  Keep this comparison in mind for the results of the next section.

## Process configuration: ext.args and withName

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

You should see the above in the `nextflow.config` on lines 16-20. Please uncomment (erase
the */ and /* on lines 15 and 21), save the file and try re-running your pipeline
with the following command:

```bash
nextflow run main.nf -profile conda,cluster -with-report
```

- [ ] Uncomment the lines in your `nextflow.config`
- [ ] Observe what happens: which jobs re-run and which remain `cached`?

### Resume

If you look at the last line of the `nextflow.config`, you can see an option specified
`resume = true`. When nextflow runs, it caches information about jobs that have successfully
finished. With this option, if your pipeline failed at a later step, nextflow will not re-run
steps that have already finished. 

There are times when you want your pipeline to start from the beginning, in which case, you will
want to change this value to `resume = false` or you can delete the directories in `work/` to
force nextflow to re-run everything. You can avoid deleting the `conda/` directory in `work/` so
nextflow doesn't have to remake the environments. 

**Back to your pipeline**
You should see `PROKKA` re-run, along with everything downstream of it including
`EXTRACT_REGION` and `SAMTOOLS_FAIDX_SUBSET` while `SAMTOOLS_FAIDX` stays
`cached`. Nextflow computes a hash for each individual task from everything
that could affect its output: the task's inputs, its script, and the process
directives applied to it (including `ext.args`). Changing `ext.args` on
`PROKKA` changes only `PROKKA`'s own hash but it also changes `PROKKA`'s output
files, and those files are the *input* to `EXTRACT_REGION`, so `EXTRACT_REGION`'s
hash changes too, and its output cascades the same way into `SAMTOOLS_FAIDX_SUBSET`.
`SAMTOOLS_FAIDX` never touches `PROKKA`'s output (it depends only on the downloaded
genome from `NCBI_DATASETS_CLI`), so its inputs are unchanged and it's the one 
process that stays cached. This reuse only happens because `resume = true` is set
 in `nextflow.config` — more on that later.

Wait until this new re-run finishes and take a look at the HTML report that was
generated in your directory.

- [ ] Take a look at the HTML report that was generated when the re-run of your
  pipeline finished

- [ ] Find where the new PROKKA processes ran for this re-run. Find one of their
  work directories and note the `.command.sh`. Compare what is added to the command
  compared to earlier.

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

Navigate to the appropriate sub-directory underneath `work/`. You can use
the one given by the command above or just choose any random subdirectory.

Every task's work directory contains at minimum the following (N.B. each task
directory will also include that processes' inputs and outputs):

- `.command.sh` — the exact script Nextflow generated and ran (or would have
  run, for a stub run). This is where you go to confirm `ext.args` was
  actually substituted into the command. You can also see the appropriate
  variable substitutions that were made.
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
- `.exitcode` — the exit status of the task's command. 1 means an error occured,
  and 0 means a successful exit.

If you've submitted jobs to the SCC directly with `qsub` before, `.command.out`
and `.command.err` are Nextflow's equivalent of the `.o<jobid>`/`.e<jobid>`
files a bare SGE job writes. 

- [ ] Navigate to the appropriate sub-directory underneath `work/` and inspect
  the contents of the `.command.sh` file to confirm that `ext.args` was
  actually substituted into the command.
- [ ] Check the `.exitcode` file to confirm that the task exited successfully
  (exit code 0).
- [ ] Observe how the `qsub` script arguments are found in the `.command.run`
  file

## Labels

At the same level as the `conda` declarations in the `PROKKA` process, add
a line that specifies a label like so:

```nextflow
label 'process_medium`
```

Now go the `nextflow.config` and add a label (with the same formatting) between
`withLabel: process_single` and `withLabel: process_high`:

```nextflow
withLabel: process_medium {
    cpus = 4

}
```

Now when you run with `-profile cluster,conda`, the `PROKKA` process will use the `process_medium` label,
which will request 4 CPUs. **However**, this label only *requests* the amount of resources
from the SCC. You will also need to ensure that your process can make use of the resources by 
adding the appropriate flags to the `prokka` command in the `PROKKA` process. Not every tool can
make use of multiple CPUs, so you'll need to check the documentation for the tool to see if it supports
parallel processing. Prokka supports parallel processing via the `--cpus` flag. Inside the actual command,
you can use the variable `$task.cpus` to access the value defined in the config.

Navigate to the `PROKKA` process module and replace the hard coded `1` argument after `--cpus` with `$task.cpus`. 
Once done, re-run your workflow again with the following command:

```nextflow
nextflow run main.nf -profile conda,cluster -with-report
```

- [ ] While the job is queued or running, run `qstat -j <native_id>` and
  check what was actually requested
- [ ] Once the job has finished, run `qacct -j <native_id>` (`qstat` won't
  show it anymore) — this is the important one: it reports *actual* usage
  (`maxvmem`, `cpu`, `ru_wallclock`, exit status). `qacct` accounting data
  can take a few seconds to appear after a job finishes, it may not be
  there instantly.
- [ ] Check the `.command.sh` for one of the new PROKKA processes, and ensure
  you see the value from `process_medium` in the script command.

## Linting, formatting, and inspecting pipelines

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

Now in your directory, please run the following command:

```nextflow
nextflow lint .
```

On your terminal, you will probably see 3 warnings and 8 files passing. The 3 warnings are
about an unused variable (the final output) and two deprecated uses of the `shell` block. Go to
the files where it warned about the `shell` block usage and replace them with `script`.

You can also use a built-in formatted to reformat any nextflow file according to standard
conventions.

**Optional**
Choose any working nextflow module and run the following command:

```nextflow
nextflow lint -format modules/<name-of-module>/main.nf
```

## Results - moving important files outside of the work directory

By now, you've likely noticed that it's somewhat cumbersome to navigate through
the `work` directory. Nextflow has a built-in convention for `publishing` certain
outputs to a more convenient location, `results`, by default. 

If you look under the `publish:` block in the `main.nf`, you'll notice that we have
saved the output of PROKKA to a new variable called `prokka_results`. Below the `workflow`
block, you can see we have one more block: `output` and this is where `prokka_results` is
listed. 

Both of these lines together will instruct Nextflow to save the outputs (just the outputs
declared in the process, not the accessory files) of the declared variables to the `results/`
directory. This will enable you to more easily find or inspect important outputs from your
processes. Please note that for every variable declared under `publish:`, you must have 
declare it also in the `output` block or nextflow will throw an error. 