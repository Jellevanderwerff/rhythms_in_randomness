############# PACKAGES AND OTHER PRELIMINARIES ############

# for easy loading of packages
if (!require("pacman")) install.packages("pacman")

# load packages
p_load("here")

here::i_am(file.path("scripts", "simulated", "prepare_dataframes", "iois_simulated.R"))

n_iois <- 25
n_seqs <- 10000
mean_ioi <- 500
sd_sampling <- 125
sd_jittering <- 88.83

rows_per_loop <- n_iois * 2
output_nrows <- rows_per_loop * n_seqs


iois.simulated <- data.frame(matrix(nrow = output_nrows, ncol = 3))
colnames(iois.simulated) <- c("condition", "sequence_id", "ioi")

# add progress bar so we can see what's happening
pb <- txtProgressBar(min = 1, max = n_seqs, style = 3)

first_row <- 1
last_row <- first_row + rows_per_loop - 1

for (i in 1:n_seqs) {
  # Sampling
  sampling_displacements <- rnorm(n_iois, 0, sd_sampling)
  sampling_iois <- sampling_displacements + mean_ioi

  # Jittering
  jit_displacements <- rnorm(n_iois + 1, 0, sd_jittering)
  jit_t_list <- seq(
    from = mean_ioi,
    to = (n_iois + 1) * mean_ioi,
    by = mean_ioi
  )
  jit_t_list <- jit_t_list + jit_displacements
  jit_iois <- diff(jit_t_list)

  # Create temp dataframes
  sampling_df <- as.data.frame(list(
    "condition" = "Sampling",
    "sequence_id" = i,
    "ioi" = sampling_iois
  ))
  jittering_df <- as.data.frame(list(
    "condition" = "Jittering",
    "sequence_id" = i,
    "ioi" = jit_iois
  ))

  # Add dataframes to output dataframe
  iois.simulated[first_row:last_row, ] <- rbind(sampling_df, jittering_df)


  # update progress bar and indices
  setTxtProgressBar(pb, i)
  first_row <- first_row + rows_per_loop
  last_row <- last_row + rows_per_loop
}

# Change data structures and types
iois.simulated$condition <- as.factor(iois.simulated$condition)

# Save dataframe
saveRDS(iois.simulated, here("data", "simulated", "iois_simulated.rds"))
