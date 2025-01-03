process DESEQ2_NORMALIZE {

    // debug true

    publishDir "${params.outdir}/normalization/deseq2"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/ce/cef7164b168e74e5db11dcd9acf6172d47ed6753e4814c68f39835d0c6c22f6d/data':
        'community.wave.seqera.io/library/bioconductor-deseq2_r-base_r-optparse:c84cd7ffdb298fa7' }"

    input:
    tuple val(meta), path(count_file)

    output:
    tuple val(meta), path('*.log_cpm.csv'),                                                                          emit: csv
    tuple val("${task.process}"), val('R'),      eval('Rscript -e "cat(R.version.string)" | sed "s/R version //"'),  topic: versions
    tuple val("${task.process}"), val('DESeq2'), eval('Rscript -e "cat(as.character(packageVersion(\'DESeq2\')))"'), topic: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def design_file = meta.design
    """
    deseq2_normalize.R --counts "$count_file" --design "$design_file"
    """


}
