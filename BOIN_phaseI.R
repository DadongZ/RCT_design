# Load required libraries
library(BOIN)  # For BOIN design functions
library(Iso)   # For isotonic regression

#---------------------------------------------
# Example data from a completed Phase I trial
#---------------------------------------------
# Dose levels tested
dose_levels <- c(10, 20, 30, 50, 80, 100)  # mg

# Number of patients treated at each dose level
n_patients <- c(3, 3, 6, 9, 6, 3)

# Number of DLTs (dose-limiting toxicities) observed at each dose
n_toxicities <- c(0, 0, 1, 2, 3, 2)

# Target toxicity rate
target <- 0.3

#---------------------------------------------
# Step 1: Calculate raw toxicity rates
#---------------------------------------------
raw_tox_rates <- n_toxicities / n_patients
print("Raw toxicity rates by dose level:")
print(data.frame(Dose = dose_levels, 
                 Patients = n_patients, 
                 Toxicities = n_toxicities,
                 Rate = round(raw_tox_rates, 2)))

#---------------------------------------------
# Step 2: Apply isotonic regression
#---------------------------------------------
# Isotonic regression ensures monotonicity of dose-toxicity curve
wt <- n_patients  # Weights are the number of patients at each dose
iso_tox_rates <- Iso::pava(raw_tox_rates, wt)
print("Isotonic regression adjusted toxicity rates:")
print(round(iso_tox_rates, 3))

#---------------------------------------------
# Step 3: Compute posterior probability of each dose being the MTD
#---------------------------------------------
# Prior parameters for Beta distribution (usually minimally informative)
alpha0 <- 1
beta0 <- 1

# Calculate posterior parameters for each dose
alpha_post <- alpha0 + n_toxicities
beta_post <- beta0 + n_patients - n_toxicities

# Function to calculate probability that toxicity rate is in target +/- epsilon range
prob_in_target_range <- function(alpha, beta, target, epsilon = 0.05) {
  pbeta(target + epsilon, alpha, beta) - pbeta(target - epsilon, alpha, beta)
}

# Calculate probability each dose is in acceptable toxicity range
mtd_probs <- sapply(1:length(dose_levels), function(i) {
  prob_in_target_range(alpha_post[i], beta_post[i], target)
})

# Adjust probabilities based on isotonic estimates
for (i in 1:length(dose_levels)) {
  # Downweight doses with isotonic estimate far from target
  dist_from_target <- abs(iso_tox_rates[i] - target)
  mtd_probs[i] <- mtd_probs[i] * (1 - min(dist_from_target/target, 0.5))
}

# Normalize probabilities
mtd_probs <- mtd_probs / sum(mtd_probs)

#---------------------------------------------
# Step 4: Select MTD based on posterior probabilities
#---------------------------------------------
mtd_results <- data.frame(
  Dose = dose_levels,
  IsotonicRate = round(iso_tox_rates, 3),
  MTD_Probability = round(mtd_probs, 3)
)

print("MTD probability for each dose level:")
print(mtd_results)

# Find dose with highest probability of being MTD
selected_mtd_index <- which.max(mtd_probs)
selected_mtd <- dose_levels[selected_mtd_index]

cat("\nSelected MTD:", selected_mtd, "mg with estimated DLT rate of", 
    round(iso_tox_rates[selected_mtd_index], 3), "\n")

#---------------------------------------------
# Step 5: Compute 95% credible interval for toxicity rate at MTD
#---------------------------------------------
ci_lower <- qbeta(0.025, alpha_post[selected_mtd_index], beta_post[selected_mtd_index])
ci_upper <- qbeta(0.975, alpha_post[selected_mtd_index], beta_post[selected_mtd_index])

cat("95% credible interval for toxicity rate at MTD:", 
    round(ci_lower, 3), "to", round(ci_upper, 3), "\n")

#---------------------------------------------
# Step 6: Visualize the results
#---------------------------------------------
# Create plot of dose-toxicity curve
plot(dose_levels, raw_tox_rates, type = "p", pch = 16, 
     xlab = "Dose (mg)", ylab = "DLT Rate",
     main = "Dose-Toxicity Relationship",
     ylim = c(0, 1))

# Add isotonic regression line
lines(dose_levels, iso_tox_rates, col = "blue", lwd = 2)

# Add horizontal line for target toxicity
abline(h = target, col = "red", lty = 2)

# Add confidence intervals
for (i in 1:length(dose_levels)) {
  ci_l <- qbeta(0.025, alpha_post[i], beta_post[i])
  ci_u <- qbeta(0.975, alpha_post[i], beta_post[i])
  arrows(dose_levels[i], ci_l, dose_levels[i], ci_u, 
         code = 3, angle = 90, length = 0.05)
}

# Highlight the MTD
points(selected_mtd, iso_tox_rates[selected_mtd_index], 
       col = "green", pch = 16, cex = 2)

# Add legend
legend("topleft", 
       legend = c("Observed rates", "Isotonic estimate", "Target toxicity", "Selected MTD"),
       pch = c(16, NA, NA, 16), 
       lty = c(NA, 1, 2, NA),
       col = c("black", "blue", "red", "green"),
       pt.cex = c(1, 1, 1, 2),
       lwd = c(1, 2, 1, 1))
