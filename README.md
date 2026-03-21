# PM2.5 and Health in India

## Overview
This project constructs a cluster-level panel dataset of air pollution (PM2.5) and fire exposure in India using satellite data and administrative boundaries. The dataset is designed to study the causal impact of air pollution on maternal and child health outcomes using DHS data, with local fire activity as an instrumental variable.

## Data Sources
- Satellite PM2.5 data (NetCDF format)
- Satellite fire event data (NASA FIRMS)
- India district shapefiles (2011 Census)
- DHS (Demographic and Health Surveys)

## Methodology
The pipeline performs the following steps:
1. Loads and cleans district and DHS cluster shapefiles
2. Extracts PM2.5 from raster (NetCDF) data
3. Aggregates grid-level pollution to DHS cluster-level exposure
4. Constructs a cluster-month panel dataset (84 months)
5. Computes fire exposure measures within spatial buffers
6. Prepares datasets for econometric analysis (e.g., IV estimation)

## Output
- Cluster-level monthly PM2.5 exposure dataset
- Cluster-level monthly fire exposure dataset
- Analysis-ready panel data for merging with DHS microdata

## Code Structure
- `pm25_extraction_district_level.R`: Constructs district-level PM2.5 from satellite data
- `pm25_dhs_fire_analysis.R`: Integrates PM2.5 with DHS clusters and fire data to build the final analysis dataset

## Tools Used
- R (sf, raster, ncdf4, data.table, dplyr)
- Stata (for downstream econometric analysis)

## Author
Nikita Dhingra  
PhD Candidate, Georgia State University
