# Run iois_simulated.R first (this script used the iois_simulated.rds dataframe)

if (!require(pacman)) install.packages('pacman')
p_load('here')
here <- here::here
here::i_am(file.path('scripts', 'simulated', 'prepare_dataframes', 'onsets_simulated.R'))

iois.simulated.sequences <- readRDS(here('data', 'simulated', 'iois_simulated.rds'))

onsets.simulated <- data.frame(matrix(nrow = 26 * 10000 * 2, ncol = 3))
colnames(onsets.simulated) <- c("condition", "event_i", "onset")

cur_row <- 1

pb <- txtProgressBar(min = cur_row, max = 26 * 10000 * 2)

for (i in seq(1, nrow(iois.simulated.sequences), 25)) {
  df_piece <- iois.simulated.sequences[i:(i+24), ]
  iois <- df_piece$ioi
  onsets <- cumsum(c(0, iois))
  condition <- as.character(df_piece$condition[1])
  event_i <- 1:26
  out_df <- as.data.frame(list(
    condition = condition,
    event_i = event_i,
    onset = onsets
  ))
  onsets.simulated[cur_row:(cur_row + 25), ] <- out_df

  cur_row <- cur_row + 26
  setTxtProgressBar(pb, cur_row)
}

onsets.simulated$condition <- as.factor(onsets.simulated$condition)
onsets.simulated$event_i <- as.factor(onsets.simulated$event_i)

saveRDS(onsets.simulated, here('data', 'simulated', 'onsets_simulated.rds'))