# Converts notebook.Rmd to output/notebook.ipynb for Kaggle.
# The code is not run here; Kaggle runs it.

ipynb <- rmarkdown::output_format(
  knitr = rmarkdown::knitr_options(
    opts_chunk = list(eval = FALSE),
    opts_hooks = list(child = function(options) {
      options$eval <- TRUE # still include the notebooks in analysis/
      options
    }),
    knit_hooks = list(source = function(x, options) {
      code <- paste(x, collapse = "\n")
      paste0("\n::: {.cell .code}\n```r\n", code, "\n```\n:::\n")
    })
  ),
  pandoc = rmarkdown::pandoc_options(to = "ipynb")
)

rmarkdown::render(
  here::here("notebook.Rmd"),
  output_format = ipynb,
  output_dir = here::here("output")
)
