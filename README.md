<img src="https://github.com/sunbeam-labs/sunbeam/blob/stable/docs/images/sunbeam_logo.gif" width=120, height=120 align="left" />

# sbx_phase_finder

<!-- badges: start -->

<!-- badges: end -->

A [Sunbeam](https://github.com/sunbeam-labs/sunbeam) extension for identifying inversion sites in metagenomic reads using [PhaseFinder](https://github.com/XiaofangJ/PhaseFinder).

## Installation

To install, activate your conda environment (using the name of your environment) and use `sunbeam extend`:

    conda activate <i>sunbeamX.X.X</i>
    sunbeam extend https://github.com/sunbeam-labs/sbx_phase_finder.git

## Usage

To generate an `inversions.txt` summary file, create a project, specify your reference, and use the `all_phase_finder` target:

    sunbeam init --data_fp /path/to/reads/ /path/to/project/
    sunbeam config modify -i -f /path/to/project/sunbeam_config.yml -s 'sbx_phase_finder: {{ref_fp: {/path/to/host/host.fa}}}'
    sunbeam run --profile /path/to/project/ all_phase_finder

N.B. For sunbeam versions <4 the last command will be something like `sunbeam run --configfile /path/to/project/sunbeam_config.yml all_phase_finder`.

## Configuration

  - ref_fp: Is the filepath to a reference genome

## Legacy Installation

For sunbeam versions <3 or if `sunbeam extend` isn't working, you can use `git` directly to install an extension:

    git clone https://github.com/sunbeam-labs/sbx_phase_finder.git extensions/sbx_phase_finder

and then include it in the config for any given project with:

    cat extensions/sbx_phase_finder/config.yml >> /path/to/project/sunbeam_config.yml