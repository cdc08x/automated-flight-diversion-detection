# sudo apt-get install libproj-dev libgdal1-dev
# sudo R CMD javareconf
# sudo R : install.packages("OpenStreetMap")

library(ggplot2)
library(ggmap)
library(RMySQL)
library(plyr)
# require(OpenStreetMap)

HOME_DIR <- "/home/claudio/University/Pubs/flightmonitoring/code-and-data-repo/DiversionDetector/flightpicsmaking"
OUT_FOLDER <- paste(HOME_DIR, "gfx", sep = "/")

printer_friendly <- TRUE

if (showdiversionairport) {
  airshapes <- c("Destination", "Diversion", "Origin")
  airshapetypes <- data.frame( types = airshapes, shapes = c(12,8,14) )
} else {
  airshapes <- c("Destination", "Origin")
  airshapetypes <- data.frame( types = airshapes, shapes = c(12,14) )
}
speedcolours <- c("white","grey90","grey80","grey50","black")

options(width=240)

frDb <- dbConnect(MySQL(), user='fr24', password='fr24', dbname='flightradar24', host='get-service.ai.wu.ac.at')
# data <- dbReadTable(frDb, "FlightsWithStartAndEnd")

# for (trackId in 25011286) {
# for (trackId in trackIds$trackId) {
# for (trackId in 24845690) {
# for (trackId in trackIds) {

#### Not diverted (true negatives)
####
# trackId <- 24888970 # MUC to LHR
# divairportIATAFAA <- NONE
# DEFAULT_ZOOM <- 5
# diversioncheck <- FALSE
# showdiversionairport <- TRUE
# nolegend <- TRUE

#### Diverted and detected as such (true positives)
####
# trackId <- 24936159 # MUC to LHR
# divairportIATAFAA <- "MUC" # Munich Airport
# DEFAULT_ZOOM <- 5
# diversioncheck <- FALSE
# showdiversionairport <- TRUE
# nolegend <- TRUE

# trackId <- 24643263 # AYT to ARN
# divairportIATAFAA <- "SVG" # Stavanger, Sola Airport
# DEFAULT_ZOOM <- 4
# diversioncheck <- TRUE
# showdiversionairport <- TRUE
# nolegend <- FALSE

# trackId <- 24871421 # AYT to 
# divairportIATAFAA <- "TRD" # Trondheim Airport
# DEFAULT_ZOOM <- 3
# diversioncheck <- TRUE
# showdiversionairport <- TRUE
# nolegend <- FALSE

# trackId <- 24939815
# divairportIATAFAA <- "NCE" # Nice Côte d'Azur International Airport
# DEFAULT_ZOOM <- 5
# diversioncheck <- FALSE
# showdiversionairport <- TRUE
# nolegend <- TRUE

#### Diverted but not detected as such (false negatives)
####
trackId <- 24789661
divairportIATAFAA <- "STN" # London Stansted Airport
DEFAULT_ZOOM <- 5
diversioncheck <- FALSE
showdiversionairport <- TRUE
nolegend <- FALSE

    print(paste("Examining flight track no. ", trackId))
#    data <- read.csv2(file=paste(HOME_DIR,"/db-csv-samples/",trackId,"-flightData.csv", sep=""), sep=";")#dbGetQuery(frDb, paste("SELECT F.* FROM FlightEvents F WHERE F.trackId =", trackId, " AND F.origin IS NOT NULL AND F.destination IS NOT NULL ORDER BY F.eventTimestamp", sep=" "))
#    bgEnData <- read.csv2(file=paste(HOME_DIR,"/db-csv-samples/",trackId,"-bgEnData.csv", sep=""), sep=";")#dbGetQuery(frDb, paste("SELECT F.trackId, OrigA.latitude AS origAirpoLat, OrigA.longitude AS origAirpoLon, OrigA.city AS oriCity, OrigA.name AS oriName, DestinA.latitude AS destinAirpoLat, DestinA.longitude AS destinAirpoLon, DestinA.city AS destiCity, DestinA.name AS destiName FROM FlightEvents F, Airports OrigA, Airports DestinA WHERE F.origin = OrigA.IATAFAA AND F.destination = DestinA.IATAFAA AND F.trackId =", trackId, "GROUP BY trackId"))
#    unexpectedDestination <- read.csv2(file=paste(HOME_DIR,"/db-csv-samples/",trackId,"-diversionAirport.csv", sep=""), sep=";")#dbGetQuery(frDb, paste("SELECT DestinA.latitude AS destinAirpoLat, DestinA.longitude AS destinAirpoLon, DestinA.city AS destiCity, DestinA.name AS destiName FROM Airports DestinA WHERE DestinA.IATAFAA='MUC'"))
    
#    data$datetime <- as.POSIXct(as.numeric(as.character(data$eventTimestamp)), origin="1970-01-01")
#    data$speed <- as.double(as.character(data$speed))
#    data$latitude <- as.numeric(as.character(data$latitude))
#    data$longitude <- as.double(as.character(data$longitude))
#    data$altitude <- as.double(as.character(data$altitude))
#    bgEnData$origAirpoLat <- as.double(as.character(bgEnData$origAirpoLat))
#    bgEnData$origAirpoLon <- as.double(as.character(bgEnData$origAirpoLon))
#    bgEnData$destinAirpoLat <- as.double(as.character(bgEnData$destinAirpoLat))
#    bgEnData$destinAirpoLon <- as.double(as.character(bgEnData$destinAirpoLon))
#    unexpectedDestination$destinAirpoLat <- as.double(as.character(unexpectedDestination$destinAirpoLat))
#    unexpectedDestination$destinAirpoLon <- as.double(as.character(unexpectedDestination$destinAirpoLon))

    data <- dbGetQuery(frDb, paste("SELECT F.* FROM FlightEvents F WHERE F.trackId =", trackId, " AND F.origin IS NOT NULL AND F.destination IS NOT NULL ORDER BY F.eventTimestamp", sep=" "))
    bgEnData <- dbGetQuery(frDb, paste("SELECT F.trackId, OrigA.latitude AS origAirpoLat, OrigA.longitude AS origAirpoLon, OrigA.city AS oriCity, OrigA.name AS oriName, DestinA.latitude AS destinAirpoLat, DestinA.longitude AS destinAirpoLon, DestinA.city AS destiCity, DestinA.name AS destiName FROM FlightEvents F, Airports OrigA, Airports DestinA WHERE F.origin = OrigA.IATAFAA AND F.destination = DestinA.IATAFAA AND F.trackId =", trackId, "GROUP BY trackId"))

    data$datetime <- as.POSIXct(data$eventTimestamp, origin="1970-01-01")

    if (showdiversionairport) {
      unexpectedDestination <- dbGetQuery(frDb, paste("SELECT DISTINCT DestinA.latitude AS destinAirpoLat, DestinA.longitude AS destinAirpoLon, DestinA.city AS destiCity, DestinA.name AS destiName FROM Airports DestinA WHERE DestinA.IATAFAA='",divairportIATAFAA,"'", sep = ""))
      unexpectedDestination
    }
    if (diversioncheck) {
      checkedPoints <- read.csv2(file=paste(HOME_DIR,"/detectionlogfiles/",trackId,"-4x3-anomaliesDetected.csv", sep=""), header=TRUE, sep=";",quote='""', comment.char="#")
      checkedPoints$datetime <- gsub(x = checkedPoints$predictionDateTime, pattern = "([+-])([0-9][0-9]):([0-9][0-9])", replacement =  "\\1\\2\\3")
      checkedPoints$datetime <- as.POSIXct(checkedPoints$datetime,format='%Y-%m-%d %H:%M:%S%z')
      
      data <- merge(data, checkedPoints[,c("datetime","anomaly","distLeft","distGain","dspeed","dalt","firstAlert")], by.x="datetime", by.y="datetime", all.x = TRUE, sort = TRUE, suffixes = c(".x",".y"))
    }
        
#    print("data")
#    print(data)
#    print("checkedPoints")
#    print(checkedPoints)

    # data[data$datetime %in% checkedPoints$datetime,])
#    print("data")

    if (!(length(data) > 0 & length(bgEnData) > 0)) {
        quit()
    }

    quantiles.speed <- quantile(data$speed)
    if (max(data$speed) + min(data$speed) > 0) {
        quantiles.speed.scaled <- quantiles.speed / (max(data$speed) - min(data$speed))
        quantiles.speed.scaled[1] <- 0
    } else {
        quantiles.speed.scaled <- quantiles.speed
    }

    separationIndex <- which(tail(data$eventTimestamp,-1) > head(data$eventTimestamp,-1) + 30*60)
    if (is.integer(separationIndex) & length(separationIndex) > 0) {
#        data <- data[1:separationIndex[1],]
        print("Warning! Events are missing for 30 minutes in flight data at: ")
        print(data[separationIndex[1],])
    }

    data.minlat <- min(c( data$latitude, bgEnData$origAirpoLat, bgEnData$destinAirpoLat ))
    data.maxlat <- max(c( data$latitude, bgEnData$origAirpoLat, bgEnData$destinAirpoLat ))
    data.minlon <- min(c( data$longitude, bgEnData$origAirpoLon, bgEnData$destinAirpoLon ))
    data.maxlon <- max(c( data$longitude, bgEnData$origAirpoLon, bgEnData$destinAirpoLon ))
#    left/bottom/right/top bounding box
    boundingbox <- c(data.minlon, data.minlat, data.maxlon, data.maxlat)

## To find which row has some NA in some column
# print(data[unique (unlist (lapply (data, function (x) which (is.na (x))))),])
    custo_map <- get_map(location = boundingbox, zoom=DEFAULT_ZOOM, color="bw", crop = TRUE)
#    custo_map <- openmap(c(lat = data.maxlat + 5, lon = data.minlon - 5), c(lat = data.minlat - 5, lon = data.maxlon + 5), type=maptype)
#    custo_map <- openmap(c(lat = data.maxlat + 5, lon = data.minlon - 5), c(lat = data.minlat - 5, lon = data.maxlon + 5), type=maptype)
#    custo_map <- openmap(c(lat = 198, lon = -4), c(lat = -4, lon = 17), minNumTiles=9, type=maptype)
#    custo_map <- openproj(custo_map)

    pdf(paste(OUT_FOLDER, "/", trackId, "-nu-map.pdf", sep=""))
#    p <- ggmap(euro_map) +
    p <- ggmap(custo_map) +
         geom_path(data = data, aes(x = longitude, y = latitude), size=4, colour="white", alpha=0.75) +
         geom_point(data = data, aes(x = longitude, y = latitude, colour = speed)) +
         geom_path(data = data, aes(x = longitude, y = latitude), linetype="dashed")
    if (showdiversionairport) {
      p <- p + geom_point(data = unexpectedDestination, aes(x = destinAirpoLon, y = destinAirpoLat, shape="Diversion"), size=8)
#        geom_text(data = unexpectedDestination, aes(x = destinAirpoLon, y = destinAirpoLat + 1, label=paste(destiCity, "\n", "(", destiName, ")", sep="")), hjust=0.5, vjust=0, size=3, alpha=0.85, fontface="bold") +
    }
    
    p <- p +
        geom_point(data = bgEnData, aes(x = destinAirpoLon, y = destinAirpoLat, shape="Destination"), size=8) +
#        geom_text(data = bgEnData, aes(x = destinAirpoLon, y = destinAirpoLat + 0.75, label=paste(destiCity, "  (", destiName, ")", sep="")), hjust=0, vjust=0, size=3, alpha=0.85, fontface="bold") +
        geom_point(data = bgEnData, aes(x = origAirpoLon, y = origAirpoLat, shape="Origin"), size=8)
#        geom_text(data = bgEnData, aes(x = origAirpoLon - 0.5, y = origAirpoLat, label=paste(oriCity,"  ", "(", oriName, ")    ", sep="")), hjust=1, vjust=0.5, size=3, alpha=0.85, fontface="bold") + 
    if (diversioncheck) {
      p <- p +
        geom_text(data = data[!is.na(data$anomaly) & (data$firstAlert == 'Alert!'),], aes(x = longitude, y = latitude, label="    Diversion detected  "), hjust=1, vjust=0.5, size=4, alpha=0.85, angle=45, fontface="bold") +
        geom_point(data = data[!is.na(data$anomaly) & (data$firstAlert == 'Alert!'),], aes(x = longitude, y = latitude, size = altitude * 1.5), size=3, alpha = 0.5) +
        geom_point(data = data[!is.na(data$anomaly) & (data$firstAlert == 'Alert!'),], aes(x = longitude, y = latitude, size = altitude * 1.5), size=3, shape = 1)
    }
    p <- p +
        scale_x_continuous(limits = c(data.minlon -4, data.maxlon +4)) +
        scale_y_continuous(limits = c(data.minlat -1, data.maxlat +1)) +
#        labs(list(title = paste("Flight #", trackId, sep=""), colour = "Speed [mph]", size = "Altitude [feet]", shape = "Airport", x = "Longitude [deg]", y = "Latitude [deg]")) +
        # Without title
        labs(list(title = element_blank(), shape = "Airport", colour = "Speed [mph]", x = "Longitude [deg]", y = "Latitude [deg]")) +
#        guides(shape = guide_legend(override.aes = list(alpha = 1.0, colour="black"))) +
        scale_shape_manual(breaks = airshapetypes$types, values=airshapetypes$shapes)

    if (max(data$speed) + min(data$speed) > 0) {
        p <- p +
            scale_colour_gradientn(limits=c(min(data$speed), max(data$speed)), values=as.double(quantiles.speed.scaled), colours = speedcolours) +
          scale_fill_grey()
    }

    if (nolegend) {
      p <- p + theme(legend.position='none')
    }

    print(p)

    dev.off()
#}
