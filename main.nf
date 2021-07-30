#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/******************************************************************************
 * Default parameter values.
 *****************************************************************************/

params.input = null

/******************************************************************************
 * Include dependencies.
 *****************************************************************************/

include { SRA_PREFETCH; SRA_DUMP; SRA_DUMP as SRA_DUMP_COMPRESS } from './modules/sra'
include { PARALLEL_FASTQ_DUMP; PARALLEL_FASTQ_DUMP as PARALLEL_FASTQ_DUMP_COMPRESS } from './modules/parallel'

/******************************************************************************
 * Define an implicit workflow that only runs when this is the main nextflow
 * pipeline called.
 *****************************************************************************/

 if (!params.input) {
   exit 1, "An input table is required."
 }

 def add_compression(row, decision) {
   copy = row.clone()
   copy[0] = copy[0].clone()
   copy[0].compress = decision
   return copy
 }

workflow {
  log.info """
************************************************************

Fetch NGS Benchmark
===================
Sample Sheet: ${params.input}

************************************************************

"""
  def runs = Channel.fromPath(params.input, checkIfExists: true)
    .splitCsv(header: true, sep: '\t', strip: true)
    .map({ row -> ['id': row.run_accession] })

  SRA_PREFETCH(runs)

  SRA_PREFETCH.out.sra.multiMap({
    uncompressed: add_compression(it, false)
    compressed: add_compression(it, true)
  }).set({ result })

  SRA_DUMP(result.uncompressed)
  PARALLEL_FASTQ_DUMP(result.uncompressed)

  SRA_DUMP_COMPRESS(result.compressed)
  PARALLEL_FASTQ_DUMP_COMPRESS(result.compressed)
}
