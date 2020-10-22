# SRA Demo

A demo workflow showing download, extraction, and compression of sequences from SRA.

This branch is intended to be used with the Docker profile.

A directory is mounted as the container's `/tmp` directory. You can significantly improve the performance of `fasterq-dump` if the mounted directory (provided as `params.scratch_space`) is either on an SSD or even better an in-memory `tmpfs`.

The workflow generates an execution timeline giving a rough idea of the performance. You can find a sample execution timeline report in `info/execution_timeline.html`.

## Usage

1. Set up nextflow as [described
   here](https://www.nextflow.io/index.html#GetStarted).
2. If you didn't run this pipeline in a while, possibly update nextflow itself.
   ```
   nextflow self-update
   ```
3. Then run the pipeline.
   ```
   nextflow run main.nf -profile docker --scratch_space=/your/own/path
   ```

## Copyright

- Copyright © 2020, Unseen Bio ApS.
- Free software distributed under the [GNU Affero General Public License version
  3 or later (AGPL-3.0-or-later)](https://opensource.org/licenses/AGPL-3.0).
