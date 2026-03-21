# =========================================================
# PM2.5 + DHS + Fire Data Integration
# Author: Nikita Dhingra
# =========================================================

# Load libraries
library(sf)
library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)
library(haven)

# -------------------------------
# Load processed PM2.5 data
# -------------------------------
pm25_data <- read_dta("output/pm25_district_monthly.dta")

# -------------------------------
# Load DHS shapefile
# -------------------------------
dhs_shapefile <- st_read("data/dhs/DHS.shp") %>%
  st_make_valid() %>%
  st_transform(crs = 4326)

# -------------------------------
# Convert to spatial points
# -------------------------------
pm25_sf <- st_as_sf(pm25_data, coords = c("coords_x1", "coords_x2"), crs = 4326)

# -------------------------------
# Create buffers (50km, 75km, 100km)
# -------------------------------
buffer_50km <- st_buffer(dhs_shapefile, dist = 50000)
buffer_75km <- st_buffer(dhs_shapefile, dist = 75000)
buffer_100km <- st_buffer(dhs_shapefile, dist = 100000)

# -------------------------------
# Compute average PM2.5 per cluster
# -------------------------------
avg_pm25 <- pm25_data %>%
  group_by(DHSCLUST) %>%
  summarise(mean_pm25 = mean(pm25, na.rm = TRUE))

# -------------------------------
# Plot spatial variation
# -------------------------------
avg_pm25_sf <- st_as_sf(avg_pm25, coords = c("coords_x1", "coords_x2"), crs = 4326)

ggplot(avg_pm25_sf) +
  geom_sf(aes(color = mean_pm25)) +
  scale_color_viridis_c() +
  theme_minimal() +
  ggtitle("Average PM2.5 (2015–2021)")

# -------------------------------
# Load DHS birth data
# -------------------------------
dhs_births <- read_dta("data/dhs/births_2019.dta")

# Merge cluster info
dhs_births <- left_join(dhs_births, dhs_shapefile, by = "DHSCLUST")

# -------------------------------
# Match PM2.5 within 75km buffer
# -------------------------------
matches <- st_intersects(pm25_sf, buffer_75km, sparse = TRUE)

matched_pm25 <- pm25_sf[lengths(matches) > 0, ]

# Merge with births
dhs_births_pm25 <- left_join(
  dhs_births,
  matched_pm25,
  by = c("DHSCLUST", "month_year")
)

# -------------------------------
# Load fire data
# -------------------------------
fire_files <- list.files("data/fire/", full.names = TRUE)

fire_data <- fire_files %>%
  lapply(read_csv) %>%
  bind_rows() %>%
  mutate(acq_date = dmy(acq_date)) %>%
  filter(!is.na(acq_date))

# Convert to spatial
fire_sf <- st_as_sf(fire_data, coords = c("longitude", "latitude"), crs = 4326)

# -------------------------------
# Fires within 75km and 100km
# -------------------------------
fires_75 <- st_filter(fire_sf, buffer_75km)
fires_100 <- st_filter(fire_sf, buffer_100km)

# Ring: 75–100km
fires_ring <- anti_join(fires_100, fires_75, by = "fire_id")

# -------------------------------
# Count fires per cluster-month
# -------------------------------
fire_counts <- fires_ring %>%
  group_by(cluster_id, month) %>%
  summarise(fire_events = n(), .groups = "drop")

# -------------------------------
# Final merge
# -------------------------------
final_data <- left_join(
  dhs_births_pm25,
  fire_counts,
  by = c("DHSCLUST", "month_year")
)

# Save
write_dta(final_data, "output/final_analysis_dataset.dta")
