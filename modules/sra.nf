#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/******************************************************************************
 * Define workflow processes.
 *****************************************************************************/

process SRA_PREFETCH {
  tag "${meta.id}"
  label 'fasterq_dump'
  label 'minimal_process'
  label 'error_retry'

  input:
  val(meta)

  output:
  tuple val(meta), path("${meta.id}/"), emit: sra

  script:
  """
  mkdir -p ~/.ncbi
  printf '/LIBS/GUID = "%s"\n' `uuid` > ~/.ncbi/user-settings.mkfg

  prefetch ${meta.id}
  vdb-validate --verbose ${meta.id}
  """
}

process SRA_DUMP {
  tag "${meta.id}"
  label 'fasterq_dump'
  label 'default_process'

  input:
  tuple val(meta), path(archive)

  output:
  tuple val(meta), path("*.fastq"), emit: reads

  script:
  """
  mkdir -p ~/.ncbi
  printf '/LIBS/GUID = "%s"\n' `uuid` > ~/.ncbi/user-settings.mkfg

  fasterq-dump --progress --threads ${task.cpus} --temp /tmp ${meta.id}
  """
}

/******************************************************************************
 * Define a sub-workflow for this module.
 *****************************************************************************/

workflow SRA_FASTQ {
  take:
  samples

  main:
  SRA_PREFETCH(samples) | SRA_DUMP

  emit:
  reads = SRA_DUMP.out.reads
}
