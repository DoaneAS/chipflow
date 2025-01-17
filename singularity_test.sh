#!/usr/bin/env bash

script_path="main.nf"
if [ -z $1]
then
    echo "No argument given, going to try to run ../main.nf"
else
    script_path=$1
fi

data_path="/athena/elementolab/scratch/asd2007/projectshg38/datasets/ngi"
if [ -d "./test_data" ]
then
    data_path="./test_data"
    echo "Found data directory in current working directory, using ./test_data/"
fi

curl --version >/dev/null 2>&1 || { echo >&2 "I require curl, but it's not installed. Aborting."; exit 1; }
tar --version >/dev/null 2>&1 || { echo >&2 "I require tar, but it's not installed. Aborting."; exit 1; }
#docker -v >/dev/null 2>&1 || { echo >&2 "I require docker, but it's not installed. Visit https://www.docker.com/products/overview#/install_the_platform  ."; exit 1; }
nextflow -v >/dev/null 2>&1 || { echo >&2 "I require nextflow, but it's not installed. If you hava Java, run 'curl -fsSL get.nextflow.io | bash'. If not, install Java."; exit 1; }

data_dir=${data_path}/data
if [ -d $data_dir ]
then
    echo "Found existing test set, using $data_dir"
else
    echo "Downloading test set..."
    curl https://export.uppmax.uu.se/b2013064/test-data/ngi-chipseq_test_set.tar.bz2 > ${data_path}/ngi-chipseq_test_set.tar.bz2
    echo "Unpacking test set..."
    tar xvjf ${data_path}/ngi-chipseq_test_set.tar.bz2 -C ${data_path}
    echo "Done"
fi


### --fasta ${data_dir}/hg38/bwa_index/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta

nf_cmd="nextflow run $script_path -profile singularity --genome hg38 --macsconfig ${data_dir}/macsconfig.txt --singleEnd --reads \"${data_dir}/*_R1.fastq.gz\""

###nf_cmd="nextflow run $script_path -resume -profile singularity --genome hg38 --bwa_index ${data_dir}/hg38/bwa_index/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta --macsconfig ${data_dir}/macsconfig.txt --singleEnd --reads \"${data_dir}/*_R1.fastq.gz\""
echo "Starting nextflow... Command:"
echo $nf_cmd
echo "--------------------------------------------------"
eval $nf_cmd

