#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/******************************************************************************
 * Define workflow processes.
 *****************************************************************************/

process PARALLEL_FASTQ_DUMP {
  label 'parallel_fastq_dump'
  label 'default_process'

  input:
  val(meta)

  output:
  tuple val(meta), path('*.fastq'), emit: reads

  script:
  """
  parallel-fastq-dump --sra-id ${meta.id} --threads ${task.cpus} --split-e
  """
}

/******************************************************************************
 * Define a sub-workflow for this module.
 *****************************************************************************/

workflow PARALLEL_FASTQ {
  take:
  meta

  main:
  PARALLEL_FASTQ_DUMP(meta)

  emit:
  reads = PARALLEL_FASTQ_DUMP.out.reads
}
