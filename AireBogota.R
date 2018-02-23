#****************************************************************************************************************
#*****************************    ESTADÍSTICA ESPACIAL - KRIGING UNIVERSAL     **********************************
#****************************************************************************************************************
source("fun.R")
options(scipen=999)

# 0. Cargue de librerías ####
#*********************************************
load.lib("dplyr", "scales", "tidyr", "rgeos", "sp", "maptools", "car", "geoR", 
         "gstat", "stringr", "reshape2", "RColorBrewer", "readxl")


# 1. Cargue información ####
#*********************************************
# Se toman datos tomados el portal http://201.245.192.252:81/ con mediciones relevantes a la calidad
# del aire en Bogotá. Los datos contienen información del 22 de febrero de 2017 hora 06:00pm

# Mediciones aire Bogotá
load("./TidyData/aireBogota.RData")

# Capa de Bogotá sin localidad de sumapaz
bogota = readShapePoly("./localidades1/localidades_WGS84.shp")

# Puntos de ubicación empresas
xy = SpatialPoints(aireBogota[c("Longitude", "Latitude")])

# 2. Análisis Gráfico ####
#*********************************************

# Gráfico de la capa y las ubicaciones de las empresas que se encuentran afiliadas
plot(bogota)
points(xy, pch = 3, cex = 0.3, col = "red")
title(main="Ubicación empresas en Bogotá")

# Análisis descriptivo para la cantidad de afiliados por empresa
#par(mfrow = c(1, 3))
hist(aireBogota$PM10, freq = FALSE, main = "", breaks=10, col="gray", xlim=c(0, 90),
     xlab = "PM10", ylab = "Frecuencia")

hist(aireBogota$PM2.5, freq = FALSE, main = "", breaks=10, col="gray", xlim=c(0, 90),
     xlab = "PM2.5", ylab = "Frecuencia")
## 3. Análisis de estacionariedad
#*******************************************

# Se aprecia tendencia en la variación de los datos en las dos direcciones
scatterplot(PM10~Longitude, reg.line=lm, smooth=TRUE, spread=TRUE, boxplots=FALSE, span=0.5, data=aireBogota)
scatterplot(PM10~Latitude, reg.line=lm, smooth=TRUE, spread=TRUE, boxplots=FALSE, span=0.5, data=aireBogota)

# Creamos objeto geodata para semivariograma
geo_aire <- select(as.data.frame(aireBogota), Longitude, Latitude, PM10)
geo_aire = as.geodata(geo_aire, coords.col = 1:2, data.col = 3)

# Estimación del variograma
var = variog(geo_aire, direction = "omnidirectional")
plot(var)

ev <- eyefit(var)


