# Data

No data are included in this repository. DHS data are restricted, and the other sources are large but freely available. To run the code, download the data from the sources below and save them in `data/raw/` using the folder and file names shown. The scripts create `data/processed/` automatically.

## Folder layout

```
data/raw/
├── pollution/monthlypm2p5_india_subset.nc
├── weather/ERA5_weather_controls.nc
├── fire/modis_2015_India.csv ... modis_2021_India.csv
├── shapefiles/2011_Dist.shp (with .dbf, .shx, .prj)
└── dhs/cluster_locations/DHS.shp (with .dbf, .shx, .prj)
```

## Sources

**PM2.5 (EAC4).** CAMS global reanalysis (EAC4) monthly averaged fields from the Copernicus Atmosphere Data Store. Variable: particulate matter d < 2.5 µm (`pm2p5`), January 2015 to December 2021, subset to India.

**Weather (ERA5).** ERA5 monthly averaged data on single levels from the Copernicus Climate Data Store. Variables: 2 m temperature (`t2m`), 10 m u- and v-wind components (`u10`, `v10`), total precipitation (`tp`), January 2015 to December 2021, area 60–100°E, 5–40°N.

**Fires (FIRMS).** NASA FIRMS archive download (https://firms.modaps.eosdis.nasa.gov/download/), MODIS Collection 6.1, India, one CSV per year for 2015–2021.

**District boundaries.** India district shapefile, 2011 Census.

**DHS cluster locations.** DHS India Round 5 (NFHS-5, 2019–21) GPS dataset. Access requires a free registered account and an approved project at https://dhsprogram.com. DHS data may not be redistributed.
