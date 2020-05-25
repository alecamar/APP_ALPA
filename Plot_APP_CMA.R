library(rgdal)
library(rgeos)
library(dplyr)
library(sp)
library(plotKML)
library(RgoogleMaps)
library(maptools)
library(jpeg)

##################Carregar exclusivamente APPS#####################

CMA_app<-readOGR(dsn="./data_use",layer="SP_3509452_APP")
cbind(CMA_app@data[,2], CMA_app@data[,5:7])

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
legend("topright", c("APP curso d'água 0 - 10m", "APP curso d'água 10 - 50m", "APP curso d'água 50 - 200m", "APP nascentes", "Massa d'água"), fill=c("dark green", "yellow", "purple", "red", "orange"))
axis(1)
axis(2)

#################################Calculo de area de APP de Nascente que deveria existir####################################3

a<-disaggregate(CMA_app[app_nascente,])

str(a, max.level = 2)

area_nasc<-((pi*50^2)*289)/10000

########################################Código para a criação de um .kml (google earth) *não funciona 100%*##########################

names(CMA_app)

##os plots funcionam, criando os .kml, mas exporta apenas pontos e não os poligonos
plotKML(CMA_app, folder.name = normalizeFilename(deparse(substitute(CMA_app, env = parent.frame()))), 
        file.name = paste("APP_CMA", ".kml"), plot.labpt = TRUE, balloon=TRUE)

plotKML(nasc, folder.name = normalizeFilename(deparse(substitute(nasc, env = parent.frame()))), 
        file.name = paste("nasc", ".kml"), plot.labpt = TRUE, balloon=TRUE) 

#?plotKML

######################################### Plotar mapa de APPs com imagem do Google earth de fundo *Não Funciona*########################

geocode<-getGeoCode("Campina do Monte Alegre, São Paulo, Brasil", API = c("osm", "google")[1], JSON = FALSE,
                    verbose = 0)
str(mapCMA)
class(CMA_app)
class(CMA_app.p)
str(CMA_app.p, max.level = 2)
CMA_app.p<-slot(CMA_app, "polygons")
pol = SpatialPolygons(CMA_app.p)

mapCMA<-GetMap(center=geocode , size=c(640,640), sensor="true",  maptype="satellite", 
               NEWMAP=TRUE, type="google-s", format= "jpg", tileDir = "./data_use")

PlotOnStaticMap(mapCMA)

PlotPolysOnStaticMap(mapCMA, pol, col = "transparent", border = "red")##Essa linha esta com erro

