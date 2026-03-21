# PM2.5 and Health in India

## Overview
This project constructs a district-level panel dataset of air pollution (PM2.5) and fire-events exposure in India using satellite-based data and administrative boundaries. The goal is to analyze the impact of air pollution on maternal and child health outcomes using DHS data, using local fire-activity as an instrument. 

## Data Sources
- Satellite PM2.5 data (NetCDF format)
- Satelite fire-events data (NASA FIRMS data)
- India district shapefiles (2011 Census)
- DHS (Demographic and Health Surveys)

## Methodology
The script performs the following steps:
1. Loads district shapefiles and fixes geometry issues
2. Extracts PM2.5 data from NetCDF raster files
3. Aggregates grid-level pollution data to cluster-level (sub-unit of districts used for sampling)  averages 
4. Constructs a cluster-month panel dataset (84 months)
5. Constructs fire events data for each cluster
6. Exports data for econometric analysis in Stata

## Output
- Cluster-level monthly PM2.5 dataset
- Cluster-level monthly fire-events dataset 
- Ready for merging with DHS cluster-level data

## Tools Used
- R (sf, raster, ncdf4, data.table)
- Stata (for downstream analysis)

## Author
Nikita Dhingra  
PhD Candidate, Georgia State University
