# Warfarin Compartmental Model Analysis using nlmixr2 data

# Load required packages
library(nlmixr2)
library(minpack.lm)
library(ggplot2)
library(dplyr)

# Load warfarin data from nlmixr2
data(warfarin)

# Filter to get only concentration data (dvid == "cp")
warfarin_conc <- warfarin %>%
  filter(dvid == "cp" & evid == 0)  # evid == 0 indicates observation

# Check the data structure
head(warfarin_conc)

# Extract data for one subject (e.g., Subject 1)
subject1 <- warfarin_conc %>%
  filter(id == 1)

# Visual Assessment
# Plot on linear scale
ggplot(subject1, aes(x = time, y = dv)) +
  geom_point(size = 2) +
  geom_line(color = "blue") +
  labs(x = "Time (hours)", y = "Warfarin Concentration (mg/L)",
       title = "Warfarin Concentration-Time Profile (Linear Scale)") +
  theme_minimal()

# Plot on semi-log scale
ggplot(subject1, aes(x = time, y = dv)) +
  geom_point(size = 2) +
  geom_line(color = "blue") +
  scale_y_log10() +
  labs(x = "Time (hours)", y = "log(Concentration) (mg/L)",
       title = "Warfarin Concentration-Time Profile (Semi-log Scale)") +
  theme_minimal()

# Define compartmental models
# One-compartment model with first-order absorption
one_comp_model <- function(time, dose = 100, ka, ke, V) {
  conc <- (dose/V) * (ka/(ka-ke)) * (exp(-ke*time) - exp(-ka*time))
  conc[time == 0] <- 0
  return(conc)
}

# Two-compartment model with first-order absorption
two_comp_model <- function(time, dose = 100, ka, k10, k12, k21, V1) {
  # Hybrid rate constants
  alpha <- 0.5 * ((k10 + k12 + k21) + sqrt((k10 + k12 + k21)^2 - 4*k10*k21))
  beta <- 0.5 * ((k10 + k12 + k21) - sqrt((k10 + k12 + k21)^2 - 4*k10*k21))
  
  # Coefficients
  A <- (dose/V1) * ka * (k21 - alpha) / ((ka - alpha) * (beta - alpha))
  B <- (dose/V1) * ka * (k21 - beta) / ((ka - beta) * (alpha - beta))
  C <- (dose/V1) * ka * (k21 - ka) / ((alpha - ka) * (beta - ka))
  
  conc <- A*exp(-alpha*time) + B*exp(-beta*time) + C*exp(-ka*time)
  conc[time == 0] <- 0
  return(conc)
}

# Get the dose for this subject (first amt value)
dose <- warfarin %>%
  filter(id == 1 & evid == 1) %>%  # evid == 1 indicates dosing event
  pull(amt)

print(paste("Dose for subject 1:", dose[1], "mg"))

# Fit one-compartment model
try({
  fit_one_comp <- nlsLM(dv ~ one_comp_model(time, dose[1], ka, ke, V),
                        data = subject1,
                        start = list(ka = 1, ke = 0.05, V = 8),
                        control = nls.lm.control(maxiter = 1000))
  
  summary(fit_one_comp)
  params_one <- coef(fit_one_comp)
  print("One-compartment parameters:")
  print(params_one)
}, silent = FALSE)

# Fit two-compartment model
try({
  fit_two_comp <- nlsLM(dv ~ two_comp_model(time, dose[1], ka, k10, k12, k21, V1),
                        data = subject1,
                        start = list(ka = 1, k10 = 0.05, k12 = 0.3, k21 = 0.2, V1 = 4),
                        control = nls.lm.control(maxiter = 1000))
  
  summary(fit_two_comp)
  params_two <- coef(fit_two_comp)
  print("Two-compartment parameters:")
  print(params_two)
}, silent = FALSE)

# Model Comparison
# Generate predictions
time_seq <- seq(0, max(subject1$time), by = 0.1)
if (exists("params_one")) {
  pred_one <- one_comp_model(time_seq, dose[1],
                             ka = params_one["ka"], 
                             ke = params_one["ke"], 
                             V = params_one["V"])
}

if (exists("params_two")) {
  pred_two <- two_comp_model(time_seq, dose[1],
                             ka = params_two["ka"], 
                             k10 = params_two["k10"], 
                             k12 = params_two["k12"], 
                             k21 = params_two["k21"], 
                             V1 = params_two["V1"])
}

# Plot fitted models
plot_data <- data.frame(time = time_seq)
if (exists("pred_one")) plot_data$one_comp <- pred_one
if (exists("pred_two")) plot_data$two_comp <- pred_two

p <- ggplot(subject1, aes(x = time, y = dv)) +
  geom_point(size = 2) +
  scale_y_log10() +
  labs(x = "Time (hours)", y = "log(Concentration) (mg/L)",
       title = "Model Fits Comparison (Semi-log Scale)")

if (exists("pred_one")) {
  p <- p + geom_line(data = plot_data, aes(x = time, y = one_comp), 
                     color = "blue", linewidth = 1)
}
if (exists("pred_two")) {
  p <- p + geom_line(data = plot_data, aes(x = time, y = two_comp), 
                     color = "red", linewidth = 1)
}

p + theme_minimal()

# Compare AIC
if (exists("fit_one_comp") && exists("fit_two_comp")) {
  aic_one <- AIC(fit_one_comp)
  aic_two <- AIC(fit_two_comp)
  
  cat("\nModel Comparison:\n")
  cat("AIC for 1-compartment model:", round(aic_one, 3), "\n")
  cat("AIC for 2-compartment model:", round(aic_two, 3), "\n")
  cat("Lower AIC indicates better model fit\n")
}

# Residual Analysis
if (exists("fit_one_comp")) {
  residuals_one <- residuals(fit_one_comp)
}
if (exists("fit_two_comp")) {
  residuals_two <- residuals(fit_two_comp)
}

# Plot residuals
if (exists("residuals_one") && exists("residuals_two")) {
  par(mfrow = c(2, 2))
  
  # Residuals vs Time
  plot(subject1$time, residuals_one, 
       type = "p", pch = 16, cex = 1.5,
       xlab = "Time (hours)", ylab = "Residuals",
       main = "1-Compartment: Residuals vs Time")
  abline(h = 0, col = "red", lty = 2)
  
  plot(subject1$time, residuals_two, 
       type = "p", pch = 16, cex = 1.5,
       xlab = "Time (hours)", ylab = "Residuals",
       main = "2-Compartment: Residuals vs Time")
  abline(h = 0, col = "red", lty = 2)
  
  # Residuals vs Fitted Values
  plot(fitted(fit_one_comp), residuals_one, 
       type = "p", pch = 16, cex = 1.5,
       xlab = "Fitted Values", ylab = "Residuals",
       main = "1-Compartment: Residuals vs Fitted")
  abline(h = 0, col = "red", lty = 2)
  
  plot(fitted(fit_two_comp), residuals_two, 
       type = "p", pch = 16, cex = 1.5,
       xlab = "Fitted Values", ylab = "Residuals",
       main = "2-Compartment: Residuals vs Fitted")
  abline(h = 0, col = "red", lty = 2)
  
  par(mfrow = c(1, 1))
}

# Visual assessment for bi-exponential behavior
# Look at early vs late phases
log_conc <- log(subject1$dv[subject1$dv > 0])
valid_times <- subject1$time[subject1$dv > 0]

# Fit linear models to early and late phases
early_data <- subject1 %>% filter(time <= 10 & dv > 0)
late_data <- subject1 %>% filter(time > 10 & dv > 0)

if (nrow(early_data) > 1 && nrow(late_data) > 1) {
  early_fit <- lm(log(dv) ~ time, data = early_data)
  late_fit <- lm(log(dv) ~ time, data = late_data)
  
  # Plot
  ggplot(subject1 %>% filter(dv > 0), aes(x = time, y = log(dv))) +
    geom_point(size = 2) +
    geom_smooth(data = early_data, method = "lm", se = FALSE, color = "blue") +
    geom_smooth(data = late_data, method = "lm", se = FALSE, color = "red") +
    labs(x = "Time (hours)", y = "log(Concentration)",
         title = "Visual Assessment of Bi-exponential Decay") +
    annotate("text", x = 5, y = max(log(subject1$dv)), 
             label = paste("Early phase slope:", round(coef(early_fit)[2], 4))) +
    annotate("text", x = 15, y = max(log(subject1$dv)) - 0.5, 
             label = paste("Late phase slope:", round(coef(late_fit)[2], 4))) +
    theme_minimal()
  
  cat("\nPhase Analysis:\n")
  cat("Early phase slope:", round(coef(early_fit)[2], 4), "\n")
  cat("Late phase slope:", round(coef(late_fit)[2], 4), "\n")
}

# Population analysis across multiple subjects
population_analysis <- function(data, n_subjects = 5) {
  results <- data.frame(Subject = numeric(), Model = character(), AIC = numeric())
  
  for (subj in 1:n_subjects) {
    subj_data <- data %>%
      filter(id == subj & dvid == "cp" & evid == 0)
    
    # Get dose for this subject
    dose_subj <- data %>%
      filter(id == subj & evid == 1) %>%
      pull(amt)
    
    if (length(dose_subj) > 0 && nrow(subj_data) > 0) {
      tryCatch({
        # Fit one-compartment
        fit_one <- nlsLM(dv ~ one_comp_model(time, dose_subj[1], ka, ke, V),
                         data = subj_data,
                         start = list(ka = 1, ke = 0.05, V = 8))
        
        # Fit two-compartment  
        fit_two <- nlsLM(dv ~ two_comp_model(time, dose_subj[1], ka, k10, k12, k21, V1),
                         data = subj_data,
                         start = list(ka = 1, k10 = 0.05, k12 = 0.3, k21 = 0.2, V1 = 4))
        
        results <- rbind(results,
                         data.frame(Subject = subj, Model = "1-compartment", AIC = AIC(fit_one)),
                         data.frame(Subject = subj, Model = "2-compartment", AIC = AIC(fit_two)))
      }, error = function(e) {
        cat("Error for subject", subj, ":", e$message, "\n")
      })
    }
  }
  
  return(results)
}

# Analyze multiple subjects
pop_results <- population_analysis(warfarin, n_subjects = 5)
print(pop_results)

# Determine best model per subject
if (nrow(pop_results) > 0) {
  best_models <- pop_results %>%
    group_by(Subject) %>%
    slice_min(AIC, n = 1) %>%
    ungroup()
  
  print("Best model for each subject:")
  print(best_models)
  
  # Summary statistics
  model_summary <- table(best_models$Model)
  print("\nSummary of best models:")
  print(model_summary)
  
  # Conclusion
  cat("\nConclusion:\n")
  if (length(model_summary) > 0 && "2-compartment" %in% names(model_summary) && 
      "1-compartment" %in% names(model_summary)) {
    if (model_summary["2-compartment"] > model_summary["1-compartment"]) {
      cat("Two-compartment model provides better fits for warfarin pharmacokinetics.\n")
      cat("This is expected due to warfarin's:\n")
      cat("- Substantial protein binding\n")
      cat("- Extensive tissue distribution\n")
      cat("- Complex pharmacokinetic profile\n")
    } else {
      cat("Analysis suggests considering one-compartment model.\n")
    }
  }
}

# Check AUC consistency
calculate_auc <- function(time, conc) {
  # Remove any zero or negative concentrations
  valid_idx <- conc > 0
  time <- time[valid_idx]
  conc <- conc[valid_idx]
  
  # Sort by time
  sort_idx <- order(time)
  time <- time[sort_idx]
  conc <- conc[sort_idx]
  
  # Calculate AUC using trapezoidal rule
  auc <- 0
  for (i in 1:(length(time)-1)) {
    auc <- auc + (time[i+1] - time[i]) * (conc[i] + conc[i+1]) / 2
  }
  
  return(auc)
}

# Calculate AUC for different models
auc_data <- calculate_auc(subject1$time, subject1$dv)
if (exists("pred_one")) {
  auc_one <- calculate_auc(time_seq, pred_one)
}
if (exists("pred_two")) {
  auc_two <- calculate_auc(time_seq, pred_two)
}

cat("\nAUC Comparison:\n")
cat("Data AUC:", round(auc_data, 3), "\n")
if (exists("auc_one")) cat("1-compartment AUC:", round(auc_one, 3), "\n")
if (exists("auc_two")) cat("2-compartment AUC:", round(auc_two, 3), "\n")

