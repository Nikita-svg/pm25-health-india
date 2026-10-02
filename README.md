# PM2.5 and Birth Outcomes in India

Geospatial data construction for **"Breathing for Two"**, a study of the effect of in-utero air pollution exposure on birth outcomes in India.

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
2. **DHS clusters.** Assigns each DHS cluster the PM2.5 value of the grid cell it falls in, for each month from 2015 to 2021, and maps the 2015–21 average.
3. **Cluster weather.** Extracts ERA5 temperature, wind, and precipitation at each cluster for each month.
4. **Fire exposure.** For each cluster, computes fire exposure measures within spatial buffer 75–100 km, computes the bearing from cluster to fire, and classifies each fire as upwind or not using ERA5 wind direction. (a fire within 90° of the direction the wind blows toward is downwind). Fires 75–100 km away are counted by cluster-month.
5. **Exposure windows.** Aggregates PM2.5 and upwind fire counts over each birth's gestational period, from conception to birth and by trimester.
6. **Analysis dataset.** Merges exposures with DHS birth records and exports the result for estimation in Stata.
   
## Output

- `pm25_district_monthly.dta`: district-month PM2.5
- `avg_pm25_v3.dta`: cluster-month PM2.5, with each cluster's 2015–21 mean
- `weather_combined_4vars_wide.dta`: cluster-month weather (ERA5 native units: Kelvin, m/day, m/s)
- `fire_ring_weather.dta`: cluster-month counts of upwind and downwind fires 75–100 km away, with temperature and precipitation
- `pm25_cluster_mean_map.png`: map of mean PM2.5 by cluster
- Birth-level analysis dataset: each birth from DHS Round 5 linked to PM2.5 and upwind fire exposure over its gestational period, ready for estimation in Stata
  
- ## Repository Structure

```
pm25-health-india/
├── code/
│   ├── 01_pm25_district_level.R
│   ├── 02_pm25_cluster_level.R
│   ├── 03_weather_era5_cluster.R
│   └── 04_fire_ring_upwind.R
├── data/
│   ├── raw/                        # downloaded source data (not included)
│   └── processed/                  # created by the scripts
├── output/
│   └── figures/
└── README.md
```

## How to Run

1. Clone the repository and open it in R, with the repository root as the working directory.
2. Place the raw data in `data/raw/`:
   - `pollution/monthlypm2p5_india_subset.nc` (EAC4 PM2.5)
   - `weather/ERA5_weather_controls.nc` (ERA5)
   - `fire/modis_2015_India.csv` … `modis_2021_India.csv` (FIRMS)
   - `shapefiles/2011_Dist.shp` (districts)
   - `dhs/cluster_locations/DHS.shp` (DHS cluster GPS)
3. Run `source("code/00_master.R")`. Script 04 needs the weather output from script 03.

The fire step is memory-intensive; lower `chunk_size` in `04_fire_ring_upwind.R` if R runs out of memory.

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
