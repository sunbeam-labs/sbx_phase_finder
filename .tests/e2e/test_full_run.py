import os
import pytest
import shutil
import subprocess as sp
import sys
import tempfile


@pytest.fixture
def setup():
    temp_dir = tempfile.mkdtemp()

    reads_fp = os.path.abspath(".tests/data/reads/")
    ref_fp = os.path.abspath(".tests/data/hosts/test.fa")

    project_dir = os.path.join(temp_dir, "project/")

    sp.check_output(["sunbeam", "init", "--data_fp", reads_fp, project_dir])

    config_fp = os.path.join(project_dir, "sunbeam_config.yml")

    config_str = f"sbx_phase_finder: {{ref_fp: {ref_fp}}}"

    sp.check_output(
        [
            "sunbeam",
            "config",
            "modify",
            "-i",
            "-s",
            f"{config_str}",
            f"{config_fp}",
        ]
    )

    yield temp_dir, project_dir

    shutil.rmtree(temp_dir)


@pytest.fixture
def run_sunbeam(setup):
    temp_dir, project_dir = setup

    output_fp = os.path.join(project_dir, "sunbeam_output")

    try:
        # Run the test job
        sp.check_output(
            [
                "sunbeam",
                "run",
                "--conda-frontend",
                "conda",
                "--profile",
                project_dir,
                "all_phase_finder",
                "--directory",
                temp_dir,
            ]
        )
    except sp.CalledProcessError as e:
        shutil.copytree(os.path.join(output_fp, "logs/"), "logs/")
        shutil.copytree(os.path.join(project_dir, "stats/"), "stats/")
        sys.exit(e)

    shutil.copytree(os.path.join(output_fp, "logs/"), "logs/")
    shutil.copytree(os.path.join(project_dir, "stats/"), "stats/")

    inversions_fp = os.path.join(output_fp, "qc/inversions/inversions.txt")

    benchmarks_fp = os.path.join(project_dir, "stats/")

    yield inversions_fp, benchmarks_fp


def test_full_run(run_sunbeam):
    (
        inversions_fp,
        benchmarks_fp,
    ) = run_sunbeam

    # Check output
    assert os.path.exists(inversions_fp)
    with open(inversions_fp) as f:
        print(f.readlines())
    with open(inversions_fp) as f:
        assert "am_0171_0068_d5_0006:81079-81105-81368-81394\t30\t26\t0.46\t19\t14\t0.42\n" in f.readlines()
