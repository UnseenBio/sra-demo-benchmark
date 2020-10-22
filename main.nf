#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { SRA_DOWNLOAD; SRA_SINGLE_FASTQ; SRA_PAIRED_FASTQ; } from './sra'

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

params.accession = [
  ['SRR11140744', true],
  ['SRR11140746', true],
  ['SRR037072', false]
]
params.scratch_space = '/scratch'
params.tracedir = 'info'

/* ############################################################################
 * Define workflow processes.
 * ############################################################################
 */



/* ############################################################################
 * Define an implicit workflow that only runs when this is the main nextflow
 * pipeline called.
 * ############################################################################
 */

workflow {
  log.info """
************************************************************

Shotgun Sequencing Quality Control
==================================
SRA Accessions: ${params.accession}
Temporary Directory: ${params.scratch_space}
Info Path: ${params.tracedir}

************************************************************

"""

  SRA_DOWNLOAD(Channel.fromList(params.accession))
  SRA_DOWNLOAD.out.sra.branch({
    paired: it[1]
      return it[0]
    single: !it[1]
      return it[0]
  }).set({ download })

  SRA_PAIRED_FASTQ(download.paired)

  SRA_SINGLE_FASTQ(download.single)
}
