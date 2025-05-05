---
title: "Statistical Analysis Plan for Phase I/II Study of INH006 + Bevacizumab for First-Line Maintenance Therapy in HRD-Positive HGSOC"
format: html
editor: visual
---

# STATISTICAL ANALYSIS PLAN

**Protocol Title:** A Phase I/II Study of INH006 (PARP Inhibitor) in Combination with Bevacizumab for First-Line Maintenance Therapy in HRD-Positive High-Grade Serous Ovarian Cancer (HGSOC) Following Response from Chemotherapy and Bevacizumab Treatment

**Protocol Number:** INH006-101

**Version:** 1.0

**Date:** May 3, 2025

## 1. INTRODUCTION

### 1.1 Study Background

INH006 is a novel poly(ADP-ribose) polymerase (PARP) inhibitor that has completed pre-clinical development and received Investigational New Drug (IND) approval. This study will evaluate INH006 in combination with bevacizumab as first-line maintenance therapy in patients with homologous recombination deficiency (HRD)-positive high-grade serous ovarian cancer (HGSOC) who have achieved a response following platinum-based chemotherapy and bevacizumab treatment.

The rationale for this combination is based on several observations:

1. PARP inhibitors have demonstrated significant efficacy in HRD-positive ovarian cancer, particularly in tumors with BRCA1/BRCA2 mutations
2. The combination of olaparib and bevacizumab has shown synergistic activity and improved progression-free survival (PFS) in HRD-positive HGSOC (PAOLA-1 trial)
3. Bevacizumab may induce tumor hypoxia, potentially enhancing HRD and increasing sensitivity to PARP inhibition
4. The combination targets complementary pathways critical for cancer cell survival

### 1.2 Study Objectives

#### 1.2.1 Primary Objectives

**Phase I:**
- To determine the maximum tolerated dose (MTD) and/or optimal biological dose (OBD) of INH006 when administered in combination with bevacizumab

**Phase II:**
- To evaluate the preliminary efficacy of INH006 in combination with bevacizumab as measured by progression-free survival (PFS) at 24 months

#### 1.2.2 Secondary Objectives

- To characterize the safety and tolerability profile of INH006 in combination with bevacizumab
- To evaluate objective response rate (ORR) and duration of response (DOR)
- To assess overall survival (OS)
- To determine pharmacokinetic (PK) parameters of INH006 when administered in combination with bevacizumab
- To evaluate pharmacodynamic (PD) biomarkers and establish exposure-response relationships
- To assess patient-reported outcomes (PROs)

### 1.3 Study Design

This is a Phase I/II, open-label, dose-escalation and expansion study of INH006 in combination with bevacizumab in patients with HRD-positive HGSOC who have achieved a complete or partial response following first-line platinum-based chemotherapy plus bevacizumab.

**Phase I (Dose Escalation):**
- Dose escalation will follow a modified 3+3 design
- Sequential cohorts of 3-6 patients will be treated with escalating doses of INH006 in combination with a fixed standard dose of bevacizumab (15 mg/kg IV every 3 weeks)
- INH006 will be administered orally twice daily in 28-day cycles
- Starting dose will be 100 mg BID with planned escalation to 200 mg BID, 300 mg BID, and 400 mg BID
- Dose-limiting toxicities (DLTs) will be evaluated during the first cycle (28 days)
- PK and PD assessments will be conducted to determine the OBD

**Phase II (Dose Expansion):**
- Approximately 60 patients will be enrolled at the recommended Phase II dose (RP2D) determined in Phase I
- Treatment will continue until disease progression, unacceptable toxicity, or a maximum of 24 months
- Tumor assessments will be performed every 12 weeks according to RECIST v1.1 criteria

## 2. STATISTICAL METHODS

### 2.1 Sample Size Determination

#### 2.1.1 Phase I

The sample size for the Phase I portion is determined by the modified 3+3 dose-escalation design. A minimum of 3 and a maximum of 24 patients are expected to be enrolled in this portion of the study, depending on the number of dose levels explored and the observed toxicity rates.

#### 2.1.2 Phase II

For the Phase II portion, the sample size of 60 patients is based on the following assumptions:
- The 24-month PFS rate with standard of care (bevacizumab alone) in HRD-positive patients is approximately 25%
- A clinically meaningful improvement would be an increase in the 24-month PFS rate to 45% with INH006 plus bevacizumab
- Two-sided significance level (α) of 0.05
- Power of 80%
- Dropout rate of approximately 10%

This sample size will provide sufficient precision to estimate the 24-month PFS rate with a 95% confidence interval width of approximately ±12.5 percentage points.

### 2.2 Analysis Populations

#### 2.2.1 Safety Population

The Safety Population will include all patients who receive at least one dose of study treatment. This population will be used for all safety analyses.

#### 2.2.2 Dose-Limiting Toxicity (DLT) Evaluable Population

The DLT Evaluable Population will include all patients in the Phase I portion who receive at least 75% of the planned doses of INH006 during the DLT evaluation period (Cycle 1) or who experience a DLT. This population will be used for the determination of the MTD.

#### 2.2.3 Pharmacokinetic Population

The PK Population will include all patients who receive at least one dose of study treatment and have at least one evaluable PK sample.

#### 2.2.4 Efficacy Evaluable Population

The Efficacy Evaluable Population will include all patients who receive at least one dose of study treatment and have at least one post-baseline tumor assessment. This population will be used for all efficacy analyses.

#### 2.2.5 Per-Protocol Population

The Per-Protocol Population will include all patients in the Efficacy Evaluable Population who do not have major protocol deviations affecting efficacy assessment. This population will be used for sensitivity analyses of the primary efficacy endpoint.

### 2.3 Statistical Analyses

#### 2.3.1 General Considerations

All statistical analyses will be performed using SAS version 9.4 or higher, or R version 4.0 or higher. Continuous variables will be summarized with descriptive statistics (n, mean, standard deviation, median, minimum, and maximum). Categorical variables will be summarized with frequencies and percentages.

Unless otherwise specified, the significance level for statistical tests will be 0.05, and all tests will be two-sided. Confidence intervals will be presented at the 95% level.

#### 2.3.2 Phase I Dose Escalation Analysis

The MTD will be determined based on the observed DLTs in Cycle 1. The MTD is defined as the highest dose level at which fewer than 33% of patients experience a DLT.

The OBD will be determined based on an integrated assessment of safety, PK, and PD data. Specifically, the OBD will be the dose that provides optimal target engagement (≥80% PARP inhibition in PBMCs and/or tumor biopsies) with an acceptable safety profile.

Dose escalation decisions will be made after all patients in a cohort have completed the DLT evaluation period (Cycle 1) or have experienced a DLT. Dose escalation rules are as follows:

- If 0/3 patients experience a DLT, escalate to the next dose level
- If 1/3 patients experience a DLT, enroll 3 additional patients at the same dose level
  - If 1/6 patients experience a DLT, escalate to the next dose level
  - If ≥2/6 patients experience a DLT, declare the current dose level as exceeding the MTD
- If ≥2/3 patients experience a DLT, declare the current dose level as exceeding the MTD

The RP2D for the Phase II portion will be the MTD or OBD, whichever is lower.

#### 2.3.3 Primary Efficacy Analysis (Phase II)

The primary efficacy endpoint for the Phase II portion is the PFS rate at 24 months, defined as the proportion of patients alive and without disease progression at 24 months from study entry.

The PFS rate at 24 months will be estimated with its 95% confidence interval using the Kaplan-Meier method. PFS will be defined as the time from study entry to the first documented disease progression (per RECIST v1.1) or death from any cause, whichever occurs first. Patients without documented progression or death at the time of analysis will be censored at the date of the last tumor assessment showing no evidence of progression.

The null hypothesis that the 24-month PFS rate is ≤25% will be tested against the alternative hypothesis that the 24-month PFS rate is >25% using a one-sample binomial test.

A sensitivity analysis will be performed using the Per-Protocol Population to assess the robustness of the primary analysis.

#### 2.3.4 Secondary Efficacy Analyses

**Progression-Free Survival (PFS):**
- Median PFS and the associated 95% confidence interval will be estimated using the Kaplan-Meier method
- PFS curves will be generated using the Kaplan-Meier method
- Subgroup analyses will be performed by BRCA mutation status (BRCA-mutated vs. non-BRCA HRD-positive)

**Overall Survival (OS):**
- OS will be defined as the time from study entry to death from any cause
- Median OS and the associated 95% confidence interval will be estimated using the Kaplan-Meier method
- OS curves will be generated using the Kaplan-Meier method

**Objective Response Rate (ORR):**
- ORR will be defined as the proportion of patients achieving a complete response (CR) or partial response (PR) per RECIST v1.1
- ORR and its 95% confidence interval will be calculated using the Clopper-Pearson method

**Duration of Response (DOR):**
- DOR will be defined as the time from first documented response (CR or PR) to disease progression or death from any cause, whichever occurs first
- Median DOR and the associated 95% confidence interval will be estimated using the Kaplan-Meier method

#### 2.3.5 Safety Analyses

Safety analyses will be performed on the Safety Population. All adverse events (AEs) will be coded using the Medical Dictionary for Regulatory Activities (MedDRA) and graded according to the National Cancer Institute Common Terminology Criteria for Adverse Events (NCI CTCAE) v5.0.

The following safety analyses will be performed:
- Summary of all treatment-emergent adverse events (TEAEs)
- Summary of TEAEs by severity grade
- Summary of treatment-related AEs
- Summary of serious adverse events (SAEs)
- Summary of AEs leading to dose modification or treatment discontinuation
- Summary of deaths and causes of death
- Summary of laboratory abnormalities
- Summary of vital signs
- Summary of ECOG performance status

AEs of special interest for PARP inhibitors will be specifically analyzed, including:
- Myelosuppression (anemia, neutropenia, thrombocytopenia)
- Fatigue
- Nausea/vomiting
- MDS/AML
- Pneumonitis

AEs of special interest for bevacizumab will also be specifically analyzed, including:
- Hypertension
- Proteinuria
- Thromboembolic events
- Hemorrhage
- Gastrointestinal perforation
- Wound healing complications

## 3. PHARMACOKINETIC AND PHARMACODYNAMIC ANALYSES

### 3.1 Pharmacokinetic Assessments

#### 3.1.1 PK Sampling Schedule

**Phase I:**
- Intensive PK sampling will be conducted on:
  - Cycle 1 Day 1: Pre-dose, 0.5, 1, 2, 4, 6, 8, and 12 hours post-dose
  - Cycle 1 Day 15: Pre-dose, 0.5, 1, 2, 4, 6, 8, and 12 hours post-dose
  - Cycle 2 Day 1: Pre-dose sample only

**Phase II:**
- Sparse PK sampling will be conducted on:
  - Cycle 1 Day 1: Pre-dose, 2, and 6 hours post-dose
  - Cycle 1 Day 15: Pre-dose and 2 hours post-dose
  - Cycle 2 Day 1: Pre-dose sample only
  - Cycles 3 and beyond: Pre-dose sample on Day 1 of each cycle

#### 3.1.2 PK Parameters

The following PK parameters will be calculated using non-compartmental analysis for INH006:
- Maximum observed plasma concentration (Cmax)
- Time to maximum concentration (Tmax)
- Area under the plasma concentration-time curve from time zero to the last measurable concentration (AUC0-last)
- Area under the plasma concentration-time curve from time zero to 12 hours (AUC0-12)
- Area under the plasma concentration-time curve from time zero to infinity (AUC0-inf)
- Terminal elimination half-life (t1/2)
- Apparent oral clearance (CL/F)
- Apparent volume of distribution (Vz/F)
- Accumulation ratio (Racc) for Cmax and AUC0-12

#### 3.1.3 PK Statistical Analysis

PK parameters will be summarized with descriptive statistics (n, mean, standard deviation, coefficient of variation, geometric mean, median, minimum, and maximum) for each dose level.

Dose proportionality of INH006 will be assessed using a power model: ln(PK parameter) = α + β × ln(dose) + error, where β = 1 indicates perfect dose proportionality. The 90% confidence interval for β will be calculated.

The effect of bevacizumab on INH006 PK will be evaluated by comparing PK parameters between INH006 alone and INH006 in combination with bevacizumab using a mixed-effects model.

### 3.2 Pharmacodynamic Assessments

#### 3.2.1 PD Sampling Schedule

**PBMC Samples:**
- Cycle 1 Day 1: Pre-dose, 2, 6, and 24 hours post-dose
- Cycle 1 Day 15: Pre-dose, 2, and 6 hours post-dose
- Cycle 2 Day 1: Pre-dose

**Tumor Biopsies (optional):**
- Screening (archival tissue)
- Cycle 1 Day 15-21
- At the time of progression (optional)

#### 3.2.2 PD Biomarkers

The following PD biomarkers will be assessed:

**Target Engagement Biomarkers:**
- PARP enzyme activity in PBMCs
- PAR levels in PBMCs and tumor biopsies

**Mechanism of Action Biomarkers:**
- γH2AX foci (marker of DNA double-strand breaks)
- RAD51 foci (marker of homologous recombination)
- pS345-CHK1 (marker of DNA damage response)

**Downstream Effect Biomarkers:**
- Tumor hypoxia markers (CA IX, HIF-1α)
- Angiogenic markers (VEGF, VEGFR)
- Circulating tumor DNA (ctDNA) levels

#### 3.2.3 PD Statistical Analysis

PD parameters will be summarized with descriptive statistics for each dose level. The relationship between INH006 dose/exposure and PD effects will be explored using appropriate graphical methods and regression models.

The time course of PD effects will be characterized, and the relationship between PD effects and clinical outcomes will be explored using correlation analyses and Cox proportional hazards models.

### 3.3 Exposure-Response Analysis

#### 3.3.1 Exposure-Response for Efficacy

The relationship between INH006 exposure metrics (Cmax, AUC) and efficacy endpoints (PFS, ORR) will be explored using appropriate methods, including:
- Kaplan-Meier analysis stratified by exposure quartiles
- Logistic regression for binary endpoints (e.g., response)
- Cox proportional hazards models for time-to-event endpoints

#### 3.3.2 Exposure-Response for Safety

The relationship between INH006 exposure metrics and safety endpoints (selected AEs, laboratory abnormalities) will be explored using:
- Logistic regression for binary safety endpoints
- Ordered categorical regression for AE severity grades

#### 3.3.3 PK/PD Modeling

Population PK and PK/PD modeling will be performed to:
- Characterize the dose-concentration-response relationships
- Identify significant covariates affecting PK and PD parameters
- Simulate alternative dosing regimens
- Provide a scientific basis for dose selection and individualization

A population PK model will be developed using nonlinear mixed-effects modeling (NONMEM) to describe the disposition of INH006 in plasma. The model will incorporate both dense (Phase I) and sparse (Phase II) PK data. Covariates (demographic, laboratory, and disease characteristics) will be evaluated for their effects on PK parameters.

PK/PD models will be developed to link INH006 exposure to biomarker responses and clinical outcomes. These models will help establish the exposure-response relationships required by FDA and support future dose recommendations.

## 4. EXPLORATORY ANALYSES

### 4.1 Biomarker Analyses

#### 4.1.1 Predictive Biomarkers

The following potential predictive biomarkers will be explored:
- BRCA1/2 mutation status (germline vs. somatic)
- HRD score components (LOH, TAI, LST)
- Mutations in other HRR pathway genes (e.g., ATM, PALB2, RAD51C/D)
- CCNE1 amplification
- BRCAness gene expression signature
- PARPi sensitivity gene expression signature

The association between these biomarkers and efficacy outcomes will be evaluated using appropriate statistical methods, including:
- Stratified Kaplan-Meier analyses
- Cox proportional hazards models
- Logistic regression models

#### 4.1.2 Pharmacogenomic Analyses

Genetic polymorphisms in drug-metabolizing enzymes and transporters will be assessed to evaluate their impact on INH006 PK and safety:
- CYP3A4/5 polymorphisms
- P-glycoprotein (ABCB1) polymorphisms
- BCRP (ABCG2) polymorphisms

The association between these polymorphisms and PK parameters or AE incidence will be evaluated using appropriate statistical methods.

### 4.2 Patient-Reported Outcomes

Patient-reported outcomes (PROs) will be assessed using:
- EORTC QLQ-C30 (quality of life)
- EORTC QLQ-OV28 (ovarian cancer-specific module)
- EQ-5D-5L (health utility)

PRO scores will be summarized at each assessment timepoint and change from baseline will be evaluated. The association between PRO measures and clinical outcomes will be explored.

### 4.3 Dose Optimization Analyses

Based on the integrated PK, PD, safety, and efficacy data, the following dose optimization analyses will be performed:
- Exploration of alternative dosing regimens (e.g., different doses or schedules)
- Identification of patient subgroups requiring dose modifications
- Evaluation of dose intensity-outcome relationships

Simulation-based approaches using the developed PK/PD models will be employed to support these analyses.

## 5. INTERIM ANALYSES AND EARLY STOPPING RULES

### 5.1 Phase I Interim Analyses

Safety data will be reviewed continuously during the Phase I portion of the study. Dose escalation decisions will be made after all patients in a cohort have completed the DLT evaluation period or have experienced a DLT.

An interim PK/PD analysis will be performed after the first 2-3 dose levels have been completed to ensure that target engagement (≥50% PARP inhibition) is achieved and to guide further dose escalation decisions.

### 5.2 Phase II Interim Analyses

An interim analysis for futility will be conducted after approximately 30 patients in the Phase II portion have been followed for at least 12 months. If the observed 12-month PFS rate is significantly lower than expected (≤40%), early termination of the study may be considered.

Safety data will be reviewed periodically by an independent Data Monitoring Committee (DMC) throughout the Phase II portion of the study.

### 5.3 Stopping Rules

The study may be stopped early for:
- Unacceptable toxicity: If the rate of serious, treatment-related AEs exceeds a prespecified threshold
- Futility: If the interim analysis suggests that the study is unlikely to meet its primary endpoint
- Overwhelming efficacy: If the interim analysis suggests a highly significant benefit over historical controls

The specific stopping boundaries will be detailed in the DMC charter.

## 6. HANDLING OF MISSING DATA

### 6.1 Missing Efficacy Data

For the primary analysis of the 24-month PFS rate, patients without a documented progression or death who are lost to follow-up before 24 months will be censored at the date of their last tumor assessment showing no progression.

Sensitivity analyses using different censoring rules will be performed to assess the robustness of the primary analysis, including:
- Considering all patients lost to follow-up or who discontinue treatment before 24 months without documented progression as having progressed
- Multiple imputation methods for handling missing data

### 6.2 Missing PK/PD Data

For PK analyses, samples with concentrations below the lower limit of quantification (LLOQ) will be handled as follows:
- Samples before the first quantifiable concentration will be treated as zero
- Samples between quantifiable concentrations will be treated as missing
- Samples after the last quantifiable concentration will be treated as missing

For calculation of summary statistics, values below LLOQ will be treated as zero.

Missing PK/PD data will not be imputed. Population PK and PK/PD modeling approaches inherently handle missing or sparse data through mixed-effects modeling techniques.

## 7. REGULATORY CONSIDERATIONS

### 7.1 Compliance with FDA Guidance

This SAP has been developed in accordance with the FDA guidance "Exposure-Response Relationships — Study Design, Data Analysis, and Regulatory Applications" and other relevant regulatory guidelines.

The PK/PD strategy outlined in this SAP aims to establish the scientific basis for the exposure-response relationship as required by FDA, including:
- Characterization of dose-concentration-time relationships
- Assessment of concentration-response relationships for efficacy and safety
- Evaluation of the impact of intrinsic and extrinsic factors on exposure-response
- Development of models to support dose selection and individualization

### 7.2 Data Presentation for Regulatory Submission

For regulatory submissions, PK/PD and exposure-response data will be presented in accordance with the FDA guidance and will include:
- Comprehensive summaries of PK and PD parameters
- Graphical presentations of exposure-response relationships
- Results of population PK and PK/PD modeling
- Simulations of alternative dosing regimens
- Analyses supporting dose selection and individualization

## 8. REFERENCES

1. FDA Guidance for Industry: Exposure-Response Relationships — Study Design, Data Analysis, and Regulatory Applications (2003)

2. Ray-Coquard I, et al. (2019). Olaparib plus Bevacizumab as First-Line Maintenance in Ovarian Cancer. N Engl J Med, 381(25), 2416-2428.

3. Coleman RL, et al. (2017). Rucaparib maintenance treatment for recurrent ovarian carcinoma after response to platinum therapy (ARIEL3): a randomised, double-blind, placebo-controlled, phase 3 trial. Lancet, 390(10106), 1949-1961.

4. Moore K, et al. (2018). Maintenance Olaparib in Patients with Newly Diagnosed Advanced Ovarian Cancer. N Engl J Med, 379(26), 2495-2505.

5. González-Martín A, et al. (2019). Niraparib in Patients with Newly Diagnosed Advanced Ovarian Cancer. N Engl J Med, 381(25), 2391-2402.

6. Sheiner LB, et al. (1991). A simulation study comparing designs for dose ranging. Stat Med, 10(3), 303-321.

7. Peck CC, et al. (1994). Opportunities for integration of pharmacokinetics, pharmacodynamics, and toxicokinetics in rational drug development. Clin Pharmacol Ther, 56(6), 785-797.

8. Lesko LJ, et al. (2000). Optimizing the science of drug development: opportunities for better candidate selection and accelerated evaluation in humans. J Clin Pharmacol, 40(8), 803-814.

## 9. APPENDICES

### Appendix A: Schedule of Assessments

[Detailed schedule of assessments to be included]

### Appendix B: Definition of Dose-Limiting Toxicities

Dose-limiting toxicities (DLTs) are defined as any of the following events occurring during the DLT evaluation period (Cycle 1) that are considered related to study treatment:

**Hematologic DLTs:**
- Grade 4 neutropenia lasting >7 days
- Febrile neutropenia (Grade 3 or 4)
- Grade 4 thrombocytopenia
- Grade 3 thrombocytopenia with bleeding
- Grade 4 anemia

**Non-hematologic DLTs:**
- Any Grade 3 or 4 non-hematologic toxicity, except:
  - Grade 3 nausea, vomiting, or diarrhea that resolves to ≤Grade 2 within 48 hours with optimal medical management
  - Grade 3 fatigue that resolves to ≤Grade 2 within 7 days
  - Asymptomatic Grade 3 laboratory abnormalities that resolve to ≤Grade 2 within 7 days
- Grade 2 toxicity that, in the investigator's judgment, requires dose reduction or treatment delay >7 days

**Bevacizumab-specific DLTs:**
- Grade 4 hypertension
- Grade 3 hypertension that is not controlled by oral medications
- Grade 3 or 4 proteinuria
- Any grade arterial thromboembolic event
- Grade 3 or 4 venous thromboembolic event
- Gastrointestinal perforation, GI fistula, or intra-abdominal abscess (any grade)
- Grade 3 or 4 hemorrhage
- Grade 4 PRES (posterior reversible encephalopathy syndrome)

### Appendix C: RECIST v1.1 Criteria for Tumor Response

[RECIST v1.1 criteria to be included]

### Appendix D: HRD Testing Methodology

[Description of HRD testing methodology to be included]

### Appendix E: Population PK and PK/PD Modeling Plan

[Detailed modeling plan to be included]

### Appendix F: Statistical Analysis Software Code

[Example SAS/R code for key analyses to be included]
