---
title: "dlMAPA_ALPA"
author: "JCLAraujo"
date: "20/05/2020"
output: 
  html_document:
    keep_md: True
  
---


# Introdução
Aqui vamos apenas carregar os mapas baixados da semana passada e plota-los no R

# Passos
Para conseguir usar o comando para a leitura do shapefile será necessário que rgdal esteja instalado e ativo.

```r
install.packages(c('raster', 'sp', 'rgdal', 'dplyr', 'XML', 'curl'))
```

Load packages

```r
library(raster)
```

```
## Loading required package: sp
```

```r
library(sp)
library(rgdal)
```

```
## rgdal: version: 1.4-8, (SVN revision 845)
##  Geospatial Data Abstraction Library extensions to R successfully loaded
##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
##  Path to GDAL shared files: C:/Users/acmar/Documents/R/win-library/3.6/rgdal/gdal
##  GDAL binary built with GEOS: TRUE 
##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
##  Path to PROJ.4 shared files: C:/Users/acmar/Documents/R/win-library/3.6/rgdal/proj
##  Linking to sp version: 1.3-2
```

```r
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:raster':
## 
##     intersect, select, union
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
library(XML)
library(curl)
```

Script para download dos dados.

```r
dir.create("./data_use")

#CMA
lista.files.uso.cma = readLines('http://geo.fbds.org.br/SP/CAMPINA_DO_MONTE_ALEGRE/USO/')
lista.files.app.cma = readLines('http://geo.fbds.org.br/SP/CAMPINA_DO_MONTE_ALEGRE/APP/')

lks.lista<-c(lista.files.uso.cma,lista.files.app.cma)
lks<-getHTMLLinks(lks.lista, xpQuery = "//a/@href[contains(., 'SP')]")
for (i in 1:(length(lks))){
  destf<-paste("./data_use", strsplit(lks[i], "/")[[1]][5], sep="/")
  curl_download((paste("http://geo.fbds.org.br", lks[i], sep="")),destfile = destf)
}
```

Aqui começamos a carregar os mapas para o R. O comando responsável em carregar o shapefile como SpatialPolygonsDataFrame para dentro do R é o readOGR.


```r
CMA_uso<-readOGR(dsn="./data_use",layer="SP_3509452_USO")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "G:\My Drive\UFSCar\Projetos\teste\APPs_ALPA\data_use", layer: "SP_3509452_USO"
## with 6 features
## It has 6 fields
```

```r
CMA_app<-readOGR(dsn="./data_use",layer="SP_3509452_APP")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "G:\My Drive\UFSCar\Projetos\teste\APPs_ALPA\data_use", layer: "SP_3509452_APP"
## with 5 features
## It has 7 fields
## Integer64 fields read as strings:  GEOCODIGO
```

```r
CMA_all<-readOGR(dsn="./data_use",layer="SP_3509452_APP_USO")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "G:\My Drive\UFSCar\Projetos\teste\APPs_ALPA\data_use", layer: "SP_3509452_APP_USO"
## with 5 features
## It has 6 fields
```

Nota-se que o "dsn" é o diretório do arquivo, sem o nome do shapefile, que deve ser colocado no "layer" sem a extensão. Isso faz com que todos os arquivos com o mesmo nome sejam carregados, pegando dessa forma todas as informações necessárias.

Para a visualização dos mapas basta usar o comando plot(obj), sendo o "obj" o objeto em que o mapa foi salvo dentro do R

Plotando o uso do solo

```r
plot(CMA_uso, col = "transparent", border="transparent")

flo <- CMA_uso@data$CLASSE_USO == "formaÃ§Ã£o florestal"
plot(CMA_uso[flo,], col = "dark green", border="transparent", add=TRUE)

urb<- CMA_uso@data$CLASSE_USO == "Ã¡rea edificada"
plot(CMA_uso[urb,], col = "red", border="transparent", add=TRUE)

sil<- CMA_uso@data$CLASSE_USO == "silvicultura"
plot(CMA_uso[sil,], col = "purple", border="transparent", add=TRUE)

ant<- CMA_uso@data$CLASSE_USO == "Ã¡rea antropizada"
plot(CMA_uso[ant,], col = "orange", border="transparent", add=TRUE)

nfl<- CMA_uso@data$CLASSE_USO == "formaÃ§Ã£o nÃ£o florestal"
plot(CMA_uso[ant,], col = "yellow", border="transparent", add=TRUE)

legend("topright", c("Floresta", "Formação n Flor", "Silvicultura", "Edificacoes", "Area Antropizada"), fill=c("dark green", "yellow", "purple", "red", "orange"))
axis(1)
axis(2)
```

<div class="figure" style="text-align: center">
<img src="dlMAPA_ALPA_files/figure-html/CMA_uso-1.png" alt="Uso e cobertura do solo de CMA"  />
<p class="caption">Uso e cobertura do solo de CMA</p>
</div>



```r
plot(CMA_uso, col = "transparent", border="transparent")

flo <- CMA_uso@data$CLASSE_USO == "formaÃ§Ã£o florestal"
plot(CMA_uso[flo,], col = "dark green", border="transparent", add=TRUE)

legend("topright", "Floresta", fill="dark green")
```

<div class="figure" style="text-align: center">
<img src="dlMAPA_ALPA_files/figure-html/CMA_floresta-1.png" alt="Florestas de CMA"  />
<p class="caption">Florestas de CMA</p>
</div>


```r
plot(CMA_all, col = "transparent", border="transparent")

flo <- CMA_all@data$CLASSE_USO == "formaÃ§Ã£o florestal"
plot(CMA_all[flo,], col = "dark green", border="transparent", add=TRUE)

urb<- CMA_all@data$CLASSE_USO == "Ã¡rea edificada"
plot(CMA_all[urb,], col = "red", border="transparent", add=TRUE)

sil<- CMA_all@data$CLASSE_USO == "silvicultura"
plot(CMA_all[sil,], col = "purple", border="transparent", add=TRUE)

ant<- CMA_all@data$CLASSE_USO == "Ã¡rea antropizada"
plot(CMA_all[ant,], col = "orange", border="transparent", add=TRUE)

nfl<- CMA_all@data$CLASSE_USO == "formaÃ§Ã£o nÃ£o florestal"
plot(CMA_all[ant,], col = "yellow", border="transparent", add=TRUE)

legend("topright", c("Floresta", "Formação n Flor", "Silvicultura", "Edificacoes", "Area Antropizada"), fill=c("dark green", "yellow", "purple", "red", "orange"))
axis(1)
axis(2)
```

<div class="figure" style="text-align: center">
<img src="dlMAPA_ALPA_files/figure-html/uso apps-1.png" alt="Uso e cobertura APPs"  />
<p class="caption">Uso e cobertura APPs</p>
</div>



```r
plot(CMA_all)
```

<img src="dlMAPA_ALPA_files/figure-html/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

Tipos de APPs

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

