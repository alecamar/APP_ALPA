library(rgdal)
library(rgeos)
library(dplyr)
library(sp)
library(plotKML)
library(RgoogleMaps)
library(maptools)
library(jpeg)
library(ggmap)
library(raptr)
library(raster)

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

mapCMA<-GetMap(center=geocode , size=c(640,640), sensor="true",  maptype="satellite", 
               NEWMAP=TRUE, type="google-s", format= "jpg", tileDir = "./data_use")

PlotPolysOnStaticMap(mapCMA, CMA_app)##Essa linha esta com erro

str(mapCMA)
str(CMA_app, max.level=2)

CMA_app.p<-slot(CMA_app, "polygons")

data <- fortify(CMA_app)

cma.z13<-get_map(location = c(lon = -48.48019, lat = -23.59357),
             zoom = 13, scale = "auto", maptype = "satellite", source = "google", 
             force = ifelse(source == "google", TRUE, FALSE), messaging = FALSE, 
             crop = TRUE, color = "color", language = "en")


### Converte ggmap obj to raster

mgmap <- as.matrix(cma.z13)
vgmap <- as.vector(mgmap)
vgmaprgb <- col2rgb(vgmap)
gmapr <- matrix(vgmaprgb[1, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
gmapg <- matrix(vgmaprgb[2, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
gmapb <- matrix(vgmaprgb[3, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
rgmaprgb <- brick(raster(gmapr), raster(gmapg), raster(gmapb))
rm(gmapr, gmapg, gmapb)


projection(rgmaprgb) <- CRS("+init=epsg:3857")
extent(rgmaprgb) <- unlist(attr(cma, which = "bb"))[c(2, 4, 1, 3)]
rgmaprgb

plotRGB(rgmaprgb)

proj4string(rgmaprgb)

#ge<-projectRaster(rgmaprgb, crs=proj4string(CMA_app))

cma_app<-spTransform(CMA_app, CRS(proj4string(rgmaprgb)))
plotRGB(rgmaprgb)
#plot(cma_app, add=TRUE, col="red")
plot(cma_app, add=TRUE, border="red", col="red")
axis(1)

=======
PlotOnStaticMap(mapCMA)
PlotOnStaticMap(CMA_app, lat=lati, lon=long, col=(c("dark green","yellow","purple","blue","red")), add=TRUE)
#PlotPolysOnStaticMap(mapCMA, pol, col="yellow", border = "red", add = TRUE)##Essa linha esta com erro

>>>>>>> d52ae8bc35d0ef92f9ece7ddc33b33c71aa9414f
