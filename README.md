# raimbow-whaleRisk

<!-- badges: start -->
<!-- badges: end -->

This repository contains code for calculating, analyzing, and visualizing whale risk for RAIMBOW project

## File descriptions

### Analysis files (markdown files)
* Whale_risk.Rmd: Calculates (humpback) whale risk of entanglement for each grid cell as: humpback density * fishing measure. This file then saves the humpback, fishing, and risk values as an RDATA file for use in subsequent files.
* Whale_risk_timeseries.Rmd: Using RDATA file generated by Whale_risk.Rmd, summarizes and plots humpback whale risk of entanglement by region over time
* Whale_risk_maps.Rmd: Generates heat maps of data saved in Whale_risk.Rmd.

### Analysis files (other)
* JS_OceanVisions: Code used to create plots of Jameal's April 2019 OceanVisions presentation
* VMS_nonconfidential_duplicates.R: Identify duplicate rows in CA-only, non-confidential data
* Whale_risk_timeseries_orig.R: Original document for computing and summarizing time series of humpback risk of entanglement. This file used to be named 'Whale_risk_monthly_summ'.

### Helper files
* plot_raimbow.R: Functions for plotting objects; functions fairly specific to raimbow analyses
* User_script_local.R: Script for determining whom is running the code (user info used to set appropriate file paths); sourced in relevant files
* Whale_risk_timeseries_funcs.R: Helper plotting functions for Whale_rsik_timeseries file(s)
* whalepreds_aggregate: Summarize whale predictions by specified time interval. Do not edit; any edits should be done in [this repository](smwoodman/whale-model-prep) and copied over
