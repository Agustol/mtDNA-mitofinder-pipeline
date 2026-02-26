# 🧬 Avian mtDNA Mitofinder Pipeline

A SLURM-parallelized mitochondrial genome analysis pipeline for birds integrating:

- Read mapping (BWA MEM)
- Variant calling in haploid mode (BCFtools)
- Consensus sequence generation
- CDS extraction from GenBank annotations
- De novo mitochondrial assembly and annotation using MitoFinder

Designed for reproducible execution on HPC systems.

---

## 🧬 Avian Mitochondrial Genome Ideogram

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

## 🔬 Pipeline Workflow

<p align="center">
  <img src="docs/pipeline_workflow.png" width="750">
</p>

### Main analysis branch (per sample)
