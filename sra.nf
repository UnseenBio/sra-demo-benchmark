#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

params.outdir = 'results'
params.scratch_space = '/scratch'

/* ############################################################################
 * Define workflow processes.
 * ############################################################################
 */

process SRA_DOWNLOAD {
  errorStrategy 'retry'
  maxRetries 3

  input:
  tuple val(accession), val(is_paired)

  output:
  tuple path(accession), val(is_paired), emit: sra

  """
  mkdir -p ~/.ncbi
  printf '/LIBS/GUID = "%s"\n' `uuid` > ~/.ncbi/user-settings.mkfg

  prefetch ${accession}
  vdb-validate --verbose ${accession}
  """
}

process SRA_SINGLE_FASTQ {
  label 'fasterq_dump'

  input:
  path sra

  output:
  tuple val(accession), path("${accession}.fastq.gz"), emit: fastq

  script:
  accession = sra.getName()
  """
  mkdir -p ~/.ncbi
  printf '/LIBS/GUID = "%s"\n' `uuid` > ~/.ncbi/user-settings.mkfg

  fasterq-dump --threads ${task.cpus} --temp "${params.scratch_space}" ${accession}
  pigz --best --processes ${task.cpus} ${accession}.fastq
  """
}

process SRA_PAIRED_FASTQ {
  label 'fasterq_dump'

  input:
  path sra

  output:
  tuple val(accession), path("${accession}_1.fastq.gz"), path("${accession}_2.fastq.gz"), emit: fastq

  script:
  accession = sra.getName()
  """
  mkdir -p ~/.ncbi
  printf '/LIBS/GUID = "%s"\n' `uuid` > ~/.ncbi/user-settings.mkfg

  fasterq-dump --progress --threads ${task.cpus} --temp "${params.scratch_space}" ${accession}
  pigz --best --processes ${task.cpus} ${accession}_{1,2}.fastq
  """
}
