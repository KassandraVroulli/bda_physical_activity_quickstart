# Helper functions

most_common_value <- function(x) {
  counts <- table(x, useNA = "no")
  most_frequent <- which.max(counts)
  return(names(most_frequent))
}
