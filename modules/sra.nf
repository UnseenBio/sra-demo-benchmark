#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/******************************************************************************
 * Define workflow processes.
 *****************************************************************************/

process SRA_PREFETCH {
  tag "${meta.id}"

  label 'fasterq_dump'
  label 'minimal_process'

  maxForks 3

  input:
  val(meta)

  output:
  tuple val(meta), path("${meta.id}/"), emit: sra

  script:
  """
  prefetch --progress ${meta.id}
  """
}

process SRA_DUMP {
  tag "${meta.id}"

  label 'fasterq_dump'
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
    fasterq-dump --threads ${task.cpus} --temp /tmp ${meta.id}
    pigz --processes ${task.cpus} *.fastq
    """
  } else {
    output = '*.fastq'
    """
    fasterq-dump --threads ${task.cpus} --temp /tmp ${meta.id}
    """
  }
}
