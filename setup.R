library(tidyverse)

on_kaggle <- dir.exists("/kaggle/input")
data_dir <- if (on_kaggle) "/kaggle/input/TODO" else here::here("data")
output_dir <- if (on_kaggle) "/kaggle/working" else here::here("output")
dir.create(output_dir, showWarnings = FALSE)
