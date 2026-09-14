# Feature functions (time domain)

lagged_cor <- function(x, y = x, lag = 0) {
  # compute correlation between x and a time shifted y
  r_lagged <- cor(x, dplyr::lag(y, lag), use = "pairwise")
  return(r_lagged)
}

# Feature functions (frequency domain)

mean_frequency <- function(freq, spec) {
  delta_f <- freq[2] - freq[1] # gap size between frequencies
  normalizing_constant <- sum(spec * delta_f) # ≈ ∫S(f)df
  mean_freq <- sum(freq * spec * delta_f) / normalizing_constant
  return(mean_freq)
}

extractTimeDomainFeatures <- function(filename, sample_labels) {
  # extract user and experimental run ID's from file name
  username <- str_extract(filename, "(?<=user)\\d+") |> as.integer()
  expname <- str_extract(filename, "(?<=exp)\\d+") |> as.integer()

  # import the sensor signals from the file
  user01 <- read_delim(filename,
    delim = " ", col_names = FALSE, progress = TRUE,
    col_types = "ddd"
  )


  # merge signals with labels
  user_df <-
    tibble(userid = username, trial = expname, sampleid = seq.int(0, nrow(user01) - 1)) |>
    bind_cols(user01) |>
    left_join(sample_labels, by = c("userid", "trial", "sampleid"))

  usertimedom <- user_df |>
    # partition into epochs and add an epoch ID variable (one epoch = 2.56 sec)
    mutate(epoch = sampleid %/% 128) |>
    # extract statistical features from each epoch
    group_by(epoch) |>
    summarise(
      # Keep track of user and experiment information
      user_id = username,
      exp_id = expname,

      # Activity label for the epoch = most common value (mode)
      activity = most_common_value(c("-", activity)),

      # Keep starting sample ID of the epoch
      sampleid = sampleid[1],

      # Signal features
      mean_X1 = mean(X1),
      mean_X2 = mean(X2),
      sd_X1 = sd(X1),
      q25_X1 = quantile(X1, .25),
      skew_X1 = e1071::skewness(X1),
      AR1_X1_lag1 = lagged_cor(X1, lag = 1),
      AR1_X1_lag2 = lagged_cor(X1, lag = 2),
      AR_X1X2_lag1 = lagged_cor(X1, X2, lag = 1),

      # ...
      # ... add your own features here ...
      # ... (to get inspired, look at the histograms above)
      # ...

      # Keep track of epoch lengths (some epochs are less than 128 samples)
      n_samples = n()
    )
  usertimedom
}
