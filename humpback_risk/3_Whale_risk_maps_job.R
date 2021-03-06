

###############################################################################
library(classInt)
library(dplyr)
library(maps)
library(RColorBrewer)
library(sf)

source(here::here("humpback_risk/plot_raimbow.R"))

file.data.grid <- "C:/SMW/RAIMBOW/raimbow-local/Data/5x5 km grid shapefile/five_km_grid_polys_geo.shp"
file.grid.lno.rds <- "C:/SMW/RAIMBOW/raimbow-local/RDATA_files/Grid_5km_landerased.rds"
file.contour <- "C:/SMW/RAIMBOW/raimbow-local/Data/West_coast_bathy/West_Coast_geo.shp"
file.risk <- "C:/SMW/RAIMBOW/raimbow-local/RDATA_files/Whale_risk.Rdata"

path.rdata <- "C:/SMW/RAIMBOW/raimbow-local/RDATA_files/"
path.plots <- "C:/SMW/RAIMBOW/raimbow-local/Plots/Whale_risk_maps_50f/"


###############################################################################
## Load and process data
load(file.risk)
# d <- sapply(fish.pings, which.max)
# table(fish.pings$GRID5KM_ID[unname(unlist(d))])

# Prep - background map objects
map.contours <- st_read(file.contour)
map.contours.050m <- map.contours %>% filter(Contour == -50) %>% st_geometry()
map.contours.100m <- map.contours %>% filter(Contour == -100) %>% st_geometry()
map.contours.200m <- map.contours %>% filter(Contour == -200) %>% st_geometry()

map.base <- st_geometry(st_as_sf(maps::map('world', plot = FALSE, fill = TRUE)))
grid.5km.lno <- readRDS(file.grid.lno.rds)

# Process humpback, VMS, and risk data, including converting fishing values to density
div.func <- function(x, y) {x / y}
grid.area <- humpback.abund$area_km_lno

h.sf <- humpback.abund %>% 
  left_join(grid.5km.lno, by = "GRID5KM_ID") %>% 
  mutate(across(starts_with("Mn_"), div.func, y = grid.area)) %>%
  st_sf(agr = "constant") %>% 
  select(starts_with("Mn_"))

f.sf <- fish.pings %>% 
  left_join(grid.5km.lno, by = "GRID5KM_ID") %>% 
  mutate(across(starts_with("DC_"), div.func, y = grid.area)) %>%
  st_sf(agr = "constant") %>% 
  select(starts_with("DC_"))

r.sf <- risk.total %>% 
  left_join(grid.5km.lno, by = "GRID5KM_ID") %>% 
  mutate(across(starts_with("Mn_DC_risk"), div.func, y = grid.area)) %>%
  st_sf(agr = "constant") %>% 
  select(starts_with("Mn_DC_risk"))

h.vals.all <- unlist(st_drop_geometry(h.sf))
f.vals.all <- unlist(st_drop_geometry(f.sf))
r.vals.all <- unlist(st_drop_geometry(r.sf))

summary(h.vals.all)
summary(f.vals.all)
summary(r.vals.all)


###############################################################################
## Determine break point values
n.breakpts <- 5
col.pal <- rev(brewer.pal(n.breakpts, "YlGnBu"))

# h.br <- seq(0, max(st_drop_geometry(h.sf), na.rm = TRUE), length.out = 7)
# f.br <- ceiling(seq(0, max(st_drop_geometry(f.sf), na.rm = TRUE), length.out = 7))
# r.br <- ceiling(seq(0, max(st_drop_geometry(r.sf), na.rm = TRUE), length.out = 7))

set.seed(42)
# Takes ~3 min with samp_prop = default of 0.1
h.br <- classIntervals(na.omit(h.vals.all), n.breakpts, style = "fisher", samp_prop = 0.01)$brks
h.br[1] <- 0
h.br[n.breakpts + 1] <- max(h.vals.all, na.rm = TRUE)

set.seed(42)
f.br <- classIntervals(na.omit(f.vals.all), n.breakpts, style = "fisher")$brks
f.br <- round(f.br, 0) # Pings should be only whole numbers
f.br[1] <- 0
f.br[n.breakpts + 1] <- ceiling(max(f.vals.all, na.rm = TRUE))

set.seed(42)
r.br <- classIntervals(na.omit(r.vals.all), n.breakpts, style = "fisher")$brks
r.br[1] <- 0
r.br[n.breakpts + 1] <- ceiling(max(r.vals.all, na.rm = TRUE))

print(h.br)
print(f.br)
print(r.br)


###############################################################################
## Tester plots
# layout(matrix(1:3, nrow = 1))
# i <- "2015_04"
# plot_raimbow(
#   h.sf, "Mn_2015_04", grid.5km.lno, map.base, 
#   map.b1 = map.contours.100m, map.b2 = map.contours.200m, 
#   col.pal = col.pal, col.breaks = h.br, 
#   asp = 0, ylim = c(34, 48), xaxt = "n", 
#   main = paste("Humpback density", i)
# )
# legend_raimbow(h.br, "%0.2f", fill = rev(col.pal), cex = 1.4, title = "Whales/km2")
# legend.raimbow.bathy()
# 
# 
# plot_raimbow(
#   f.sf, "DC_2015_04", NULL, map.base, 
#   map.b1 = map.contours.100m, map.b2 = map.contours.200m, 
#   col.pal = col.pal, col.breaks = f.br, 
#   asp = 0, ylim = c(34, 48), xaxt = "n", 
#   main = paste("Non-conf VMS ping dens", i)  
# )
# legend_raimbow(f.br, "%0.0f", fill = rev(col.pal), cex = 1.4, title = "Pings/km2")
# legend.raimbow.bathy()
# 
# 
# plot_raimbow(
#   r.sf, "Mn_DC_risk_2015_04", NULL, map.base, 
#   map.b1 = map.contours.100m, map.b2 = map.contours.200m, 
#   col.pal = col.pal, col.breaks = r.br, 
#   asp = 0, ylim = c(34, 48), xaxt = "n", 
#   main = paste("Risk (linear) dens", i)  
# )
# legend_raimbow(r.br, "%0.1f", fill = rev(col.pal), cex = 1.4, title = "Whales*Pings/km2")
# legend.raimbow.bathy()
# 
# rm(i)


###############################################################################
## Create and save plots
key.txt <- apply(df.key[, 1:2], 1, paste, collapse = "_")

for (i in key.txt) {
  print(i)
  h.curr <- paste0("Mn_", i)
  f.curr <- paste0("DC_", i)
  r.curr <- paste0("Mn_DC_risk_", i)
  
  png(paste0(path.plots, i, ".png"), height = 4, width = 7, units = "in", res = 300)
  
  layout(matrix(1:3, nrow = 1))
  if (h.curr %in% names(h.sf)) {
    plot_raimbow(
      h.sf, h.curr, NULL, map.base, 
      map.i050 = map.contours.050m, map.i100 = map.contours.100m, map.i200 = map.contours.200m, 
      col.pal = col.pal, col.breaks = h.br, 
      asp = 0, ylim = c(34, 48), xaxt = "n", 
      main = paste("Humpback density", i)
    )
    legend_raimbow(h.br, "%0.2f", fill = rev(col.pal), cex = 1.2, title = "Whales/km2")
    legend.raimbow.bathy()
  } else {
    plot.new()
    text(0.5, 0.7, labels = "No humpback data", adj = 0.5, cex = 1.7)
  }
  
  if (f.curr %in% names(f.sf)) {
    plot_raimbow(
      f.sf, f.curr, NULL, map.base, 
      map.i050 = map.contours.050m, map.i100 = map.contours.100m, map.i200 = map.contours.200m, 
      col.pal = col.pal, col.breaks = f.br, 
      asp = 0, ylim = c(34, 48), xaxt = "n", 
      main = paste("Non-conf VMS density", i)  
    )
    legend_raimbow(f.br, NULL, fill = rev(col.pal), cex = 1.2, title = "Pings/km2")
    legend.raimbow.bathy()
  } else {
    plot.new()
    text(0.5, 0.7, labels = "No fishing data", adj = 0.5, cex = 1.7)
  }
  
  if (r.curr %in% names(r.sf)) {
    plot_raimbow(
      r.sf, r.curr, NULL, map.base, 
      map.i050 = map.contours.050m, map.i100 = map.contours.100m, map.i200 = map.contours.200m, 
      col.pal = col.pal, col.breaks = r.br, 
      asp = 0, ylim = c(34, 48), xaxt = "n", 
      main = paste("Risk (linear) dens", i)  
    )
    legend_raimbow(r.br, "%0.1f", fill = rev(col.pal), cex = 1.2, title = "Whales*Pings/km2")
    legend.raimbow.bathy()
  } else {
    plot.new()
    text(0.5, 0.7, labels = "No risk data", adj = 0.5, cex = 1.7)
  }
  
  dev.off()
}


###############################################################################
# ## Make GIF of heat maps
# library(magick)
# library(purrr)
# 
# plot.files <- list.files(path.plots, full.names = TRUE)
# plot.files[1]
# tail(plot.files, 1)
# 
# plot.files %>%  #3.5 hours for 140 (continuous color scheme) images
#   purrr::map(image_read) %>% 
#   image_join() %>% 
#   image_animate(fps = 2) %>% 
#   image_write(paste0(path.plots, "Whale_risk.gif"))

###############################################################################
