# This script uses data simulated in iois_simulated.R. If you want to run this, first run that one.

# Prelims
# for easy loading of packages
if (!require("pacman")) install.packages("pacman")

# load packages
p_load("here", "zoo", "reshape")

# parameters
n_iois <- 25  # number of iois in a single sequence in the sample data

# for relative file paths (e.g. here('Input', 'file.csv'))
here::i_am(file.path('scripts', 'simulated', 'prepare_dataframes', 'iois_simulated_movingaverages.R'))

# load data
iois <- readRDS(here('data', 'simulated', 'iois_simulated.rds'))

# add progress bar so we can see what's happening
pb <- txtProgressBar(min = 1, max = 4 * nrow(iois) / n_iois, style = 3)
i <- 1

# calculate moving averages
for (window_size in 2:5) {
  print(paste("Busy with window", window_size))
  colname <- as.character(window_size)
  iois[ , colname] <- rep(NA, nrow(iois))
  for (index in seq(1, nrow(iois), n_iois)) {
    iois[index:(index+n_iois-1), colname] <- rollmean(iois$ioi[index:(index+n_iois-1)],
                                                    k=window_size, fill=NA, align="right")

    i <- i + 1
  # update progress bar
  setTxtProgressBar(pb, i)

  }
}

# melt and save the dataframe
iois.ma <- melt(iois, measure.vars = colnames(iois)[3:6])
colnames(iois.ma) <- c("condition", "ioi", "window_size", "ma")
saveRDS(iois.ma, here('data', 'simulated', 'iois_movingaverages.rds'))
