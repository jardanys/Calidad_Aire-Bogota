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
# Se tomas datos tomados el portal http://201.245.192.252:81/ con mediciones relevantes a la calidad
# del aire en Bogotá. Los datos contienen información del 22 de febrero de 2017 hora 06:00pm

#*************************
## Mediciones estaciones
#*************************
l<-list.files("./datos")[grepl(".*xlsx.*", list.files("./datos"))]

for(i in 1:length(l)){
      nombre <- str_split(l[i], "\\.")[[1]][1]
      p <- read_xlsx(paste0("./datos/",l[i]), sheet = 1)
      p$Station<-nombre
      assign(nombre, p); rm(p)
}

l <- unlist(str_split(l, "\\."))
l <- l[l!="xlsx"]

mediciones <- get(l[i])
for(i in 2:length(l)){
      mediciones <- rbind(mediciones, get(l[i]))
}
mediciones[is.na(mediciones)]<-0

rm(list = l); gc()

#************************
## ubicación estaciones
#************************

ubicaciones <- read.table("./datos/Ubicación Estaciones.csv", sep=";", header = T, fill=T)


# 3. Genera tabla final ####
#*********************************************

aireBogota <- mediciones %>%
              select(Station, Monitor, Value) %>%
              group_by(Station, Monitor) %>%
              summarise(valor=max(Value, na.rm=T)) %>%
              dcast(Station ~ Monitor, value.var = "valor")

aireBogota <- merge(aireBogota, ubicaciones, by.x="Station", by.y="Nombre.de.la.Estación", 
                    all.x=T, all.y=F) %>%
              select(Station, Longitude, Latitude, PM10=`PM10[µg/m3]`, PM2.5=`PM2.5[µg/m3]`)

write.table(aireBogota, "./TidyData/aireBogota.csv", sep=";", col.names = F)
save(aireBogota, file="./TidyData/aireBogota.RData")







