# Power and Sample Size Simulation
# Assumptions:
# - Median PFS control arm: 11 months (taking middle of 10-12 month range)
# - Target HR: 0.70
# - Two-sided alpha: 0.05
# - Target power: 80%
# - One interim analysis + final analysis

# Load required libraries
library(gsDesign)  # For group sequential design
library(survival)  # For survival analysis functions

#========== PART 1: Simple Sample Size Calculation ==========
# Convert median survival times to lambda parameters for exponential distribution
# Lambda = log(2)/median
lambda_control <- log(2)/11  # Control arm (erlotinib alone)
lambda_experimental <- lambda_control * 0.70  # Experimental arm (ramucirumab + erlotinib)
# HR of 0.70 means 30% reduction in hazard rate

# Simple sample size calculation without interim analysis
# Using Schoenfeld's formula for log-rank test
simple_ss <- function(hr, alpha, power, p_experimental = 0.5) {
  # hr: hazard ratio
  # alpha: significance level
  # power: desired power
  # p_experimental: proportion of subjects in experimental arm
  
  p_control <- 1 - p_experimental
  z_alpha <- qnorm(1 - alpha/2)  # Two-sided alpha
  z_beta <- qnorm(power)
  
  # Total number of events needed
  d <- ((z_alpha + z_beta)^2) / (p_experimental * p_control * log(hr)^2)
  
  return(ceiling(d))
}

# Calculate number of events needed
events_needed <- simple_ss(hr = 0.70, alpha = 0.05, power = 0.80)
print(paste("Events needed for simple design:", events_needed))

#========== PART 2: Group Sequential Design ==========
# Create group sequential design with one interim analysis
# Using O'Brien-Fleming spending function

# Define the group sequential design
gs_design <- gsDesign(
  k = 2,                  # Number of analyses (1 interim + 1 final)
  test.type = 2,          # Two-sided test
  alpha = 0.05,           # Overall type I error
  beta = 0.2,             # Type II error (1 - power)
  timing = 0.5,           # Information fraction at interim (50% of events)
  sfu = "OF"              # O'Brien-Fleming spending function
)

# Display the design
print(gs_design)

#========== PART 3: Sample Size Calculation ==========
# Calculate sample size based on events needed and expected enrollment/follow-up

# Parameters
accrual_period <- 18      # Enrollment period in months
follow_up_period <- 12    # Minimum follow-up after last patient enrolled
dropout_rate <- 0.05      # Annual dropout rate

# Function to calculate sample size based on events
calculate_sample_size <- function(events, hr, accrual_period, follow_up_period, 
                                  lambda_control, dropout_rate) {
  # Convert annual dropout rate to monthly
  monthly_dropout <- 1 - (1 - dropout_rate)^(1/12)
  
  # Initial estimate of sample size (typically needs iteration)
  # Using a rough approximation based on event rate
  n_initial <- ceiling(events / (1 - exp(-lambda_control * (accrual_period/2 + follow_up_period))))
  
  # Refine with simulation
  n_min <- n_initial * 0.7
  n_max <- n_initial * 1.3
  n_step <- 10
  
  best_n <- n_initial
  best_diff <- Inf
  
  for (n in seq(n_min, n_max, n_step)) {
    # Simulate trial with n patients
    n_control <- floor(n/2)
    n_experimental <- n - n_control
    
    # Generate accrual times (uniform over accrual period)
    accrual_times <- runif(n, 0, accrual_period)
    
    # Generate survival times
    survival_times_control <- rexp(n_control, lambda_control)
    survival_times_exp <- rexp(n_experimental, lambda_control * hr)
    survival_times <- c(survival_times_control, survival_times_exp)
    
    # Generate dropout times
    dropout_times <- rexp(n, monthly_dropout)
    
    # Calculate observation time for each patient
    obs_times <- pmin(survival_times, dropout_times, accrual_period + follow_up_period - accrual_times)
    
    # Count events
    event_indicator <- (obs_times == survival_times) & (survival_times <= accrual_period + follow_up_period - accrual_times)
    sim_events <- sum(event_indicator)
    
    # Check how close we are to target events
    diff <- abs(sim_events - events)
    if (diff < best_diff) {
      best_diff <- diff
      best_n <- n
    }
  }
  
  return(best_n)
}

# Calculate sample size for simple design
sample_size_simple <- calculate_sample_size(
  events = events_needed,
  hr = 0.70,
  accrual_period = accrual_period,
  follow_up_period = follow_up_period,
  lambda_control = lambda_control,
  dropout_rate = dropout_rate
)

# Calculate sample size for group sequential design
sample_size_gs <- calculate_sample_size(
  events = gs_design$n.I[2] * events_needed,  # Events needed at final analysis
  hr = 0.70,
  accrual_period = accrual_period,
  follow_up_period = follow_up_period,
  lambda_control = lambda_control,
  dropout_rate = dropout_rate
)

print(paste("Estimated sample size for simple design:", sample_size_simple))
print(paste("Estimated sample size for group sequential design:", sample_size_gs))

#========== PART 4: Power Simulation ==========
# Simulate trials to verify power

simulate_trial_power <- function(n_trials, n_patients, hr, interim_fraction,
                                 alpha_interim, alpha_final) {
  # Initialize counters
  reject_at_interim <- 0
  reject_at_final <- 0
  
  for (i in 1:n_trials) {
    # Allocate patients to groups
    n_control <- floor(n_patients/2)
    n_experimental <- n_patients - n_control
    group <- c(rep(0, n_control), rep(1, n_experimental))
    
    # Generate survival times
    surv_times <- ifelse(group == 0, 
                         rexp(n_patients, lambda_control),
                         rexp(n_patients, lambda_control * hr))
    
    # Generate censoring times
    cens_times <- rexp(n_patients, 0.5 * lambda_control)  # Assuming lower censoring rate
    
    # Observed time is minimum of survival and censoring
    obs_times <- pmin(surv_times, cens_times)
    event <- surv_times <= cens_times
    
    # Create survival objects
    surv_obj <- Surv(obs_times, event)
    
    # Sort by time for interim analysis
    sorted_indices <- order(obs_times)
    sorted_times <- obs_times[sorted_indices]
    sorted_events <- event[sorted_indices]
    sorted_groups <- group[sorted_indices]
    
    # Determine interim analysis point (e.g., after 50% of events)
    interim_events <- sum(sorted_events[1:floor(sum(event) * interim_fraction)])
    interim_indices <- which(cumsum(sorted_events) <= interim_events)
    
    if (length(interim_indices) > 0) {
      # Fit Cox model at interim
      interim_data <- data.frame(
        time = sorted_times[1:max(interim_indices)],
        event = sorted_events[1:max(interim_indices)],
        group = sorted_groups[1:max(interim_indices)]
      )
      
      interim_fit <- try(coxph(Surv(time, event) ~ group, data = interim_data), silent = TRUE)
      
      if (!inherits(interim_fit, "try-error")) {
        interim_pval <- summary(interim_fit)$coefficients[5]  # p-value
        
        if (!is.na(interim_pval) && interim_pval < alpha_interim) {
          reject_at_interim <- reject_at_interim + 1
          next  # Trial stopped at interim
        }
      }
    }
    
    # Proceed to final analysis if not rejected at interim
    final_data <- data.frame(
      time = obs_times,
      event = event,
      group = group
    )
    
    final_fit <- try(coxph(Surv(time, event) ~ group, data = final_data), silent = TRUE)
    
    if (!inherits(final_fit, "try-error")) {
      final_pval <- summary(final_fit)$coefficients[5]  # p-value
      
      if (!is.na(final_pval) && final_pval < alpha_final) {
        reject_at_final <- reject_at_final + 1
      }
    }
  }
  
  # Calculate overall power
  overall_power <- (reject_at_interim + reject_at_final) / n_trials
  
  return(list(
    overall_power = overall_power,
    reject_at_interim = reject_at_interim / n_trials,
    reject_at_final = reject_at_final / n_trials
  ))
}

# Run power simulation
set.seed(123)  # For reproducibility
power_results <- simulate_trial_power(
  n_trials = 500,  # Number of simulated trials
  n_patients = sample_size_gs,
  hr = 0.70,
  interim_fraction = 0.5,  # 50% of events at interim
  alpha_interim = gs_design$upper$bound[1],  # Critical value at interim
  alpha_final = gs_design$upper$bound[2]     # Critical value at final
)

print("Power simulation results:")
print(paste("Overall power:", round(power_results$overall_power, 3)))
print(paste("Probability of stopping at interim:", round(power_results$reject_at_interim, 3)))
print(paste("Probability of rejecting at final analysis:", round(power_results$reject_at_final, 3)))

#========== PART 5: Visualization ==========
# Plot the group sequential boundaries
plot(gs_design, xlab = "Information Fraction", ylab = "Z-score")
title("O'Brien-Fleming Boundaries for RELAY Trial")
