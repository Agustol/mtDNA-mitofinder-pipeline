#!/bin/bash
#SBATCH --job-name=mt_pipeline
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=48:00:00
#SBATCH --output=mt_pipeline.%j.out
#SBATCH --error=mt_pipeline.%j.err

set -eo pipefail

############################################
# CONFIG
############################################
CONDA_ENV="mt_pipeline"

SAMPLE_LIST="sample_list.txt"
REF="reference/NC_041257.fa"
REFGB="reference/NC_041257.gb"
OUTDIR="results"

TOTAL_CPUS=${SLURM_CPUS_PER_TASK:-16}
N_JOBS=4
THREADS=$(( TOTAL_CPUS / N_JOBS ))
[[ "$THREADS" -lt 1 ]] && THREADS=1

############################################
# ACTIVATE CONDA
############################################
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV"

############################################
# PREP
############################################
mkdir -p "$OUTDIR"

[[ -f "${REF}.bwt" ]] || bwa index "$REF"
[[ -f "${REF}.fai" ]] || samtools faidx "$REF"

############################################
# BUILD CDS BED (FIXED)
############################################
CHROM=$(grep "^>" "$REF" | sed 's/>//' | awk '{print $1}')

awk -v chrom="$CHROM" '
/^     CDS/ {
    line=$0
    sub(/^     CDS[[:space:]]+/, "", line)
    strand="+"
    if (line ~ /complement/) strand="-"
    gsub(/complement\(|join\(|\)| /,"", line)
    n=split(line, parts, ",")
    for (i=1; i<=n; i++) {
        split(parts[i], coords, /\.\./)
        if (coords[1] ~ /^[0-9]+$/ && coords[2] ~ /^[0-9]+$/) {
            start=coords[1]-1
            end=coords[2]
            print chrom "\t" start "\t" end "\tCDS_part" i "\t0\t" strand
        }
    }
}
' "$REFGB" > "$OUTDIR/cds_coords.bed"

############################################
# FUNCTION
############################################
process_one() {

    SAMPLE="$1"
    READ1="$2"
    READ2="$3"

    echo "Processing $SAMPLE"

    mkdir -p "$OUTDIR/$SAMPLE"/{bam,vcf,consensus,genes}

    BAM="$OUTDIR/$SAMPLE/bam/$SAMPLE.sorted.bam"
    MAPPED="$OUTDIR/$SAMPLE/bam/$SAMPLE.mapped.bam"
    VCF="$OUTDIR/$SAMPLE/vcf/$SAMPLE.vcf.gz"
    CONS="$OUTDIR/$SAMPLE/consensus/${SAMPLE}_mt.fasta"

    bwa mem -t "$THREADS" "$REF" "$READ1" "$READ2" \
        | samtools view -b - \
        | samtools sort -@ "$THREADS" -o "$BAM" -

    samtools index "$BAM"

    samtools view -b -F 4 "$BAM" > "$MAPPED"
    samtools index "$MAPPED"

    bcftools mpileup -f "$REF" "$MAPPED" -Ou \
        | bcftools call -mv --ploidy 1 -Oz -o "$VCF"

    bcftools index "$VCF"

    bcftools consensus -f "$REF" "$VCF" > "$CONS"

    bedtools getfasta \
        -fi "$CONS" \
        -bed "$OUTDIR/cds_coords.bed" \
        -s \
        -fo "$OUTDIR/$SAMPLE/genes/${SAMPLE}_cds.fasta"

    cd "$OUTDIR/$SAMPLE"

    mitofinder \
        -j "$SAMPLE" \
        -1 "$READ1" \
        -2 "$READ2" \
        -r "$REFGB" \
        -o 2 \
        -p "$THREADS" \
        --metaspades

    cd - > /dev/null

    echo "[$SAMPLE] DONE"
}

export -f process_one
export REF REFGB OUTDIR THREADS

############################################
# PARALLEL LOOP
############################################
while read SAMPLE READ1 READ2; do

    process_one "$SAMPLE" "$READ1" "$READ2" &

    # Limit number of concurrent jobs
    while [[ $(jobs -r | wc -l) -ge $N_JOBS ]]; do
        sleep 2
    done

done < "$SAMPLE_LIST"

wait

echo "ALL SAMPLES COMPLETE"
