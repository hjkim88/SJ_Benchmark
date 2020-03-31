###
#   File name : Subread_bulk_rnaseq_PC.R
#   Author    : Hyunjin Kim
#   Date      : Mar 30, 2020
#   Email     : hyunjin.kim@stjude.org
#   Purpose   : Do alignment and make Bam files from fastq.gz files - benchmarking
#
#   * THIS CODE SHOULD BE RUN ON LINUX
#
#   * THIS IS MOUSE DATA, HENCE MM10 WILL BE USED AS REFERENCE
#
#   Instruction
#               1. Source("Subread_bulk_rnaseq_PC.R")
#               2. Run the function "benchmark" - specify the input directory (fastq.gz) and output directory
#               3. The Bam files and raw counts will be generated under the output directory
#
#   Example
#               > source("The_directory_of_Subread_bulk_rnaseq_PC.R/Subread_bulk_rnaseq_PC.R")
#               > benchmark(fastqgzPath1="/mnt/c/Users/hkim8/Documents/SJ_Benchmark/data/FASTQ/ER_low_3_S9_R1.fastq.gz",
#                           fastqgzPath2="/mnt/c/Users/hkim8/Documents/SJ_Benchmark/data/FASTQ/ER_low_3_S9_R2.fastq.gz",
#                           referencePath="/mnt/c/Users/hkim8/Reference/mm10.fa",
#                           referenceIdxPath="/mnt/c/Users/hkim8/Reference/mm10.index",
#                           outputDir="/mnt/c/Users/hkim8/Documents/SJ_Benchmark/data/")
###

benchmark <- function(fastqgzPath1="/mnt/c/Users/hkim8/Documents/SJ_Benchmark/data/FASTQ/ER_low_3_S9_R1.fastq.gz",
                      fastqgzPath2="/mnt/c/Users/hkim8/Documents/SJ_Benchmark/data/FASTQ/ER_low_3_S9_R2.fastq.gz",
                      referencePath="/mnt/c/Users/hkim8/Reference/mm10.fa",
                      referenceIdxPath="/mnt/c/Users/hkim8/Reference/mm10.index",
                      outputDir="/mnt/c/Users/hkim8/Documents/SJ_Benchmark/data/") {
  
  ### load library
  # Sys.setenv(R_INSTALL_STAGED = FALSE)
  if(!require(Rsubread, quietly = TRUE)) {
    if(!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("Rsubread")
    require(Rsubread, quietly = TRUE)
  }
  if(!require(org.Mm.eg.db, quietly = TRUE)) {
    if(!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("org.Mm.eg.db")
    require(org.Mm.eg.db, quietly = TRUE)
  }
  if(!require(microbenchmark, quietly = TRUE)) {
    install.packages("microbenchmark")
    require(microbenchmark, quietly = TRUE)
  }
  
  ### create output directory
  dir.create(path = paste0(outputDir, "/bam_files/"), showWarnings = FALSE)
  
  ### get sample name
  x <- strsplit(basename(fastqgzPath1), "R1", TRUE)[[1]][1]
  sample_name <- substr(x, 1, nchar(x)-1)
  
  ### Benchmark
  results <- microbenchmark(
    PC_Subread = align(index=referenceIdxPath,
                       readfile1=fastqgzPath1,
                       readfile2=fastqgzPath2,
                       output_file=paste0(outputDir, "/bam_files/", sample_name, ".bam"),
                       nthreads = 4),
    times = 10)
  
  ### save the result
  results$time_mins <- results$time / (1E+9 * 60)
  colnames(results)[2] <- "time_nanoseconds"
  write.table(results, file = paste0(outputDir, "benchmark_subread_pc.txt"), sep = "\t")
  
}
