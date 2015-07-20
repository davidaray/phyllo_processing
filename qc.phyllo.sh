#!/bin/bash
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N QC
#$ -o $JOB_NAME.o$JOB_ID
#$ -e $JOB_NAME.e$JOB_ID
#$ -q R2D2
#$ -pe fill 5 
#$ -P communitycluster

#This file will process raw Illumina data using FASTX Toolkit. 

BASEDIR=/lustre/scratch/daray/ray_phyllo
SEQDIR=/lustre/scratch/daray/HiSeq
WORKDIR=$BASEDIR/qc_HiSeq

mkdir $WORKDIR
cd $WORKDIR

#THREADS=9  #Line 9 sets this up to run 5 processors.  If you want fewer, make sure to change that line as well as this one.

######
#set up alias' for major programs
######
BWA_HOME=/lustre/work/apps/bwa-0.6.2
SAMTOOLS_HOME=/lustre/work/apps/samtools-1.2
SAMTOOLS1_8_HOME=/lustre/work/apps/samtools-0.1.18
PICARD_HOME=/lustre/work/apps/picard-tools-1.91
BCFTOOLS_HOME=/lustre/work/apps/samtools-0.1.18/bcftools
RAY_SOFTWARE=/lustre/work/daray/software
TRIM_HOME=/lustre/work/apps/Trimmomatic-0.27
FASTX_HOME=/lustre/work/apps/fastx_toolkit-0.0.14/bin
VCFTOOLS_HOME=/lustre/work/daray/software/vcftools_0.1.12b/bin

for RAW_READ_FOLDER in $SEQDIR/HiSeq/*;
	mkdir $SEQDIR/qc_HiSeq/$RAW_READ_FOLDER;	\
done

for RAW_READ_FOLDER in $SEQDIR/HiSeq/*;

	for RAW_READ_FILE in $SEQDIR/HiSeq/$RAW_READ_FOLDER
	do
		SAMPLE_ID=$(basename $RAW_READ_FILE _fastq.gz)
		$FASTX_HOME/fastq_quality_filter 			\
			-i $RAW_READ_FILE			\
			-Q33							\
			-q20							\
			-p 50							\
			-o $SEQDIR/qc_HiSeq/$RAW_READ_FILE"_QC.fastq.gz"		

		$FASTX_HOME/fastx_quality_stats 					\
			-Q33		 						\
			-o $SEQDIR/qc_HiSeq/$RAW_READ_FILE"_QC.stats" 	\
			-i $SEQDIR/qc_HiSeq/$RAW_READ_FILE"_QC.fastq.gz"

		$FASTX_HOME/fastx_nucleotide_distribution_graph.sh 			\
			-i $SEQDIR/qc_HiSeq/$RAW_READ_FILE"_QC.stats"		\
			-o $SEQDIR/qc_HiSeq/$RAW_READ_FILE"_QC_NUC.png"	\
			-t $RAW_READ_FILE"_QC"		

		$FASTX_HOME/fastq_quality_boxplot_graph.sh 				\
			-i $SEQDIR/qc_HiSeq/$RAW_READ_FILE"_QC.stats" 	\
			-o $SEQDIR/qc_HiSeq/$RAW_READ_FILE"_QC_BOX.png"	\
			-t $RAW_READ_FILE"_QC"		

done

#echo "qc finished" |  mailx -s "qc finished" 9895280979@tmomail.net
#echo "qc finished" |  mailx -s "qc finished" david.4.ray@gmail.com

#sleep 5

