###
#   File name : Wrap_up_the_results.R
#   Author    : Hyunjin Kim
#   Date      : Mar 31, 2020
#   Email     : hyunjin.kim@stjude.org
#   Purpose   : Gather all the benchmarking results and create a figure with tables and figures
#
#   Instruction
#               1. Source("Wrap_up_the_results.R")
#               2. Run the function "benchmark_result" - specify the necessary directory and the output directory
#               3. The results will be generated under the output directory
#
#   Example
#               > source("The_directory_of_Wrap_up_the_results.R/Wrap_up_the_results.R")
#               > benchmark_result(inputDir="./data/",
#                                  spec_path="./etc/machine_specs.txt",
#                                  outputDir="./results/")
###

benchmark_result <- function(inputDir="./data/",
                             spec_path="./etc/machine_specs.txt",
                             outputDir="./results/") {
  
  ### load library
  if(!require(microbenchmark, quietly = TRUE)) {
    install.packages("microbenchmark")
    require(microbenchmark, quietly = TRUE)
  }
  if(!require(ggbeeswarm, quietly = TRUE)) {
    install.packages("ggbeeswarm")
    require(ggbeeswarm, quietly = TRUE)
  }
  if(!require(ggpubr, quietly = TRUE)) {
    install.packages("ggpubr")
    require(ggpubr, quietly = TRUE)
  }
  if(!require(gridExtra, quietly = TRUE)) {
    install.packages("gridExtra")
    require(gridExtra, quietly = TRUE)
  }
  
  ### get input file names
  f <- list.files(path = inputDir, pattern = ".txt$", full.names = TRUE)
  
  ### load the input files
  input <- lapply(f, function(x) {
    read.table(x, header = TRUE, sep = "\t", row.names = 1,
               stringsAsFactors = FALSE, check.names = FALSE)  
  })
  
  ### combine into one data frame
  combine <- Reduce(function(x, y) rbind(x, y), input)
  class(combine) <- c("microbenchmark", "data.frame")
  
  ### machine specs
  specs <- read.table(file = spec_path, header = TRUE, sep = "\t",
                      stringsAsFactors = FALSE, check.names = FALSE)
  p1 <- tableGrob(specs, rows = NULL)
  
  ### get averaged result
  result_table <- print(combine[,1:2])
  colnames(result_table) <- c("Time (seconds)", "Min", "25%", "Mean", "Median", "75%", "Max", "Iteration")
  p2 <- tableGrob(result_table, rows = NULL)
  
  ### beeswarm plot of the result
  p3 <- ggplot(combine, aes_string(x="expr", y="time_mins")) +
          geom_boxplot() +
          geom_beeswarm(aes_string(color="expr"), na.rm = TRUE) +
          xlab("") +
          theme_classic(base_size = 16) +
          theme(legend.title = element_blank())
  
  ### arrange the plots and print out
  fName <- "Benchmarking Results - Subread"
  g <- grid.arrange(p1, p2, p3, top = fName, layout_matrix = rbind(c(1, 1, 3, 3, 3), c(2, 2, 3, 3, 3)))
  ggsave(file = paste0(outputDir, fName, ".png"), g, width = 18, height = 8, dpi = 300)
  
}
