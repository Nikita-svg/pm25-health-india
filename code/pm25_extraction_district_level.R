# =========================================================
# PM2.5 Extraction from NetCDF to District Level (India)
# Author: Nikita Dhingra
# =========================================================

# Load libraries
library(sf)
library(raster)
library(ncdf4)
library(data.table)

# -------------------------------
# File paths
# -------------------------------
data_path <- "data/pm25/monthlypm2p5_india_subset.nc"
shp_path  <- "data/shapefiles/2011_Dist.shp"

# -------------------------------
# Load district shapefile
# -------------------------------
districts <- st_read(shp_path)

# Fix invalid geometries
districts <- st_make_valid(districts)

# -------------------------------
# Open NetCDF file
# -------------------------------
nc_file <- nc_open(data_path)
var_names <- names(nc_file$var)
nc_close(nc_file)

# -------------------------------
# Initialize storage
# -------------------------------
extracted_values_list <- vector("list", length = 84)

# -------------------------------
# Loop over all 84 bands (months)
# -------------------------------
for (band in 1:84) {
  
  # Load raster for given band
  my_rast <- raster(
    x = data_path,
    band = band,
    varname = var_names[1]
  )
  
  # Ensure CRS match
  districts <- st_transform(districts, crs = crs(my_rast))
  
  # Extract mean PM2.5 for each district
  val_extract <- extract(
    x = my_rast,
    y = districts,
    fun = mean,
    na.rm = TRUE,
    sp = TRUE
  )
  
  # Convert to data.table
  val_dt <- as.data.table(st_drop_geometry(val_extract))
  
  # Add time/band identifier
  val_dt[, band := band]
  
  # Store
  extracted_values_list[[band]] <- val_dt
}

# -------------------------------
# Combine results
# -------------------------------
combined_results <- rbindlist(extracted_values_list, use.names = TRUE, fill = TRUE)

# -------------------------------
# Convert PM2.5 units
# -------------------------------
combined_results[, pm2_5 := Particulate.matter.d....2.5.um * 10^9]

# Drop original column
combined_results[, Particulate.matter.d....2.5.um := NULL]

# -------------------------------
# Export
# -------------------------------
write_dta(combined_results, "output/pm25_district_monthly.dta")
