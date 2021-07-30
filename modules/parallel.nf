#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/******************************************************************************
 * Define workflow processes.
 *****************************************************************************/

process PARALLEL_FASTQ_DUMP {
  tag "${meta.id}"

  label 'parallel_fastq_dump'
  label 'default_process'

  maxForks 1

  input:
  tuple val(meta), path(archive)

  output:
  tuple val(meta), path(output), emit: reads

  script:
  if (meta.compress) {
    output = '*.fastq.gz'
    """
    parallel-fastq-dump --tmpdir /tmp \
      --sra-id ${meta.id} \
      --threads ${task.cpus} \
      --gzip \
      --split-e
    """
  } else {
    output = '*.fastq'
    """
    parallel-fastq-dump --tmpdir /tmp \
      --sra-id ${meta.id} \
      --threads ${task.cpus} \
      --split-e
    """
  }
}
