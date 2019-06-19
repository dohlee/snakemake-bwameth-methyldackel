from pathlib import Path
import pandas as pd

configfile: 'config.yaml'
include: 'rules/bwameth.smk'
include: 'rules/sambamba.smk'
include: 'rules/methyldackel.smk'

DATA_DIR = Path(config['data_dir'])
RESULT_DIR = Path(config['result_dir'])
manifest = pd.read_csv(config['manifest'])

SAMPLE_SE = manifest[manifest.library_layout == 'single'].name.values
SAMPLE_PE = manifest[manifest.library_layout == 'paired'].name.values
BAM_SE = expand(str(RESULT_DIR / '01_bwameth' / 'se' / '{sample}.bam'), sample=SAMPLE_SE)
BAM_PE = expand(str(RESULT_DIR / '01_bwameth' / 'pe' / '{sample}.bam'), sample=SAMPLE_PE)
SORTED_BAM_SE = expand(str(RESULT_DIR / '01_bwameth' / 'se' / '{sample}.sorted.bam'), sample=SAMPLE_SE)
SORTED_BAM_PE = expand(str(RESULT_DIR / '01_bwameth' / 'pe' / '{sample}.sorted.bam'), sample=SAMPLE_PE)
METHYLDACKEL_SE = expand(str(RESULT_DIR / '02_methyldackel' / 'se' / '{sample}_CpG.bedGraph'), sample=SAMPLE_SE)
METHYLDACKEL_PE = expand(str(RESULT_DIR / '02_methyldackel' / 'pe' / '{sample}_CpG.bedGraph'), sample=SAMPLE_PE)

ALL = []
ALL.append(BAM_SE)
ALL.append(BAM_PE)
ALL.append(SORTED_BAM_SE)
ALL.append(SORTED_BAM_PE)
ALL.append(METHYLDACKEL_SE)
ALL.append(METHYLDACKEL_PE)

rule all:
    input: ALL


