---
title: "MW_APP_BURI"
author: "NEEDS"
date: "08/06/2020"
output: 
  html_document:
    includes:
      after_body: footer.html
    keep_md: True
    toc: True
---

# Introdução

Nesse script buscamos usar a técnica de "Moving Window" para avaliar os potenciais corredores de vegetação nativa no município de Buri, SP. 

Nosso objetivo com essa análise é subsidiar estratégias para a priorização de áreas para a restauração.

# instalando e carregando os pacotes necessários

Verifica se os pacotes necessários estão instalados


Carrega os pacotes necessários 

```r
require(raster)
```

# Carregando os dados

Carrega o raster de 2007 e de 2017

```r
r07<-raster("./data_use/raster/RASTER_BURI_07.tif")
r17<-raster("./data_use/raster/RASTER_BURI_017.tif")
```
# Análises

## Reclassificando
Primeiro iremos reclassificar ambos os rasters, para transformar a vegetação nativa em 1 e todo o resto em 0.

```r
r07[r07 < 3] <- 0
r07[r07 > 3] <- 0
r07[r07 == 3] <- 1

r17[r17 < 3] <- 0
r17[r17 > 3] <- 0
r17[r17 == 3] <- 1
```


## Criando as janelas voadoras

Agora iremos criar as janelas voadoras. Iremos definir o tamanho desas janelas. Lembrando que esse tamanho é dado em número de pixels, e ele precisa sempre ser impar, para ter o pixel focal no meio. Existem outras formas de se fazer essas janelas, inclusive dando grande flexibilidade para tamanho e formato, mas não iremos usar no momento.


```r
m11<-matrix(1, nrow=11, ncol=11)
m15<-matrix(1, nrow=15, ncol=15)
m21<-matrix(1, nrow=21, ncol=21)
```

## Rodando o MW (funcao focal)
Aplica MW no raster referente a 2007

```r
r07.m11.focal<-focal(r07, m11, fun=mean)
r07.m15.focal<-focal(r07, m15, fun=mean)
r07.m21.focal<-focal(r07, m21, fun=mean)
```

Aplica o MW no raster referente a 2017

```r
r17.m11.focal<-focal(r17, m11, fun=mean)
r17.m15.focal<-focal(r17, m15, fun=mean)
r17.m21.focal<-focal(r17, m21, fun=mean)
```

## Potando os resultados

Plota o MW para 2007

```r
par(mfrow=c(1,3))
plot(r07.m11.focal, main="2007, 330m")
plot(r07.m15.focal, main="2007, 450m")
plot(r07.m21.focal, main="2007, 630m")
```

<img src="MW_FF_BURI_files/figure-html/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />
Plota o MW para 2017

```r
par(mfrow=c(1,3))
plot(r17.m11.focal, main="2017, 330m")
plot(r17.m15.focal, main="2017, 450m")
plot(r17.m21.focal, main="2017, 630m")
```

<img src="MW_FF_BURI_files/figure-html/unnamed-chunk-9-1.png" style="display: block; margin: auto;" />
