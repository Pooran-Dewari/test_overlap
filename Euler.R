#setwd("/home/pdewari/Documents/2022/AtlanticSalmon/Atlantic_salmon_March22/macs2/H3K27me3/K27me3")

#create a function

library(tidyverse)
library(eulerr)

make_plot <- function(Peak_txt_file) {
  
  file_name <- Peak_txt_file
  
  my_file <- read.table(file_name, header = TRUE)
  
  row.names(my_file) <- my_file$file
  
  my_file <- my_file %>%
    select(2)
  
  Upreg <- euler(c("R1"= my_file$overlap[4],
                 "R2" = my_file$overlap[2],
                 "R3" = my_file$overlap[1],
                 "R1&R2" = my_file$overlap[6],
                 "R1&R3" = my_file$overlap[5],
                 "R2&R3" = my_file$overlap[3],
                 "R1&R2&R3" = my_file$overlap[7]),
               shape = "ellipse")
  
  filename = paste0(file_name,".jpg")
  print(filename)
  #Open jpeg file
  jpeg(filename=filename, width = 600, height = 600)
  
  the_plot <- plot(Upreg,
                   main = filename,
                   labels = list(fontfamily = "Arial", fontsize=15),
                   fill=c("#FCD1B8", "#53D2CE", "#C8A2C8"), numbers=TRUE,
                   fontsize = 8,
                   quantities = list(fontfamily = "Arial", fontsize=15, type = c("counts","percent")),
                   #legend = list(side = "right"),
                   lwd = 1.5)
  print(the_plot)
  
  dev.off()
}

#get list of overlap.txt files
myFiles <- list.files(pattern = ".txt") 

#apply function over the list of files
lapply(myFiles, make_plot)

