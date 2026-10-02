# =========================================================
# PM2.5 Extraction to DHS Cluster Level (India)
# Author: Nikita Dhingra 
#
# Input:  EAC4 monthly PM2.5 (NetCDF, kg/m^3), 84 monthly bands, Jan 2015 - Dec 2021
#         DHS Round 5 (NFHS-5) cluster GPS points
# Output: cluster-month PM2.5 in ug/m^3, plus each cluster's 2015-21 mean
#         (data/processed/avg_pm25_v3.dta), and a map of mean PM2.5
#
# Each cluster is assigned the PM2.5 value of the grid cell it falls in.
# =========================================================

library(sf)
library(raster)
library(ncdf4)
library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)
library(haven)

# -------------------------------
# File paths (relative to repository root)
# -------------------------------
nc_path  <- "data/raw/pollution/monthlypm2p5_india_subset.nc"
dhs_path <- "data/raw/dhs/cluster_locations/DHS.shp"
out_path <- "data/processed/avg_pm25_v3.dta"
fig_path <- "output/figures/pm25_cluster_mean_map.png"

# -------------------------------
# Load DHS cluster points
# -------------------------------
dhs_shapefile <- st_read(dhs_path)
dhs_shapefile <- st_make_valid(dhs_shapefile)
dhs_shapefile <- st_transform(dhs_shapefile, crs = "EPSG:4326")

# -------------------------------
# Get PM2.5 variable name from the NetCDF
# -------------------------------
nc <- nc_open(nc_path)
var_name <- names(nc$var)[1]
nc_close(nc)

# Band 1 is January 2015 
print(getZ(raster(nc_path, band = 1, varname = var_name)))

# -------------------------------
# Extract PM2.5 at each cluster, for all 84 months
# -------------------------------
extracted_values_list <- vector("list", length = 84)

for (band in 1:84) {

  my_rast <- raster(x = nc_path, band = band, varname = var_name)

  val_extract <- extract(
    x     = my_rast,
    y     = dhs_shapefile,
    fun   = mean,
    na.rm = TRUE,
    sp    = TRUE
  )

  val_extract_dt <- as.data.table(st_drop_geometry(val_extract))
  val_extract_dt[, band := band]

  extracted_values_list[[band]] <- val_extract_dt
}

combined_results <- rbindlist(extracted_values_list, use.names = TRUE, fill = TRUE)

# -------------------------------
# Convert units (kg/m^3 -> ug/m^3) and clean names
# -------------------------------
combined_results[, pm25 := Particulate.matter.d....2.5.um * 10^9]
combined_results[, Particulate.matter.d....2.5.um := NULL]
setnames(combined_results, c("coords.x1", "coords.x2"), c("coords_x1", "coords_x2"))

# -------------------------------
# Convert band number to month (band 1 = Jan 2015)
# -------------------------------
start_date <- ymd("2015-01-31")
combined_results[, month_year := format(start_date %m+% months(band - 1), "%b %Y")]

# -------------------------------
# Add each cluster's mean PM2.5 over 2015-21
# -------------------------------
avg_pm25 <- combined_results %>%
  group_by(DHSCLUST) %>%
  mutate(mean_pm25 = mean(pm25, na.rm = TRUE)) %>%
  ungroup()

# -------------------------------
# Drop clusters with missing GPS (coordinates 0, 0)
# -------------------------------
avg_pm25 <- avg_pm25 %>%
  filter(coords_x1 != 0 & coords_x2 != 0)

# -------------------------------
# Map of mean PM2.5 by cluster
# -------------------------------
cluster_map <- avg_pm25 %>%
  distinct(DHSCLUST, coords_x1, coords_x2, mean_pm25) %>%
  st_as_sf(coords = c("coords_x1", "coords_x2"), crs = 4326)

p <- ggplot() +
  geom_sf(data = cluster_map, aes(color = mean_pm25), size = 1, alpha = 0.8) +
  scale_color_viridis_c(option = "C", name = "PM2.5 (µg/m³)") +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text  = element_blank(),
    axis.title = element_blank(),
    plot.title = element_text(size = 16)
  ) +
  labs(title = "Average PM2.5 Levels (2015–2021)")

dir.create(dirname(fig_path), showWarnings = FALSE, recursive = TRUE)
ggsave(fig_path, p, width = 7, height = 8, dpi = 300)

# -------------------------------
# Export to Stata
# -------------------------------
dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
write_dta(avg_pm25, out_path)
