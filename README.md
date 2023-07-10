# **Snakemake workflow: variant calling using the BCFtools**

[![conda](https://img.shields.io/badge/conda->=23.1.0-brightgreen.svg)](https://github.com/conda/conda)
[![snakemake](https://img.shields.io/badge/snakemake-7.24.2-brightgreen.svg)](https://snakemake.readthedocs.io)

---

## **Table of contents**
- [**Snakemake workflow: variant calling using the BCFtools**](#snakemake-workflow-variant-calling-using-the-bcftools)
  - [**Table of contents**](#table-of-contents)
  - [**Motivation**](#motivation)
  - [**Pipeline breakdown**](#pipeline-breakdown)
  - [**Project dependencies:**](#project-dependencies)
  - [**Where to start**](#where-to-start)
  - [**Directory structure**](#directory-structure)
  - [**Running the analysis**](#running-the-analysis)
  - [**Feedback and Issues**](#feedback-and-issues)


## **Motivation**

- This repository contains a pipeline built with [Snakemake](https://snakemake.readthedocs.io/en/stable/) for variant calling using [BCFtools](https://github.com/samtools/bcftools).
- The test paired-FastQ files are from an amplicon-sequencing project of _Plasmodium falciparum_ isolates, and it can be modified to suit one's needs.


## **Pipeline breakdown**
- This pipeline handles paired-end reads and below are the analysis sections in the Snakefile:

  - **Step 1 - Compile a list of all output files** -  a Snakemake [rule all](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html#step-7-adding-a-target-rule) is placed at the top of the workflow and lists all the output files as dependencies. This ensures that all the output files are generated when the pipeline is executed.
  - **Step 2 - Gather Genome Data** - this step downloads the _P. falciparum_ genome data (_FASTA files of the genome, coding and protein sequences as well as the GFF annotation file_) from [PlasmoDB](https://plasmodb.org/) and creates a SnpEff database for variant annotation.
  - **Step 3 - Perform Fastq data pre-processing tool** - this step performs quality control on the FastQ files using [fastp](https://github.com/OpenGene/fastp).
  - **Step 4 - Generate genome index** - to perform read-mapping to the genome, [BWA](https://github.com/lh3/bwa) requires an index for your reference genome to allow it to more efficiently search the genome.
  - **Step 5 - Perform read mapping** - this step performs read-mapping using [BWA](https://github.com/lh3/bwa), followed by marking duplicates using [Samblaster](https://github.com/GregoryFaust/samblaster), then [Samtools](https://github.com/samtools/samtools) fixmate to fill in the mate-coordinates and insert-size fields in the SAM records, and finally sorting the BAM file using samtools.
  - **Step 6 - Get mapping-quality statistics from BAM files** - this step generates mapping-quality statistics from the BAM files using two algorithms Samtools, [idxstats](http://www.htslib.org/doc/samtools-idxstats.html) and [flagstats](http://www.htslib.org/doc/samtools-flagstat.html).
  - **Step 7 - Perform variant calling** - this step performs variant-calling and variant-filtering using [BCFtools](https://github.com/samtools/bcftools).
  - **Step 8 - Perform variant annotation and functional effect prediction** - this step uses [SnpEff](https://pcingola.github.io/SnpEff/se_introduction/) to annotate the identified genetic variants and predict the effects of these variants on genes and proteins, such as amino acid changes.
  - **Step 9 - Extract variants from VCF files** - this step extracts the genetic variants from the VCF files using [SnpSift](https://pcingola.github.io/SnpEff/ss_introduction/) and calculates within-sample allele frequency using [AWK](https://www.gnu.org/software/gawk/manual/gawk.html)
  

---

## **Project dependencies:**

- [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) - an open-source package management system and environment management system that runs on various platforms, including Windows, MacOS, Linux

- [Snakemake](https://github.com/snakemake/snakemake) - a workflow management system that aims to reduce the complexity of creating workflows by providing a fast and comfortable execution environment, together with a clean and modern specification language in python style.

---

## **Where to start**

- Install conda for your operating System (_the pipeline is currently tested on Linux and MacOS_):
  - [Linux](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html)
  - [MacOS](https://docs.conda.io/projects/conda/en/latest/user-guide/install/macos.html)
- Clone this project using the following command in your terminal:
  - `git clone https://github.com/kevin-wamae/variant-calling-with-Snakemake-and-BCFtools.git`
- Type the following command in your terminal to navigate into the cloned directory using the command below. This will be the root directory of the project:
  - `cd variant-calling-with-Snakemake-and-BCFtools`
  
- **_Note: All subsequent commands should be run from the root directory of this project. However, users can modify the scripts to their liking_**
 
 ---

## **Directory structure**
- Below is the default directory structure:
    - **config/**   - contains the Snakemake-configuration files
    - **input/** - contains input files
      - **bed/** - contains the bed files for specifying the intervals of interest
      - **fastq/** - contains the FastQ files
    - **output/** - will contain the numbered-output directories with the results of the analysis
    - **workflow/** - contains the Snakemake workflow files
      - **envs/** - contains the Conda environment-configuration files
      - **scripts/** - contains the scripts used in the pipeline
```
.
├── README.md
├── config
│   └── config.yaml
├── input
│   ├── bed
│   │   ├── p.falciparum_core_genome.bed
│   │   └── p.falciparum_genes.bed
│   └── fastq
│       ├── reads_R1.fastq.gz
│       └── reads_R2.fastq.gz
├── output
│   ├── 1_annotation_db
│   ├── 2_genome
│   ├── 3_trimmed_fastq
│   ├── 4_aligned_bam
│   ├── 5_map_qual_stats
│   ├── 6_vcf_files
│   ├── 7_variant_annotation
│   └── 8_extracted_variants
└── workflow
    ├── Snakefile
    ├── envs
    │   ├── bcftools.yaml
    │   ├── bwa.yaml
    │   ├── environment.yaml
    │   ├── fastp.yaml
    │   ├── samtools.yaml
    │   └── snpeff.yaml
    └── scripts
        ├── create_snpeff_db.sh
        └── split_annot_column.sh
```

---

## **Running the analysis**
After navigating into the root directory of the project, run the analysis by executing the following commands in your terminal to:

1. Create a conda analysis environment by running the command below in your terminal. This will create a conda environment named `variant-calling-bcftools` and install [Snakemake](https://snakemake.readthedocs.io/en/stable/) and [SnpEff](https://pcingola.github.io/SnpEff/se_introduction/) in the environment:
    - `conda env create --file workflow/envs/environment.yaml`
    - _**_Note:_** This only needs to be done once.

2. Activate the conda environment by running the command below in your terminal:
    - `conda activate variant-calling-bcftools`
    - **_Note:_** This needs to be done every time you exit and restart your terminal and want re-run this pipeline

3. Execute the shell script below to create the SnpEff database for variant annotation. This will download the _P. falciparum_ genome data from [PlasmoDB](https://plasmodb.org/) and create a database in the **output/** directory:
    - `bash workflow/scripts/create_snpeff_db.sh`
    - **_Note:_** This is an important step because the genome-FASTA and GFF files are required for read-mapping and variant calling. It can also be modified to suit one's needs such as download genome files for your organism of interest:

4. Finally, execute the whole Snakemake pipeline by running the following command in your terminal:
    - `snakemake --use-conda --cores 2 --jobs 1`
    - This will run the whole pipeline using a maximum of two cores and one job in parallel. The `--cores` flag specifies the number of cores to use for each job and the `--jobs` flag specifies the number of jobs to run in parallel.
    - If you want to run the pipeline using more resources, you can increase the number of cores and jobs. For example, to run the pipeline using 4 cores and 2 jobs in parallel, run the following command:
        - `snakemake --use-conda --cores 4 --jobs 2`
    - Additionally, you can change the `threads` entry in `line 5` of the configuration file (`config/config.yaml`) to specify the number of cores to use for each step in the pipeline.

5. Once the analysis is complete, look through **output/** directory to view the results of the analysis

6. Finally, you can deactivate the variant calling conda environment if you are done with the analysis by running the following command:
     - `conda deactivate variant-calling-bcftools`

---

## **Feedback and Issues**

Report any issues or bugs by openning an issue [here](https://github.com/kevin-wamae/variant-calling-with-Snakemake-and-BCFtools/issues) or contact me via email at **wamaekevin[at]gmail.com**
  
 
