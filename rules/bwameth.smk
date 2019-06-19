from pathlib import Path
DATA_DIR = Path(config['data_dir'])
RESULT_DIR = Path(config['result_dir'])

rule bwameth_index:
    input:
        config['reference']['fasta']
    output:
        config['reference']['bwameth_index']
    # NOTE: This rule does not require parameters.
    threads: config['threads']['bwameth_index']  # NOTE: This rule will not use more than 1 core.
    wrapper:
        'http://dohlee-bio.info:9193/bwa-meth/index'

rule bwameth_se:
    input:
        # Required input. Reference genome fasta file.
        reads = [DATA_DIR / '{sample}.fastq.gz'],
        reference = config['reference']['fasta'],
        bwameth_reference = config['reference']['bwameth_index'],
    output:
        # BAM output or SAM output is both allowed.
        # Note that BAM output will be automatically detected by its file extension,
        # and SAM output (which is bwa mem default) will be piped through `samtools view`
        # to convert SAM to BAM.
        RESULT_DIR / '01_bwameth' / 'se' / '{sample}.bam',
    params:
        extra = config['bwameth_se']['extra'],
        # Read-group to add to bam in same format as to bwa:
        # '@RG\tID:foo\tSM:bar'
        read_group = lambda wildcards: '"@RG\\tID:%s\\tSM:%s\\tPL:ILLUMINA"' % (wildcards.sample, wildcards.sample),
        # flag alignments to this strand as not passing QC (0x200). Targetted BS-Seq libraries
        # are often to a single strand, so we can flag them as QC failures.
        # Note f == OT, r == OB. Likely, this will be 'f' as we will expect reads to align
        # to the original-bottom (OB) strand and will flag as failed those aligning to the
        # forward, or original top (OT).
        # Default: False
        set_as_failed = config['bwameth_se']['set_as_failed'],
        # Fastq files have 4 lines of read1 followed by 4 lines of read 2.
        # e.g. seqtk mergepe output.
        # Default: False
        interleaved = config['bwameth_se']['interleaved'],
    threads: config['threads']['bwameth_se']
    log: 'logs/bwameth_se/{sample}.log'
    benchmark: 'benchmarks/bwameth_se/{sample}.log'
    wrapper:
        'http://dohlee-bio.info:9193/bwa-meth'

rule bwameth_pe:
    input:
        # Required input. Reference genome fasta file.
        reads = [DATA_DIR / '{sample}.read1.fastq.gz', DATA_DIR / '{sample}.read2.fastq.gz'],
        reference = config['reference']['fasta'],
        bwameth_reference = config['reference']['bwameth_index'],
    output:
        # BAM output or SAM output is both allowed.
        # Note that BAM output will be automatically detected by its file extension,
        # and SAM output (which is bwa mem default) will be piped through `samtools view`
        # to convert SAM to BAM.
        RESULT_DIR / '01_bwameth' / 'pe' / '{sample}.bam',
    params:
        extra = config['bwameth_pe']['extra'],
        # Read-group to add to bam in same format as to bwa:
        # '@RG\tID:foo\tSM:bar'
        read_group = lambda wildcards: '"@RG\\tID:%s\\tSM:%s\\tPL:ILLUMINA"' % (wildcards.sample, wildcards.sample),
        # flag alignments to this strand as not passing QC (0x200). Targetted BS-Seq libraries
        # are often to a single strand, so we can flag them as QC failures.
        # Note f == OT, r == OB. Likely, this will be 'f' as we will expect reads to align
        # to the original-bottom (OB) strand and will flag as failed those aligning to the
        # forward, or original top (OT).
        # Default: False
        set_as_failed = config['bwameth_pe']['set_as_failed'],
        # Fastq files have 4 lines of read1 followed by 4 lines of read 2.
        # e.g. seqtk mergepe output.
        # Default: False
        interleaved = config['bwameth_pe']['interleaved'],
    threads: config['threads']['bwameth_pe']
    log: 'logs/bwameth_pe/{sample}.log'
    benchmark: 'benchmarks/bwameth_pe/{sample}.log'
    wrapper:
        'http://dohlee-bio.info:9193/bwa-meth'

