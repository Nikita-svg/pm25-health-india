# =========================================================
# PM2.5 Extraction from NetCDF to District Level (India)
# Author: Nikita Dhingra 
# Input:  EAC4 monthly PM2.5 (NetCDF, kg/m^3), 84 monthly bands
#         2011 Census district shapefile
# Output: district-month PM2.5 in ug/m^3
# =========================================================

library(sf)
library(raster)
library(ncdf4)
library(data.table)
library(haven)

# -------------------------------
# File paths (relative to repository root)
# -------------------------------
nc_path  <- "data/raw/pollution/monthlypm2p5_india_subset.nc"
shp_path <- "data/raw/shapefiles/2011_Dist.shp"
out_path <- "data/processed/combined_results.dta"

# -------------------------------
# Load and clean district shapefile
# -------------------------------
districts <- st_read(shp_path)
districts <- st_make_valid(districts)
districts <- st_transform(districts, crs = "EPSG:4326")

# -------------------------------
# Get PM2.5 variable name from the NetCDF
# -------------------------------
nc <- nc_open(nc_path)
var_name <- names(nc$var)[1]
nc_close(nc)

# -------------------------------
# Extract mean PM2.5 for each district, for all 84 months
# -------------------------------
extracted_values_list <- vector("list", length = 84)

for (band in 1:84) {

  my_rast <- raster(x = nc_path, band = band, varname = var_name)

  val_extract <- extract(
    x     = my_rast,
    y     = districts,
    fun   = mean,
    na.rm = TRUE,
    sp    = TRUE
  )

  val_extract_dt <- as.data.table(st_drop_geometry(val_extract))

  # Band number and the date it corresponds to
  val_extract_dt[, band := band]
  val_extract_dt[, date := as.character(getZ(my_rast))]

  extracted_values_list[[band]] <- val_extract_dt
}

combined_results <- rbindlist(extracted_values_list, use.names = TRUE, fill = TRUE)

# -------------------------------
# Convert PM2.5 from kg/m^3 to ug/m^3
# -------------------------------
combined_results[, pm2_5 := Particulate.matter.d....2.5.um * 10^9]
combined_results[, Particulate.matter.d....2.5.um := NULL]

# -------------------------------
# Export to Stata
# -------------------------------
dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
write_dta(combined_results, out_path)
