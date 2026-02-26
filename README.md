#  Avian mtDNA Mitofinder Pipeline

A SLURM-parallelized mitochondrial genome analysis pipeline for birds integrating:

- Read mapping (BWA MEM)
- Variant calling in haploid mode (BCFtools)
- Consensus sequence generation
- CDS extraction from GenBank annotations
- De novo mitochondrial assembly and annotation using MitoFinder

Designed for reproducible execution on HPC systems.

---

## Avian Mitochondrial Genome Ideogram

<p align="center">
  <img src="docs/avian_mtDNA_ideogram.png" width="500">
</p>

Typical avian mitochondrial genome (~16.8 kb):

- 13 protein-coding genes  
- 22 tRNAs  
- 2 rRNAs  
- Control Region (D-loop)  
- ND6 encoded on the light strand  

---

##  Pipeline Workflow

<p align="center">
  <img src="docs/pipeline_workflow.png" width="750">
</p>

---

## Inputs

### 1) `sample_list.txt` (must be in repo root)
Each line: `SAMPLE_ID  READ1.fastq.gz  READ2.fastq.gz`

### 2) Reference files (must be in `reference/`)
- `reference/NC_041257.fa` (FASTA reference for mapping + consensus)
- `reference/NC_041257.gb` (GenBank file used to parse CDS coordinates + guide MitoFinder)

---

## ⚙️ Installation (Conda)

Create environment:

```bash
conda env create -f env/environment.yml
conda activate mt_pipeline

**Running the Pipeline**
sbatch scripts/mt_pipeline.slurm.sh

---
title: "MitoFinder Standalone Installation (GitHub)"
output: html_document
---

## MitoFinder Standalone Installation

This document installs the official standalone version of **MitoFinder**
directly from GitHub. This method is recommended when the Conda package
fails or causes compatibility issues on HPC systems.

---

## Installation Procedure

Run the following commands in a terminal:

```bash
# Activate (or create) environment
conda activate mt_pipeline 

# Clone official repository
git clone https://github.com/RemiAllio/MitoFinder.git

# Enter repository
cd MitoFinder

# Run bundled installer
chmod +x install.sh
./install.sh

# Export repository directory to PATH
export PATH=$(pwd):$PATH

# Make PATH permanent
echo "export PATH=$(pwd):\$PATH" >> ~/.bashrc
source ~/.bashrc

# Verify installation
which mitofinder
mitofinder --version

## References

1. **BWA**  
   Li H, Durbin R. (2009).  
   Fast and accurate short read alignment with Burrows–Wheeler transform.  
   *Bioinformatics* 25(14):1754–1760.  
   https://doi.org/10.1093/bioinformatics/btp324  

2. **SAMtools / BCFtools**  
   Danecek P, Bonfield JK, Liddle J, et al. (2021).  
   Twelve years of SAMtools and BCFtools.  
   *GigaScience* 10(2):giab008.  
   https://doi.org/10.1093/gigascience/giab008  

3. **BEDTools**  
   Quinlan AR, Hall IM. (2010).  
   BEDTools: a flexible suite of utilities for comparing genomic features.  
   *Bioinformatics* 26(6):841–842.  
   https://doi.org/10.1093/bioinformatics/btq033  

4. **MitoFinder**  
   Allio R, Schomaker-Bastos A, Romiguier J, Prosdocimi F, Nabholz B, Delsuc F. (2020).  
   MitoFinder: Efficient automated large-scale extraction of mitogenomic data.  
   *Molecular Ecology Resources* 20(4):892–905.  
   https://doi.org/10.1111/1755-0998.13160  

5. **SPAdes**  
   Bankevich A, Nurk S, Antipov D, et al. (2012).  
   SPAdes: A New Genome Assembly Algorithm and Its Applications to Single-Cell Sequencing.  
   *Journal of Computational Biology* 19(5):455–477.  
   https://doi.org/10.1089/cmb.2012.0021
