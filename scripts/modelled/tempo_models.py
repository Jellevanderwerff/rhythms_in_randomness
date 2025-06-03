import numpy as np
from scipy import sparse
import pandas as pd
import os

"""
Below, you can change the used parameters. The default values are the ones used in the paper.
"""

N = 22  # number of IOIs in a sequence
m = 5  # memory cut-off (for the equal weights scenario)
interval_durations = [400, 500]  # durations of IOI in ms
std_fractions = [0.2, 0.25]  # standard deviation as fraction of IOI duration
tau = 1000  # memory half-life in ms (for the exponential decay and optimal scenarios)

# Perform initial calculations that we need later on
def initial_calculations(interval_duration, std_fraction, tau, N, m):
    std_ms = interval_duration * std_fraction  # standard deviation in ms
    n_IOIs = N + m - 1  # total number of IOIs in the experiment
    a = interval_duration / tau  # here we just 2^(t/tau) which we need to construct the "half life" weights
    return std_ms, n_IOIs, a

# Generate the covariance matrices for 'sampling' and 'jittering'
def generate_covariance_matrices(std_ms, totIOIs):
    # definition of covariance matrices for Jitter and Sampling
    J = sparse.diags([-1 / 2, 1, -1 / 2], [-1, 0, 1], shape=(totIOIs, totIOIs)).toarray()
    J[0, 0] = 1 / 2
    J[totIOIs - 1, totIOIs - 1] = 1 / 2
    J = std_ms**2 * J
    S = std_ms**2 * np.identity(totIOIs)
    return J, S

# Equal weights scenario (brutal average)
def equal_weights(covariance_matrix, interval_i):
    """
    This function takes as arguments a covariance matrix, and the index of the interval we want to estimate the error for.
    It returns the error for the equal weights scenario for the supplied interval.
    """
    p = max(1, interval_i - m + 1)
    l = interval_i - p + 1
    w = (1 / l) * np.ones(l)
    G = covariance_matrix[p - 1 : interval_i, p - 1 : interval_i]
    return np.sqrt(np.dot(w, np.dot(G, w)))


# Exponential decay scenario
def exponential_decay(covariance_matrix, a, interval_i):
    """
    This function takes as arguments a covariance matrix, the 'a' calculated in the initial_calculations functions, and 
    the index of the interval we want to estimate the error for.
    It returns the error for the exponential decay scenario for the supplied interval.
    """
    w = np.array([a**j for j in range(0, interval_i)])
    w = (1 / np.sum(w)) * w
    G = covariance_matrix[0:interval_i, 0:interval_i]
    return np.sqrt(np.dot(w, np.dot(G, w)))


def optimal_error(covariance_matrix, interval_i):
    """
    This function takes as arguments a covariance matrix, and the index of the interval we want to estimate the error for.
    It returns the error for the optimal scenario for the supplied interval.
    """
    G = covariance_matrix[0:interval_i, 0:interval_i]
    if np.linalg.det(G) != 0:
        ans = np.sqrt(1 / np.sum(np.linalg.inv(G)))
    else:
        ans = 0
    return ans


def generate_dataframe(N, m, interval_duration, std_fraction, tau):
    """
    This functions takes the parameters defined at the top of this script,
    and returns a dataframe with the error values for the various scenarios.

    These are the parameters:
    N = number of IOIs in the experiment
    m = memory cut-off
    interval_duration = duration of IOI in ms
    std_fraction = standard deviation as fraction of IOI duration
    tau = memory half-life in ms
    """

    # Perform initial calculations
    std_ms, n_IOIs, a = initial_calculations(
        interval_duration, std_fraction, tau, N, m
    )

    # Generate the covariance matrices
    J, S = generate_covariance_matrices(std_ms, n_IOIs)

    # Make a list of IOI indices to estimate the error for
    IOI_indices = np.arange(1, N + 1)

    # Make dictionaries with error values for each scenario
    jittering_equalweights = {
        "condition": "Jittering",
        "strategy": "equal_weights",
        "tempo": interval_duration,
        "std_fraction": std_fraction,
        "interval_i": IOI_indices,
        "error": [equal_weights(J, k) for k in IOI_indices],
    }
    jittering_exponentialdecay = {
        "condition": "Jittering",
        "strategy": "exp_decay",
        "tempo": interval_duration,
        "std_fraction": std_fraction,
        "interval_i": IOI_indices,
        "error": [exponential_decay(J, a, k) for k in IOI_indices],
    }
    jittering_optimal = {
        "condition": "Jittering",
        "strategy": "optimal",
        "tempo": interval_duration,
        "std_fraction": std_fraction,
        "interval_i": IOI_indices,
        "error": [optimal_error(J, k) for k in IOI_indices],
    }
    sampling_equalweights = {
        "condition": "Sampling",
        "strategy": "equal_weights",
        "tempo": interval_duration,
        "std_fraction": std_fraction,
        "interval_i": IOI_indices,
        "error": [equal_weights(S, k) for k in IOI_indices],
    }
    sampling_exponentialdecay = {
        "condition": "Sampling",
        "strategy": "exp_decay",
        "tempo": interval_duration,
        "std_fraction": std_fraction,
        "interval_i": IOI_indices,
        "error": [exponential_decay(S, a, k) for k in IOI_indices],
    }
    sampling_optimal = {
        "condition": "Sampling",
        "strategy": "optimal",
        "tempo": interval_duration,
        "std_fraction": std_fraction,
        "interval_i": IOI_indices,
        "error": [optimal_error(S, k) for k in IOI_indices],
    }


    # Dataframe in long format
    df = pd.concat(
        [
            pd.DataFrame.from_dict(jittering_equalweights),
            pd.DataFrame.from_dict(jittering_exponentialdecay),
            pd.DataFrame.from_dict(jittering_optimal),
            pd.DataFrame.from_dict(sampling_equalweights),
            pd.DataFrame.from_dict(sampling_exponentialdecay),
            pd.DataFrame.from_dict(sampling_optimal),
        ]
    )
    return df


if __name__ == "__main__":
    # Generate and export dataframe
    df = pd.DataFrame()
    for interval_duration in interval_durations:
        for std_fraction in std_fractions:
            df = pd.concat([df, generate_dataframe(N, m, interval_duration, std_fraction, tau)])
    df.to_csv(os.path.join("data", "modelled", "tempo_models.csv"), index=False)
