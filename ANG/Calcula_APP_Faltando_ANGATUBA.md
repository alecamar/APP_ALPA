---
title: "Calcula_APP_faltando_Angatuba"
author: "NEEDS"
date: "21/06/2020"
output: 
  html_document:
    includes:
      after_body: footer.html
    keep_md: True
    toc: True
---
# Introdução

Nesse script buscamos identificar e quantificar as APPs que necessitam ser restauradas em Angatuba.

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
ANGA_app<-readOGR(dsn="./data_use",layer="SP_3502200_APP")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "/cloud/project/data_use", layer: "SP_3502200_APP"
## with 5 features
## It has 7 fields
## Integer64 fields read as strings:  GEOCODIGO
```

```r
ANGA_uso<-readOGR(dsn="./data_use",layer="SP_3502200_USO")
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: "/cloud/project/data_use", layer: "SP_3502200_USO"
## with 6 features
## It has 6 fields
```

Verifica USO

```r
head(ANGA_uso@data)
```

```
##   GEOCODIGO MUNICIPIO UF CD_UF             CLASSE_USO   AREA_HA
## 0   3502200  ANGATUBA SP    35                   água  1385.170
## 1   3502200  ANGATUBA SP    35       área antropizada 65224.700
## 2   3502200  ANGATUBA SP    35         área edificada   298.405
## 3   3502200  ANGATUBA SP    35     formação florestal 14061.400
## 4   3502200  ANGATUBA SP    35 formação não florestal   288.038
## 5   3502200  ANGATUBA SP    35           silvicultura 21629.900
```
Verifica APP

```r
head(ANGA_app@data)
```

```
##   GEOCODIGO MUNICIPIO UF CD_UF                    HIDRO APP_M   AREA_HA
## 0   3502200  ANGATUBA SP    35   curso d'água (0 - 10m)    30 10163.500
## 1   3502200  ANGATUBA SP    35  curso d'água (10 - 50m)    50  1162.770
## 2   3502200  ANGATUBA SP    35 curso d'água (50 - 200m)   100   286.386
## 3   3502200  ANGATUBA SP    35             massa d'água    30   266.207
## 4   3502200  ANGATUBA SP    35                 nascente    50  1688.720
```
# Cálculo das APPs

Para ver o que a função de baixo vai fazer, depois pode tirar.

```r
ANGA_app_sf<-as(ANGA_app, "sf")#transforma em objeto sf

ANGA_app_sf_cast = st_cast(ANGA_app_sf,"POLYGON") #explode em 

dim(ANGA_app_sf)
dim(ANGA_app_sf_cast)

ANGA_app_exp<-as(ANGA_app_sf_cast, "Spatial")
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
ANGA_app_sf<-explode(ANGA_app)
```

```
## Warning in st_cast.sf(sp_sf, "POLYGON"): repeating attributes for all sub-
## geometries for which they may not be constant
```

```r
ANGA_uso_sf<-explode(ANGA_uso)
```

```
## Warning in st_cast.sf(sp_sf, "POLYGON"): repeating attributes for all sub-
## geometries for which they may not be constant
```

```r
ANGA_app_sf<-st_buffer(ANGA_app_sf, 0)
ANGA_uso_sf<-st_buffer(ANGA_uso_sf, 0)
```
Clipa e organiza

```r
a<-st_intersection(ANGA_uso_sf, ANGA_app_sf)
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

<img src="Calcula_APP_Faltando_ANGATUBA_files/figure-html/unnamed-chunk-9-1.png" style="display: block; margin: auto;" />

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
## água                   6.258057e-04
## área antropizada       7.690545e+03
## área edificada         1.842001e+01
## formação florestal     5.357702e+03
## formação não florestal 4.130000e+01
## silvicultura           5.750222e+02
```


```r
colSums(somatoria)
```

```
## [1] 13682.99
```

```r
sum(ANGA_app@data$AREA_HA)
```

```
## [1] 13567.58
```

O total de APP a ser restaurado em Angatuba é de 8284 ha, o que corresponde a 61 % do total de APPs do município.

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
## curso d'água (0 - 10m)   10271.9179
## curso d'água (10 - 50m)   1162.8632
## curso d'água (50 - 200m)   286.4012
## massa d'água               266.2069
## nascente                  1695.6011
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
## água                   7.381792e-06
## área antropizada       1.234297e+03
## formação florestal     2.570669e+02
## formação não florestal 1.643753e+00
## silvicultura           2.025937e+02
```
O total de APP, dispostas em nascentes, a ser restaurado em Angatuba é de 1437 ha, o que corresponde a 85 % do total de APPs presentes apenas em nascentes do município.




