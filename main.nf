#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/******************************************************************************
 * Default parameter values.
 *****************************************************************************/

params.input = null

/******************************************************************************
 * Include dependencies.
 *****************************************************************************/

include { SRA_FASTQ } from './modules/sra'
include { PARALLEL_FASTQ } from './modules/parallel'

/******************************************************************************
 * Define an implicit workflow that only runs when this is the main nextflow
 * pipeline called.
 *****************************************************************************/

if (params.input) {
  runs = Channel
    .fromPath(params.input, checkIfExists: true)
    .splitCsv(header: true, sep: '\t', strip: true)
    .map({ row -> ['id': row.run_accession] })
} else {
  exit 1, 'Input file with public database ids not specified!'
}

workflow {
  log.info """
************************************************************

Fetch NGS Benchmark
===================
Sample Sheet: ${params.input}

************************************************************

"""

  SRA_FASTQ(runs)
  PARALLEL_FASTQ(runs)
}
