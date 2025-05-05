# Improved function to fit model for a single subject with better error handling
fit_subject <- function(subj_id, data, doses) {
  # Filter data for this subject
  subj_data <- data %>% filter(id == subj_id)
  
  # Get dose for this subject
  dose <<- doses %>% filter(id == subj_id) %>% pull(dose)
  
  # Skip if not enough data points
  if(nrow(subj_data) < 4) {
    message("Not enough data points for subject ", subj_id)
    return(NULL)
  }
  
  # Try multiple initial parameter sets to improve convergence
  initial_params_list <- list(
    list(ka = 0.1, ke = 0.01, V = 10),  # Default
    list(ka = 0.5, ke = 0.05, V = 5),   # Faster absorption/elimination
    list(ka = 0.05, ke = 0.005, V = 20) # Slower absorption/elimination
  )
  
  for (init_params in initial_params_list) {
    tryCatch({
      # Try with different algorithms
      for (algo in c("port", "Nelder-Mead")) {
        fit <- NULL
        if (algo == "port") {
          # Port algorithm with bounds
          fit <- try(nls(conc ~ onecomp_model(time, ka, ke, V), 
                         data = subj_data,
                         start = init_params,
                         algorithm = "port",
                         lower = c(ka = 0.001, ke = 0.001, V = 0.1),
                         upper = c(ka = 2, ke = 0.2, V = 100),
                         control = nls.control(maxiter = 200, warnOnly = TRUE)),
                     silent = TRUE)
        } else {
          # Nelder-Mead without bounds
          fit <- try(nls(conc ~ onecomp_model(time, ka, ke, V), 
                         data = subj_data,
                         start = init_params,
                         algorithm = "default",
                         control = nls.control(maxiter = 200, warnOnly = TRUE)),
                     silent = TRUE)
        }
        
        # If fit worked, process results
        if (!inherits(fit, "try-error") && !is.null(fit)) {
          # Extract parameters
          params <- coef(fit)
          ka <- params["ka"]
          ke <- params["ke"]
          V <- params["V"]
          
          # Calculate derived parameters
          half_life <- log(2) / ke
          AUC <- dose / (V * ke)
          
          # Try to calculate Cmax and Tmax, but handle potential errors
          Cmax_time <- try(log(ka/ke) / (ka - ke), silent = TRUE)
          if (inherits(Cmax_time, "try-error") || is.nan(Cmax_time) || Cmax_time < 0) {
            # If calculation fails, estimate from the data
            Cmax_time <- subj_data$time[which.max(subj_data$conc)]
          }
          
          Cmax <- try(onecomp_model(Cmax_time, ka, ke, V), silent = TRUE)
          if (inherits(Cmax, "try-error") || is.nan(Cmax) || is.na(Cmax)) {
            # If calculation fails, use the observed maximum
            Cmax <- max(subj_data$conc)
          }
          
          # Calculate goodness of fit metrics
          subj_data$pred <- predict(fit)
          subj_data$res <- subj_data$conc - subj_data$pred
          rmse <- sqrt(mean(subj_data$res^2))
          r_squared <- 1 - sum(subj_data$res^2) / sum((subj_data$conc - mean(subj_data$conc))^2)
          
          # Return results as a list
          message("Successfully fit subject ", subj_id, " with algorithm ", algo, " and initial params ka=", init_params$ka)
          return(list(
            id = subj_id,
            fit = fit,
            params = data.frame(
              id = subj_id,
              ka = ka,
              ke = ke,
              V = V,
              half_life = half_life,
              AUC = AUC,
              Tmax = Cmax_time,
              Cmax = Cmax,
              CL = V * ke,
              rmse = rmse,
              r_squared = r_squared
            ),
            data = subj_data
          ))
        }
      }
    }, error = function(e) {
      # Continue to next initial parameter set
    })
  }
  
  # If we get here, all attempts failed
  message("Error fitting subject ", subj_id, ": All methods failed to converge")
  
  # Return a simple estimate based on the data (as fallback)
  if (nrow(subj_data) >= 4) {
    # Estimate ke from terminal phase (last 3 points)
    terminal_data <- tail(subj_data %>% arrange(time), 3)
    if (nrow(terminal_data) >= 2) {
      lm_fit <- try(lm(log(conc) ~ time, data = terminal_data), silent = TRUE)
      if (!inherits(lm_fit, "try-error")) {
        ke_est <- -coef(lm_fit)[2]
        if (ke_est > 0) {
          # Rough estimation of V based on extrapolation to t=0
          intercept <- coef(lm_fit)[1]
          V_est <- dose / exp(intercept)
          
          # Rough estimation of ka (assume 5x faster than elimination)
          ka_est <- 5 * ke_est
          
          message("Using rough estimates for subject ", subj_id)
          
          # Calculate predictions using these estimates
          subj_data$pred <- onecomp_model(subj_data$time, ka_est, ke_est, V_est)
          subj_data$res <- subj_data$conc - subj_data$pred
          
          return(list(
            id = subj_id,
            fit = NULL,  # No actual fit object
            params = data.frame(
              id = subj_id,
              ka = ka_est,
              ke = ke_est,
              V = V_est,
              half_life = log(2) / ke_est,
              AUC = dose / (V_est * ke_est),
              Tmax = log(ka_est/ke_est) / (ka_est - ke_est),
              Cmax = max(subj_data$conc),
              CL = V_est * ke_est,
              rmse = sqrt(mean(subj_data$res^2)),
              r_squared = NA  # Can't calculate accurate R² without proper fit
            ),
            data = subj_data,
            estimated = TRUE  # Flag that these are estimates, not fitted values
          ))
        }
      }
    }
  }
  
  return(NULL)  # If all else fails
}

# Improved function to generate PK predictions at specific time points
generate_pk_predictions <- function(id, fit, doses, times) {
  # Handle case where fit might be problematic
  tryCatch({
    # Get parameters
    params <- coef(fit)
    ka <- params["ka"]
    ke <- params["ke"]
    V <- params["V"]
    
    # Get dose
    dose <- doses %>% filter(id == id) %>% pull(dose)
    
    # Check if parameters make sense
    if (ka <= 0 || ke <= 0 || V <= 0 || is.na(ka) || is.na(ke) || is.na(V)) {
      warning("Invalid parameters for subject ", id)
      return(NULL)
    }
    
    # Calculate concentrations
    conc_pred <- (dose * ka / (V * (ka - ke))) * (exp(-ke * times) - exp(-ka * times))
    
    # Check for valid predictions
    if (any(is.na(conc_pred)) || any(is.infinite(conc_pred))) {
      warning("Invalid predictions for subject ", id)
      return(NULL)
    }
    
    # Return as data frame
    return(data.frame(
      id = rep(id, length(times)),
      time = times,
      pred_conc = conc_pred
    ))
  }, error = function(e) {
    warning("Error in generate_pk_predictions for subject ", id, ": ", e$message)
    return(NULL)
  })
}

# Indirect response model for each subject
# This is a simplified implementation using the predicted concentrations

# Function to simulate the indirect response for a given set of parameters
simulate_indirect_response <- function(conc, time, kin, kout, ic50, gamma = 1, baseline = 100) {
  # Initialize PCA vector
  pca <- numeric(length(time))
  pca[1] <- baseline
  
  # Time steps
  dt <- diff(c(0, time))
  
  # Simulate the response
  for(i in 2:length(time)) {
    # Inhibition of input rate
    effect <- 1 - (conc[i-1]^gamma) / (ic50^gamma + conc[i-1]^gamma)
    
    # Update PCA using Euler method
    dpca <- (kin * effect - kout * pca[i-1]) * dt[i]
    pca[i] <- pca[i-1] + dpca
  }
  
  return(pca)
}

# Function to fit the indirect response model for a subject
fit_indirect_response <- function(subject_id, pkpd_data) {
  # Filter data for this subject
  subj_data <- pkpd_data %>% filter(id == subject_id)
  
  # Skip if not enough data points
  if(nrow(subj_data) < 4) {
    message("Not enough PK/PD data points for subject ", subject_id)
    return(NULL)
  }
  
  # Sort by time
  subj_data <- subj_data %>% arrange(time)
  
  # Define objective function (sum of squared residuals)
  objective <- function(params) {
    kin <- params[1]
    kout <- params[2]
    ic50 <- params[3]
    
    # Simulate PCA
    pred_pca <- simulate_indirect_response(
      conc = subj_data$pred_conc,
      time = subj_data$time,
      kin = kin,
      kout = kout,
      ic50 = ic50
    )
    
    # Calculate sum of squared residuals
    ssr <- sum((subj_data$pca - pred_pca)^2)
    return(ssr)
  }
  
  # Initial parameter values
  init_params <- c(kin = 5, kout = 0.05, ic50 = 1)
  
  # Fit the model using optim()
  tryCatch({
    fit <- optim(
      par = init_params,
      fn = objective,
      method = "L-BFGS-B",
      lower = c(0.01, 0.001, 0.01),
      upper = c(100, 1, 100)
    )
    
    # Extract parameters
    params <- fit$par
    kin <- params[1]
    kout <- params[2]
    ic50 <- params[3]
    
    # Calculate derived parameters
    half_life_pd <- log(2) / kout
    
    # Calculate predictions
    pred_pca <- simulate_indirect_response(
      conc = subj_data$pred_conc,
      time = subj_data$time,
      kin = kin,
      kout = kout,
      ic50 = ic50
    )
    
    # Calculate goodness of fit metrics
    subj_data$pred_pca <- pred_pca
    subj_data$res_pca <- subj_data$pca - pred_pca
    rmse <- sqrt(mean(subj_data$res_pca^2))
    r_squared <- 1 - sum(subj_data$res_pca^2) / sum((subj_data$pca - mean(subj_data$pca))^2)
    
    # Return results
    return(list(
      id = subject_id,
      params = data.frame(
        id = subject_id,
        kin = kin,
        kout = kout,
        ic50 = ic50,
        half_life_pd = half_life_pd,
        rmse = rmse,
        r_squared = r_squared
      ),
      data = subj_data
    ))
  }, error = function(e) {
    message("Error fitting PD model for subject ", subject_id, ": ", e$message)
    return(NULL)
  })
}

# Define the one-compartment model function with first-order absorption
onecomp_model <- function(t, ka, ke, V) {
  # Using the analytical solution to the one-compartment model
  (dose * ka / (V * (ka - ke))) * (exp(-ke * t) - exp(-ka * t))
}

simulate_pkpd <- function(dose, pk_params, pd_params, max_time = 144) {
  # Extract parameters
  ka <- pk_params$ka
  ke <- pk_params$ke
  V <- pk_params$V
  
  kin <- pd_params$kin
  kout <- pd_params$kout
  ic50 <- pd_params$ic50
  
  # Generate time points
  time <- seq(0, max_time, by = 1)
  
  # Calculate concentrations
  conc <- (dose * ka / (V * (ka - ke))) * (exp(-ke * time) - exp(-ka * time))
  
  # Simulate PD response
  pca <- simulate_indirect_response(
    conc = conc,
    time = time,
    kin = kin,
    kout = kout,
    ic50 = ic50
  )
  
  # Return as data frame
  data.frame(
    time = time,
    dose = dose,
    conc = conc,
    pca = pca
  )
}

# Function to simulate multiple dosing
simulate_multiple_dosing <- function(total_dose, interval, duration = 144, num_doses = 5) {
  # Dose per administration
  dose_per_admin <- total_dose / (24/interval)
  
  # Generate empty data frame for results
  results <- data.frame(
    time = numeric(0),
    conc = numeric(0),
    pca = numeric(0)
  )
  
  # Simulate each dose separately
  for (i in 0:(num_doses-1)) {
    # Calculate dose time
    dose_time <- i * interval
    
    # Skip if past duration
    if (dose_time > duration) break
    
    # Generate time points for this dose
    time_points <- seq(dose_time, duration, by = 1)
    
    # Calculate time since this dose
    time_since_dose <- time_points - dose_time
    
    # Calculate concentrations for this dose
    this_conc <- (dose_per_admin * mean_pk_params$ka / 
                    (mean_pk_params$V * (mean_pk_params$ka - mean_pk_params$ke))) * 
      (exp(-mean_pk_params$ke * time_since_dose) - 
         exp(-mean_pk_params$ka * time_since_dose))
    
    # Add to total
    if (i == 0) {
      # For first dose, initialize with full simulation
      conc_total <- this_conc
      
      # Simulate PD response
      pca <- simulate_indirect_response(
        conc = conc_total,
        time = time_since_dose,
        kin = mean_pd_params$kin,
        kout = mean_pd_params$kout,
        ic50 = mean_pd_params$ic50
      )
      
      # Store results
      results <- rbind(results, data.frame(
        time = time_points,
        conc = conc_total,
        pca = pca
      ))
    } else {
      # For subsequent doses, only calculate the contribution to the current results
      for (j in 1:length(time_points)) {
        # Find matching index in results
        idx <- which(results$time == time_points[j])
        
        # Add contribution if found
        if (length(idx) > 0) {
          results$conc[idx] <- results$conc[idx] + this_conc[j]
        }
      }
      
      # Re-simulate PD with updated concentrations
      results <- results %>% arrange(time)
      
      # Simulate PD response
      pca <- simulate_indirect_response(
        conc = results$conc,
        time = results$time,
        kin = mean_pd_params$kin,
        kout = mean_pd_params$kout,
        ic50 = mean_pd_params$ic50
      )
      
      # Update PCA
      results$pca <- pca
    }
  }
  
  # Add regimen info
  results$regimen <- paste0(total_dose, "mg q", interval, "h")
  results$total_dose <- total_dose
  results$interval <- interval
  
  return(results)
}
