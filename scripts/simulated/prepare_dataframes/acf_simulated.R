# for easy loading of packages
if (!require("pacman")) install.packages("pacman")

# load packages
p_load("here")

# for relative filepaths
here::i_am(file.path("scripts", "simulated", "prepare_dataframes", "acf_simulated.R"))

# parameters
sequence_length <- 25
n_runs <- 10000
mean_ioi <- 500
sd_sampling <- 125
sd_jittering <- 88.83
maxlag <- 5

acf.output <- data.frame(matrix(data = NA, nrow = n_runs * 2 * (maxlag + 1), ncol = 3))
colnames(acf.output) <- c("condition", "lag", "acf")

# add progress bar so we can see what's happening
pb <- txtProgressBar(min = 1, max = n_runs, style = 3)

index <- 1

for (i in 1:n_runs) {
  # Sampling
  sampling_displacements <- rnorm(sequence_length, 0, sd_sampling)
  sampling_iois <- sampling_displacements + mean_ioi
  acf_sampling <- acf(sampling_iois, plot = FALSE, lag.max = maxlag)

  # Add to output dataframe
  for (l in 0:maxlag) {
    sampling_row <- c("Sampling", l, acf_sampling[["acf"]][l + 1])
    acf.output[index, ] <- sampling_row
    index <- index + 1
  }

  # Jittering
  jit_displacements <- rnorm(sequence_length + 1, 0, sd_jittering)
  jit_t_list <- seq(
    from = mean_ioi,
    to = (sequence_length + 1) * mean_ioi,
    by = mean_ioi
  )
  jit_t_list <- jit_t_list + jit_displacements
  jit_iois <- diff(jit_t_list)
  acf_jit <- acf(jit_iois, plot = FALSE, lag.max = maxlag)

  # Add to output dataframe
  for (l in 0:maxlag) {
    jit_row <- c("Jittering", l, acf_jit[["acf"]][l + 1])
    acf.output[index, ] <- jit_row
    index <- index + 1
  }

  # update progress bar
  setTxtProgressBar(pb, i)
}

# Change data structures and types
acf.output$condition <- as.factor(acf.output$condition)
acf.output$lag <- as.factor(acf.output$lag)
acf.output$acf <- as.double(acf.output$acf)

# Write out the simulations
saveRDS(acf.output, here("data", "simulated", "iois_autocorrelations.rds"))
