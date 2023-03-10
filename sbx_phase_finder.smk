# -*- mode: Snakemake -*-

import sys

TARGET_PHASE_FINDER = [QC_FP / "inversions" / "inversions.txt"]


try:
    BENCHMARK_FP
except NameError:
    BENCHMARK_FP = output_subdir(Cfg, "benchmarks")
try:
    LOG_FP
except NameError:
    LOG_FP = output_subdir(Cfg, "logs")


def get_phase_finder_path() -> str:
    phase_finder_path = os.path.join(sunbeam_dir, "extensions/sbx_phase_finder/")
    if os.path.exists(phase_finder_path):
        return phase_finder_path
    raise Error(
        "Filepath for PhaseFinder.py not found, are you sure it's installed under extensions/sbx_phase_finder?"
    )


localrules:
    all_phase_finder,
    aggregate_phase_finder,


rule all_phase_finder:
    input:
        TARGET_PHASE_FINDER,


rule phase_finder_locate:
    output:
        tabs=QC_FP / "inversions" / "{sample}" / "test.einverted.tab",
    log:
        LOG_FP / "phase_finder_locate_{sample}.log",
    benchmark:
        BENCHMARK_FP / "phase_finder_locate_{sample}.tsv"
    conda:
        "sbx_phase_finder_env.yml"
    params:
        script=get_phase_finder_path() + "PhaseFinder.py",
        ref=Cfg["sbx_phase_finder"]["ref_fp"],
    shell:
        """
        python {params.script} locate -f {params.ref} -t {output.tabs} -g 15 85 -p 2>&1 | tee {log}
        """


rule phase_finder_create:
    input:
        tabs=QC_FP / "inversions" / "{sample}" / "test.einverted.tab",
    output:
        ids=QC_FP / "inversions" / "{sample}" / "test.ID.fasta",
    log:
        LOG_FP / "phase_finder_create_{sample}.log",
    benchmark:
        BENCHMARK_FP / "phase_finder_create_{sample}.tsv"
    conda:
        "sbx_phase_finder_env.yml"
    params:
        script=get_phase_finder_path() + "PhaseFinder.py",
        ref=Cfg["sbx_phase_finder"]["ref_fp"],
    shell:
        """
        python {params.script} create -f {params.ref} -t {input.tabs} -s 1000 -i {output.ids} 2>&1 | tee {log}
        """


rule phase_finder_ratio:
    input:
        ids=QC_FP / "inversions" / "{sample}" / "test.ID.fasta",
        rp1=QC_FP / "cleaned" / "{sample}_1.fastq.gz",
        rp2=QC_FP / "cleaned" / "{sample}_2.fastq.gz",
    output:
        ratio=QC_FP / "inversions" / "{sample}" / "out.ratio.txt",
    log:
        LOG_FP / "phase_finder_ratio_{sample}.log",
    benchmark:
        BENCHMARK_FP / "phase_finder_ratio_{sample}.tsv"
    conda:
        "sbx_phase_finder_env.yml"
    params:
        script=get_phase_finder_path() + "PhaseFinder.py",
        ref=Cfg["sbx_phase_finder"]["ref_fp"],
    shell:
        """
        RP1={input.rp1}
        RP2={input.rp2}
        RATIO={output.ratio}
        gzip -d {input.rp1} {input.rp2}

        python {params.script} ratio -i {input.ids} -1 ${{RP1%.gz}} -2 ${{RP2%.gz}} -p 16 -o ${{RATIO%.ratio.txt}} 2>&1 | tee {log} || gzip ${{RP1%.gz}} ${{RP2%.gz}}
        """


rule aggregate_phase_finder:
    input:
        expand(
            QC_FP / "inversions" / "{sample}" / "out.ratio.txt", sample=Samples.keys()
        ),
    output:
        QC_FP / "inversions" / "inversions.txt",
    shell:
        """
        tail -n +1 {input} >> {output}
        """
