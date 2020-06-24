---
title: "Plot_APP_CMA"
author: "ACMartensen"
date: "5/25/2020"
output: 
  html_document:
    keep_md: True
    toc: True
---

# Inicializacao


Instala os pacotes necessarios. Mas precisa verificar se tah usando tudo isso mesmo

```r
list.of.packages <- c("rgdal", "rgeos", "dplyr", "sp", "plotKML", "RgoogleMaps", "maptools", "jpeg", "ggmap", "raptr", "raster")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) 

install.packages(new.packages)
```

Verificar se precisa de tudo isso mesmo

```r
library(rgdal)
```

```
## Warning: package 'rgdal' was built under R version 3.6.1
```

```
## Loading required package: sp
```

```
## rgdal: version: 1.4-4, (SVN revision 833)
##  Geospatial Data Abstraction Library extensions to R successfully loaded
##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
##  Path to GDAL shared files: C:/Users/alecamar/Documents/R/win-library/3.6/rgdal/gdal
##  GDAL binary built with GEOS: TRUE 
##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
##  Path to PROJ.4 shared files: C:/Users/alecamar/Documents/R/win-library/3.6/rgdal/proj
##  Linking to sp version: 1.3-1
```

```r
library(rgeos)
```

```
## Warning: package 'rgeos' was built under R version 3.6.1
```

```
## rgeos version: 0.5-1, (SVN revision 614)
##  GEOS runtime version: 3.6.1-CAPI-1.10.1 
##  Linking to sp version: 1.3-1 
##  Polygon checking: TRUE
```

```r
library(dplyr)
```

```
## Warning: package 'dplyr' was built under R version 3.6.3
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:rgeos':
## 
##     intersect, setdiff, union
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library(sp)
library(plotKML)
```

```
## Warning: package 'plotKML' was built under R version 3.6.1
```

```
## Registered S3 method overwritten by 'xts':
##   method     from
##   as.zoo.xts zoo
```

```
## plotKML version 0.5-9 (2019-01-04)
```

```
## URL: http://plotkml.r-forge.r-project.org/
```

```r
library(RgoogleMaps)
```

```
## Warning: package 'RgoogleMaps' was built under R version 3.6.3
```

```r
library(maptools)
```

```
## Checking rgeos availability: TRUE
```

```r
library(jpeg)
```

```
## Warning: package 'jpeg' was built under R version 3.6.1
```

```r
library(ggmap)
```

```
## Warning: package 'ggmap' was built under R version 3.6.3
```

```
## Loading required package: ggplot2
```

```
## Warning: package 'ggplot2' was built under R version 3.6.3
```

```
## Google's Terms of Service: https://cloud.google.com/maps-platform/terms/.
```

```
## Please cite ggmap if you use it! See citation("ggmap") for details.
```

```r
library(raptr)
```

```
## Warning: package 'raptr' was built under R version 3.6.3
```

```
## Loading required package: raster
```

```
## Warning: package 'raster' was built under R version 3.6.1
```

```
## 
## Attaching package: 'raster'
```

```
## The following object is masked from 'package:dplyr':
## 
##     select
```

```
## The gorubi software is not installed
```

```
## Follow these instructions to download the Gurobi software suite:
##    http://bit.ly/1MrjXWc
## 
## The Gurobi R package requires a Gurobi license to work:
##   visit this web-page for an overview: http://bit.ly/1OHEQCm
##   academics can obtain a license at no cost here: http://bit.ly/1iYg3LX
## 
## Follow these instructions to install the "gurobi" R package:
##    http://bit.ly/1MMSZaH
```

```
## 
## 
## Type the code "is.GurobiInstalled()" to check if Gurobi is
## succesfully installed after following these instructions.
```

```
## 
## Attaching package: 'raptr'
```

```
## The following object is masked from 'package:maptools':
## 
##     SpatialPolygons2PolySet
```

```r
library(raster)
```


Carrega os dados das APPS

```r
CMA_app<-readOGR(dsn="./data_use",layer="SP_3509452_APP")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "F:\Google_Drive\UFSCar\Extensao\APP\APP_ALPA\data_use", layer: "SP_3509452_APP"
## with 5 features
## It has 7 fields
## Integer64 fields read as strings:  GEOCODIGO
```

# Analises

## Dados gerais de app

Verifica dados APPs

```r
cbind(CMA_app@data[,2], CMA_app@data[,5:7])
```

```
##         CMA_app@data[, 2]                     HIDRO APP_M   AREA_HA
## 0 CAMPINA DO MONTE ALEGRE   curso d'Ã¡gua (0 - 10m)    30 1455.7100
## 1 CAMPINA DO MONTE ALEGRE  curso d'Ã¡gua (10 - 50m)    50  384.9330
## 2 CAMPINA DO MONTE ALEGRE curso d'Ã¡gua (50 - 200m)   100  135.4960
## 3 CAMPINA DO MONTE ALEGRE             massa d'Ã¡gua    30   58.3972
## 4 CAMPINA DO MONTE ALEGRE                  nascente    50  216.8800
```

Plota dados apps

```r
plot(CMA_app, col = "transparent", border="transparent")

app_cda_0_10 <- CMA_app@data$HIDRO == "curso d'Ã¡gua (0 - 10m)"
plot(CMA_app[app_cda_0_10,], col = "dark green", border="transparent", add=TRUE)

app_cda_10_50<- CMA_app@data$HIDRO == "curso d'Ã¡gua (10 - 50m)"
plot(CMA_app[app_cda_10_50,], col = "yellow", border="transparent", add=TRUE)

app_cda_50_200<- CMA_app@data$HIDRO == "curso d'Ã¡gua (50 - 200m)"
plot(CMA_app[app_cda_50_200,], col = "purple", border="transparent", add=TRUE)

mda<- CMA_app@data$HIDRO == "massa d'Ã¡gua"
plot(CMA_app[mda,], col = "blue", border="transparent", add=TRUE)

app_nascente<- CMA_app@data$HIDRO == "nascente"
plot(CMA_app[app_nascente,], col = "red", border="transparent", add=TRUE)
nasc<-CMA_app[app_nascente,]
legend("bottomleft", c("APP curso d'água 0 - 10m", "APP curso d'água 10 - 50m", "APP curso d'água 50 - 200m", "APP nascentes", "Massa d'água"), fill=c("dark green", "yellow", "purple", "red", "orange"))
axis(1)
axis(2)
```

<img src="Plot_APP_CMA_no_rmd_files/figure-html/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />


```r
a<-disaggregate(CMA_app[app_nascente,])

str(a, max.level = 2)
```

```
## Formal class 'SpatialPolygonsDataFrame' [package "sp"] with 5 slots
##   ..@ data       :'data.frame':	289 obs. of  7 variables:
##   ..@ polygons   :List of 289
##   ..@ plotOrder  : int [1:289] 237 204 90 111 233 32 177 248 142 184 ...
##   ..@ bbox       : num [1:2, 1:2] 751361 7375671 768470 7397614
##   .. ..- attr(*, "dimnames")=List of 2
##   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
```

```r
area_nasc<-((pi*50^2)*length(a@polygons))/10000
```

Em CMA são 289 nascentes com área total de 226.98ha

## Gera os kmls


```r
plotKML(CMA_app, folder.name = normalizeFilename(deparse(substitute(CMA_app, env = parent.frame()))), 
        file.name = paste("APP_CMA", ".kml"), plot.labpt = TRUE, balloon=TRUE)
```

Gera kml para as nascentes

```r
nasc<-CMA_app[app_nascente,]
plotKML(nasc, folder.name = normalizeFilename(deparse(substitute(nasc, env = parent.frame()))), 
        file.name = paste("nasc", ".kml"), plot.labpt = TRUE, balloon=TRUE) 
```

```
## Plotting the first variable on the list
```

```
## KML file opened for writing...
```

```
## Reprojecting to +proj=longlat +datum=WGS84 ...
```

```
## Writing to KML...
```

```
## Closing  nasc .kml
```

```
## [1] 37
```

## Plota cm imagem do GE de fundo

```r
geocode<-getGeoCode("Campina do Monte Alegre, São Paulo, Brasil", API = c("osm", "google")[1], JSON = FALSE,
                    verbose = 0)

mapCMA<-GetMap(center=geocode , size=c(640,640), sensor="true",  maptype="satellite", 
               NEWMAP=TRUE, type="google-s", format= "jpg", tileDir = "./data_use")

PlotPolysOnStaticMap(mapCMA, CMA_app)##Essa linha esta com erro
```

Baixa imagem do GE com o **get_map**

```r
cma<-get_map(location = c(lon = -48.48019, lat = -23.59357),
             zoom = 11, scale = "auto", maptype = "satellite", source = "google", 
             force = ifelse(source == "google", TRUE, FALSE), messaging = FALSE, 
             crop = TRUE, color = "color", language = "en")
```

```
## Source : https://maps.googleapis.com/maps/api/staticmap?center=-23.59357,-48.48019&zoom=11&size=640x640&scale=2&maptype=satellite&language=en&key=xxx
```

Converte ggmap obj to raster

```r
### Converte ggmap obj to raster

mgmap <- as.matrix(cma)
vgmap <- as.vector(mgmap)
vgmaprgb <- col2rgb(vgmap)
gmapr <- matrix(vgmaprgb[1, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
gmapg <- matrix(vgmaprgb[2, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
gmapb <- matrix(vgmaprgb[3, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
rgmaprgb <- brick(raster(gmapr), raster(gmapg), raster(gmapb))
rm(gmapr, gmapg, gmapb)
```

Projeta a imagem baixada

```r
projection(rgmaprgb) <- CRS("+init=epsg:4326")#chute...
extent(rgmaprgb) <- unlist(attr(cma, which = "bb"))[c(2, 4, 1, 3)]
rgmaprgb
```

```
## class      : RasterBrick 
## dimensions : 1280, 1280, 1638400, 3  (nrow, ncol, ncell, nlayers)
## resolution : 0.0003433228, 0.0003146223  (x, y)
## extent     : -48.69957, -48.26012, -23.79509, -23.39237  (xmin, xmax, ymin, ymax)
## crs        : +init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## source     : memory
## names      : layer.1, layer.2, layer.3 
## min values :       0,      10,       7 
## max values :     254,     254,     254
```

Plota o mapa RGB teste

```r
plotRGB(rgmaprgb)
```

![](Plot_APP_CMA_no_rmd_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

Ajusta a projecao das APPs para a mesma do mapa baixado do GE

```r
cma_app<-spTransform(CMA_app, CRS(proj4string(rgmaprgb)))
```

Plota tudo

```r
plotRGB(rgmaprgb)
#plot(cma_app, add=TRUE, col="red")
plot(cma_app, add=TRUE, border="red", col="red")
```

![](Plot_APP_CMA_no_rmd_files/figure-html/unnamed-chunk-12-1.png)<!-- -->

```r
#axis(1)
```


Verifica nascentes

```r
plot(nasc)
axis(1)
axis(2)
```

![](Plot_APP_CMA_no_rmd_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

Ajusta a projecao das nascentes para a mesma do mapa baixado do GE

```r
cma_nasc<-spTransform(nasc, CRS(proj4string(rgmaprgb)))
```

Plota tudo

```r
plotRGB(rgmaprgb)
#plot(cma_app, add=TRUE, col="red")
plot(cma_nasc, add=TRUE, border="red", col="red")
```

![](Plot_APP_CMA_no_rmd_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

```r
#axis(1)
```









