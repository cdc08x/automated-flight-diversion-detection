data <- read.csv2(
  file="../etc/alerts-of-bestfscorers-on-noks.csv",
  sep=";")

data$filenameNoExtension <- gsub('.xml', '', data$filename)
data$flightArea <- ifelse(grepl(pattern ="^[0-9][0-9]*$", x = data$filenameNoExtension), "EU", "US")
data$realFlightId <- ifelse(data$flightArea == "EU", data$filenameNoExtension, data$flightId)

data[c("filename","flightId","realFlightId","flightArea")]

data$firstEventDateTime <- as.POSIXct(as.character(data$firstEventDateTime))
data$lastEventDateTime <- as.POSIXct(as.character(data$lastEventDateTime))
data$predictionDateTime <- as.POSIXct(as.character(data$predictionDateTime))

data$timeSaved <- as.numeric(data$lastEventDateTime - data$predictionDateTime)
data$timeSavedHhMmSs <-    sprintf("%s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
                             ifelse(data$timeSaved < 0, "-", ""), # sign
                             abs(data$timeSaved) %/% 86400,  # days
                             abs(data$timeSaved) %% 86400 %/% 3600,  # hours
                             abs(data$timeSaved) %% 3600 %/% 60,  # minutes
                             abs(data$timeSaved) %% 60 %/% 1) # seconds

# data[1:20,c("firstEventDateTime","lastEventDateTime","predictionDateTime","timeSavedHhMmSs","timeSaved")]

print("Time saved w.r.t. the actual landing")
meanTimeSaved <- mean(data$timeSaved)
medianTimeSaved <- median(data$timeSaved)
minTimeSaved <- min(data$timeSaved)
maxTimeSaved <- max(data$timeSaved)
sprintf("Average: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(meanTimeSaved < 0, "-", ""), # sign
        abs(meanTimeSaved) %/% 86400,  # days
        abs(meanTimeSaved) %% 86400 %/% 3600,  # hours
        abs(meanTimeSaved) %% 3600 %/% 60,  # minutes
        abs(meanTimeSaved) %% 60 %/% 1) # seconds
sprintf("Median: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(medianTimeSaved < 0, "-", ""), # sign
        abs(medianTimeSaved) %/% 86400,  # days
        abs(medianTimeSaved) %% 86400 %/% 3600,  # hours
        abs(medianTimeSaved) %% 3600 %/% 60,  # minutes
        abs(medianTimeSaved) %% 60 %/% 1) # seconds
sprintf("Minimum: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(minTimeSaved < 0, "-", ""), # sign
        abs(minTimeSaved) %/% 86400,  # days
        abs(minTimeSaved) %% 86400 %/% 3600,  # hours
        abs(minTimeSaved) %% 3600 %/% 60,  # minutes
        abs(minTimeSaved) %% 60 %/% 1) # seconds
sprintf("Maximum: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(maxTimeSaved < 0, "-", ""), # sign
        abs(maxTimeSaved) %/% 86400,  # days
        abs(maxTimeSaved) %% 86400 %/% 3600,  # hours
        abs(maxTimeSaved) %% 3600 %/% 60,  # minutes
        abs(maxTimeSaved) %% 60 %/% 1) # seconds

# print("Alerts")
# data[c("filename","flightId","realFlightId","departureCode","arrivalCode","predictionDateTime","timeSaved","timeSavedHhMmSs")]

# print("Predicted diversions' filenames")
# data$filename

# print("Predicted diversions' flightIds")
# data$flightId

flightCodesForAlertsEUFile <- "../flights/flightCodes-forAlerts-EU.csv"

# print("Queries for diverted flightIds")
# paste("SELECT trackId, flightNumber, origin, destination FROM FlightEvents WHERE trackId in ('", paste( data[data$flightArea == "EU", c("realFlightId")], collapse="','" ), "') GROUP BY trackId, flightNumber",
##      " INTO OUTFILE '",
##      "../flights/flightCodes-forAlerts-EU.csv",
##      "' ",
##      "FIELDS TERMINATED BY ',' ",
##      "ENCLOSED BY '' ",
##      "LINES TERMINATED BY '\n'",
#      ";",
#      sep="")

plannedFlightTimesUS <- read.csv2(
  file="../flights/plannedfFlightTimes-forAlerts-US.csv",
  sep=","
)

plannedFlightTimesUS$flightTime <- as.difftime(as.character(plannedFlightTimesUS$flightTime), format="%H:%M:%S", units = "mins")

plannedFlightTimesEU <- read.csv2(
  file="../flights/plannedfFlightTimes-forAlerts-EU.csv",
  sep=","
)

plannedFlightTimesEU$flightTime <- as.difftime(as.character(plannedFlightTimesEU$flightTime), format="%H:%M:%S", units = "mins")
plannedFlightTimesEU$stopFlightTime <- as.difftime(as.character(plannedFlightTimesEU$stopFlightTime), format="%H:%M:%S", units = "mins")

dataEU <- data[data$flightArea == "EU",]
dataUS <- data[data$flightArea == "US",]

dataEU <- merge(x = dataEU, y = plannedFlightTimesEU[c("trackId","flightTime")], by.x = "realFlightId", by.y = "trackId", all.x = TRUE)
dataUS <- merge(x = dataUS, y = plannedFlightTimesUS[c("filenameNoXml","flightTime")], by.x = "filenameNoExtension", by.y = "filenameNoXml", all.x = TRUE)

data <- rbind(dataEU,dataUS)

data$timeSavedWrtETA <- data$firstEventDateTime + data$flightTime - data$predictionDateTime

meanTimeSavedWrtETA <- as.numeric(mean(data$timeSavedWrtETA[!is.na(data$timeSavedWrtETA)])) * 60
medianTimeSavedWrtETA <- as.numeric(median(data$timeSavedWrtETA[!is.na(data$timeSavedWrtETA)])) * 60
minTimeSavedWrtETA <- as.numeric(min(data$timeSavedWrtETA[!is.na(data$timeSavedWrtETA)])) * 60
maxTimeSavedWrtETA <- as.numeric(max(data$timeSavedWrtETA[!is.na(data$timeSavedWrtETA)])) * 60
print("Time saved w.r.t. the expected landing")
sprintf("Average: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(meanTimeSavedWrtETA < 0, "-", ""), # sign
        abs(meanTimeSavedWrtETA) %/% 86400,  # days
        abs(meanTimeSavedWrtETA) %% 86400 %/% 3600,  # hours
        abs(meanTimeSavedWrtETA) %% 3600 %/% 60,  # minutes
        abs(meanTimeSavedWrtETA) %% 60 %/% 1) # seconds
sprintf("Median: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(medianTimeSavedWrtETA < 0, "-", ""), # sign
        abs(medianTimeSavedWrtETA) %/% 86400,  # days
        abs(medianTimeSavedWrtETA) %% 86400 %/% 3600,  # hours
        abs(medianTimeSavedWrtETA) %% 3600 %/% 60,  # minutes
        abs(medianTimeSavedWrtETA) %% 60 %/% 1) # seconds
sprintf("Minimum: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(minTimeSavedWrtETA < 0, "-", ""), # sign
        abs(minTimeSavedWrtETA) %/% 86400,  # days
        abs(minTimeSavedWrtETA) %% 86400 %/% 3600,  # hours
        abs(minTimeSavedWrtETA) %% 3600 %/% 60,  # minutes
        abs(minTimeSavedWrtETA) %% 60 %/% 1) # seconds
sprintf("Maximum: %s%02d:%02d:%02d:%02d", # "%s%02d:%02d:%02d", 
        ifelse(maxTimeSavedWrtETA < 0, "-", ""), # sign
        abs(maxTimeSavedWrtETA) %/% 86400,  # days
        abs(maxTimeSavedWrtETA) %% 86400 %/% 3600,  # hours
        abs(maxTimeSavedWrtETA) %% 3600 %/% 60,  # minutes
        abs(maxTimeSavedWrtETA) %% 60 %/% 1) # seconds

# data[data$filenameNoExtension == "24936159",]
data[order(data$flightTime-data$timeSavedWrtETA),c("realFlightId","filename","departureCode","arrivalCode","firstEventDateTime","lastEventDateTime","flightTime","predictionDateTime","timeSavedWrtETA","timeSavedHhMmSs")]
# write.csv2(data[order(data$flightTime-data$timeSavedWrtETA),c("realFlightId","filename","departureCode","arrivalCode","flightTime","timeSavedWrtETA","timeSavedHhMmSs")])
names(data)
