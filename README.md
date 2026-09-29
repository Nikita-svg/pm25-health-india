# PM2.5 and Birth Outcomes in India

Code for **"Breathing for Two"**, a study of the effect of in-utero air pollution exposure on birth outcomes in India.

**Author:** Nikita Dhingra, PhD Candidate in Economics, Andrew Young School of Policy Studies, Georgia State University

## Overview
This project constructs a cluster-level panel dataset of air pollution (PM2.5) and fire exposure in India using satellite data and administrative boundaries. The dataset is designed to study the causal impact of air pollution on birth outcomes using DHS data, with upwind fire activity 75–100 km away as an instrumental variable.

## Data Sources
- Satellite PM2.5 data from EAC4- ECMWF Atmospheric Composition Reanalysis 4 (NetCDF format)
- Weather variables- wind, precipitation temperature from ECMWF ERA reanalysis (u/v components)
- Satellite fire event data from NASA FIRMS, MODIS (Terra)
- India district shapefiles from 2011 Census
- India's demographic data from Demographic and Health Survey (DHS), Round 5- 2019-21

## Methodology

The pipeline performs the following steps:

1. **PM2.5 extraction.** Reads monthly PM2.5 rasters, converts units from kg/m³ to µg/m³. Aggregates grid-level PM2.5 to DHS clusters by averaging grid cells within 75 km of each cluster.
2. **DHS clusters.** Cleans cluster GPS points, drops clusters with missing coordinates, and projects them to a metric coordinate system.
3. **Fire exposure.** For each cluster, computes fire exposure measures within spatial buffer 75–100 km, computes the bearing from cluster to fire, and classifies each fire as upwind or not using ERA5 wind direction. 
4. **Exposure windows.** Aggregates PM2.5 and upwind fire counts over each birth's gestational period, from conception to birth and by trimester.
5. **Analysis dataset.** Merges exposures with DHS birth records and exports the result for estimation in Stata.
   
## Output
- Cluster-month PM2.5 exposure dataset (intermediate)
- Cluster-month upwind fire exposure dataset (intermediate)
- Birth-level analysis dataset: each birth from DHS Round 5 linked to PM2.5 and upwind fire exposure over its gestational period, ready for estimation in Stata

## Code Structure
- `pm25_extraction_district_level.R`: Constructs district-level PM2.5 from satellite data
- `pm25_dhs_fire_analysis.R`: Integrates PM2.5 with DHS clusters and fire data to build the final analysis dataset

## Tools Used
- R (sf, raster, terra, lubridate, haven, ggplot2, ncdf4, data.table, dplyr)
- Stata (for downstream econometric analysis)

## Citation

If you use this code, please cite:
 Dhingra, N. (2026). *Breathing for Two: Air Pollution and Birth Outcomes in India.* Working paper, Georgia State University.
 
## Author
Nikita Dhingra  
PhD Candidate, Georgia State University
Contact : ndhingra1@student.gsu.edu
