# Load required packages
library(nlme)      # For nonlinear mixed effects models
library(ggplot2)   # For plotting
library(dplyr)     # For data manipulation
library(PKPDmodels) # For PK/PD modeling functions
library(stats)
library(graphics)

coplot(conc ~ Time | Subject, data = Theoph, show.given = FALSE)
Theoph.4 <- subset(Theoph, Subject == 4)
fm1 <- nls(conc ~ SSfol(Dose, Time, lKe, lKa, lCl),
           data = Theoph.4)
plot(conc ~ Time, data = Theoph.4,
     xlab = "Time since drug administration (hr)",
     ylab = "Theophylline concentration (mg/L)",
     main = "Observed concentrations and fitted model",
     sub  = "Theophylline data - Subject 4 only",
     las = 1, col = 4)
#nls: Determine the nonlinear (weighted) least-squares estimates of the parameters of a nonlinear model.
#One-compartment first-order absorption model
#是一种用于描述药物在体内的吸收和消除过程的数学模型。
#该模型假设药物在体内只有一个室（compartment），药物从肠道进入体内后，以一级速率
#（first-order rate）进入血液，随后以相同的速率从血液中消除。
#这种模型在药物动力学研究中被广泛应用，尤其是在口服药物的研究中

# lKe = -2.4365: This is the log of the elimination rate constant (Ke).
# 
# Converting to the original scale: Ke = exp(-2.4365) = 0.0874 hr⁻¹
# This represents the first-order rate at which the drug is eliminated from the body
# The half-life can be calculated as: t₁/₂ = ln(2)/Ke = 0.693/0.0874 = 7.93 hours
# 
# lKa = 0.1583: This is the log of the absorption rate constant (Ka).
# 
# Converting to the original scale: Ka = exp(0.1583) = 1.1716 hr⁻¹
# This represents how quickly the drug is absorbed from the gut into the bloodstream
# Absorption half-life = 0.693/1.1716 = 0.59 hours (about 35 minutes)
# 
# lCl = -3.2861: This is the log of the apparent clearance (Cl/F).
# 
# Converting to the original scale: Cl/F = exp(-3.2861) = 0.0375 L/hr/kg
# This represents the volume of blood cleared of drug per unit time, adjusted for bioavailability
# For a 70 kg person, this would be about 2.63 L/hr total clearance

# Statistical Significance
# Looking at the p-values:
#   
# lKe (elimination rate): p = 4.77e-06 (highly significant)
# lKa (absorption rate): p = 0.51 (not significant)
# lCl (clearance): p = 1.51e-08 (highly significant)
# 
# The non-significance of Ka suggests variability in the absorption process for 
# this subject, which is common in PK studies. This could be due to various 
# factors affecting drug absorption, such as food effects or individual variability.
