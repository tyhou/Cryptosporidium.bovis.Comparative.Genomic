#!/bin/bash
#SBATCH --job-name=mapping_ref
#SBATCH -p sonmi
#SBATCH -n 32
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --nodelist=compute-0-0
##SBATCH -mem=200G
##SBATCH -t 72:00:00

ulimit -s unlimited
ulimit -l unlimited

module load bwa-mem2
cd $SLURM_SUBMIT_DIR

for id in $(cat SampleID)
do
bwa-mem2 mem -t 32 /index_BWA_48472/48472_ref \
cleandata/${id}_1.fq.gz cleandata/${id}_2.fq.gz | samtools sort -O BAM -@ 32 -o mapping/${id}_sort.bam > mapping/${id}.log
echo "$id in bwa-mem2"
done
echo "bwa-mem2 is done"

for id in $(cat SampleID)
do
sambamba markdup -r -t 32 mapping/${id}_sort.bam mapping/${id}_markdup.bam
samtools flagstat mapping/${id}_markdup.bam -@ 32 > mapping/${id}_stat.log
echo "$id in sambamba"
done
echo "sambamba is done"
exit
