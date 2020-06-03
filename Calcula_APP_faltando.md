---
title: "Calcula_APP_faltando"
author: "NEEDS"
date: "6/1/2020"
output: 
  html_document:
    keep_md: True
    toc: True
---

# Introdução

Nesse script buscamos identificar e quantificar as APPs que necessitam ser restauradas em Campina do Monte Alegre.

Exploramos um pouco as funções do pacote **sf**

# Setup, instala e carrega pacotes


```r
inline_hook <- function(x) {
  if (is.numeric(x)) {
    format(x, digits = 2)
  } else x
}
knitr::knit_hooks$set(inline = inline_hook)
```




```r
require(rgdal)
require(sf)
```

# Carrega os mapas e verifica dados

Carrega os mapas

```r
CMA_app_uso<-readOGR(dsn="./data_use",layer="SP_3509452_APP_USO")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "/cloud/project/data_use", layer: "SP_3509452_APP_USO"
## with 5 features
## It has 6 fields
```

```r
CMA_app<-readOGR(dsn="./data_use",layer="SP_3509452_APP")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "/cloud/project/data_use", layer: "SP_3509452_APP"
## with 5 features
## It has 7 fields
## Integer64 fields read as strings:  GEOCODIGO
```

```r
CMA_uso<-readOGR(dsn="./data_use",layer="SP_3509452_USO")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "/cloud/project/data_use", layer: "SP_3509452_USO"
## with 6 features
## It has 6 fields
```

Verifica APP_USO

```r
head(CMA_app_uso@data)
```

```
##   GEOCODIGO               MUNICIPIO UF CD_UF             CLASSE_USO    AREA_HA
## 0   3509452 CAMPINA DO MONTE ALEGRE SP    35       área antropizada 14063.5000
## 1   3509452 CAMPINA DO MONTE ALEGRE SP    35         área edificada   106.2360
## 2   3509452 CAMPINA DO MONTE ALEGRE SP    35     formação florestal  2078.7000
## 3   3509452 CAMPINA DO MONTE ALEGRE SP    35 formação não florestal    73.8172
## 4   3509452 CAMPINA DO MONTE ALEGRE SP    35           silvicultura  1925.9400
```

Verifica USO

```r
head(CMA_uso@data)
```

```
##   GEOCODIGO               MUNICIPIO UF CD_UF             CLASSE_USO    AREA_HA
## 0   3509452 CAMPINA DO MONTE ALEGRE SP    35                   água   271.2170
## 1   3509452 CAMPINA DO MONTE ALEGRE SP    35       área antropizada 14063.5000
## 2   3509452 CAMPINA DO MONTE ALEGRE SP    35         área edificada   106.2360
## 3   3509452 CAMPINA DO MONTE ALEGRE SP    35     formação florestal  2078.7000
## 4   3509452 CAMPINA DO MONTE ALEGRE SP    35 formação não florestal    73.8172
## 5   3509452 CAMPINA DO MONTE ALEGRE SP    35           silvicultura  1925.9400
```

Estranho, são iguais, com excecao da agua. Verificar nos outros municípios e na descrição do projeto deles.

Verifica APP

```r
head(CMA_app@data)
```

```
##   GEOCODIGO               MUNICIPIO UF CD_UF                    HIDRO APP_M
## 0   3509452 CAMPINA DO MONTE ALEGRE SP    35   curso d'água (0 - 10m)    30
## 1   3509452 CAMPINA DO MONTE ALEGRE SP    35  curso d'água (10 - 50m)    50
## 2   3509452 CAMPINA DO MONTE ALEGRE SP    35 curso d'água (50 - 200m)   100
## 3   3509452 CAMPINA DO MONTE ALEGRE SP    35             massa d'água    30
## 4   3509452 CAMPINA DO MONTE ALEGRE SP    35                 nascente    50
##     AREA_HA
## 0 1455.7100
## 1  384.9330
## 2  135.4960
## 3   58.3972
## 4  216.8800
```

Esse me parece que está correto.

# Cálculo das APPs

Para ver o que a função de baixo vai fazer, depois pode tirar.

```r
CMA_app_sf<-as(CMA_app, "sf")#transforma em objeto sf

CMA_app_sf_cast = st_cast(CMA_app_sf,"POLYGON") #explode em 

dim(CMA_app_sf)
dim(CMA_app_sf_cast)

CMA_app_exp<-as(CMA_app_sf_cast, "Spatial")
```

Funçao para explodir de multipart para singlepart. Deixei comentado o retorno para sp, deixando em sf, pq iremos usar funcao para sf na sequencia.

```r
explode<-function(sp){
  sp_sf<-as(sp, "sf") #transforma em sf
  sp_sf_cast = st_cast(sp_sf,"POLYGON") #explode 
  #sp_explodido<-as(sp_sf_cast, "Spatial")
}
```

Roda a função

```r
CMA_app_sf<-explode(CMA_app)
```

```
## Warning in st_cast.sf(sp_sf, "POLYGON"): repeating attributes for all sub-
## geometries for which they may not be constant
```

```r
CMA_uso_sf<-explode(CMA_uso)
```

```
## Warning in st_cast.sf(sp_sf, "POLYGON"): repeating attributes for all sub-
## geometries for which they may not be constant
```

```r
CMA_app_sf<-st_buffer(CMA_app_sf, 0)
CMA_uso_sf<-st_buffer(CMA_uso_sf, 0)
```

Clipa e organiza

```r
a<-st_intersection(CMA_uso_sf, CMA_app_sf)
```

```
## Warning: attribute variables are assumed to be spatially constant throughout all
## geometries
```

```r
a.col<-st_collection_extract(a, "POLYGON")
```

## Plota resultados no mapa
Plota para ver resultados no mapa

```r
plot(a.col["CLASSE_USO"], border="transparent")
```

<img src="Calcula_APP_faltando_files/figure-html/unnamed-chunk-10-1.png" style="display: block; margin: auto;" />

Calcula as áreas

```r
a.col$area<-st_area(a.col)
a.col$areaHa<-a.col$area/10000
a.col.df<-a.col
st_geometry(a.col.df)<-NULL

#head(a.col.df)
somatoria<-rowsum(a.col.df$areaHa, group=a.col.df$CLASSE_USO)
```

## Resultados quantitativos

```r
somatoria
```

```
##                                [,1]
## água                   1.827425e-04
## área antropizada       1.304508e+03
## área edificada         4.909395e-01
## formação florestal     8.511724e+02
## formação não florestal 1.283634e+01
## silvicultura           8.491236e+01
```


```r
colSums(somatoria)
```

```
## [1] 2253.921
```

```r
sum(CMA_app@data$AREA_HA)
```

```
## [1] 2251.416
```

Pequenas diferenças. Pode ser de somatoria e arredondamentos. Seria bom verificar.

O total de APP a ser restaurado em CMA é de 1390 ha, o que corresponde a 62 % do total de APPs do município.

## Resultados para APP de nascente

Separando a área (ha) por tipo de APP

```r
area_nasc<-rowsum(a.col.df$areaHa, group=a.col.df$HIDRO)
```


```r
area_nasc
```

```
##                                [,1]
## curso d'água (0 - 10m)   1458.21392
## curso d'água (10 - 50m)   384.93280
## curso d'água (50 - 200m)  135.49624
## massa d'água               58.39721
## nascente                  216.88049
```

Calculando o uso de solo dentro das APPs de nascente

```r
a.nasc<-a.col.df[a.col.df$HIDRO=="nascente",]
somatoria_nasc<-rowsum(a.nasc$areaHa, group=a.nasc$CLASSE_USO)
```


```r
somatoria_nasc
```

```
##                                [,1]
## água                   1.680720e-06
## área antropizada       1.490480e+02
## formação florestal     3.578399e+01
## formação não florestal 1.218865e+00
## silvicultura           3.082966e+01
```

O total de APP, dispostas em nascentes, a ser restaurado em CMA é de 180 ha, o que corresponde a 83 % do total de APPs presentes apenas em nascentes do município.
