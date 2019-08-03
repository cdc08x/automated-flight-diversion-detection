import logging

predictLogger = logging.getLogger(__name__)

def predictDiversion(trajectory, classification, decfunout, threshold):
    severities = computeSeverities(trajectory, decfunout, threshold)
    (diversionDetections, firstDetectionIndex) = catchDiversionAlerts(trajectory, classification, threshold)
    printResultsAsCSV(diversionDetections, classification, firstDetectionIndex, decfunout, severities, trajectory)
    if firstDetectionIndex is not None:
        predictLogger.debug("Diversion predicted for flight %s" %trajectory.flightId)
        printAlert(trajectory, classification, decfunout, severities, firstDetectionIndex)
        return True, severities, trajectory.positions[firstDetectionIndex]
    return False, severities, None

def computeSeverities(trajectory, distances, threshold):
    severity = 0.0
    severities = []
    i = 0
    j = 0
    k = 0

    while k < len(trajectory.positions) - len(distances):
        severities.append(0.0)
        k += 1

    while i < len(distances):
        severity = 0.0
        j = i
        while j >= 0:
            severity += distances[j]
            j -= 1
        severities.append(severity)
        i += 1
    
    return severities

def catchDiversionAlerts(trajectory, classification, threshold):
    numOfConsecutiveAnomalies = 0
    diversionDetections = []
    firstDetectionIndex = None
    i = 0
    j = 0
    while i < len(trajectory.positions) - len(classification):
        diversionDetections.append(False)
        i += 1
    while j < len(classification):
        if classification[j] == -1:
            numOfConsecutiveAnomalies += 1
        else:
            numOfConsecutiveAnomalies = 0
        diversionDetections.append(numOfConsecutiveAnomalies >= threshold);
        if diversionDetections[i+j] and firstDetectionIndex is None:
            firstDetectionIndex = i+j
        j += 1
    return diversionDetections, firstDetectionIndex

def printAlert(trajectory, classification, decfunout, severities, firstDetectionIndex):
    alertString = "\n"
    alertString += "div-alert-flightid:%s\n" %trajectory.flightId
    alertString += "div-alert-aircraftid:%s\n" %trajectory.aircraftId
    alertString += "div-alert-flightcode:%s\n" %trajectory.flightCode
    alertString += "div-alert-origin:%s\n" %(trajectory.origin.code)
    alertString += "div-alert-departurelatitude:%s\n" %trajectory.origin.position.lat
    alertString += "div-alert-departurelongitude:%s\n" %trajectory.origin.position.lon
    alertString += "div-alert-destination:%s\n" %(trajectory.destination.code)
    alertString += "div-alert-arrivallatitude:%s\n" %trajectory.destination.position.lat
    alertString += "div-alert-arrivallongitude:%s\n" %trajectory.destination.position.lon
    alertString += "div-alert-certainty:%s\n" %severities[firstDetectionIndex]
    alertString += "div-alert-latitude:%s\n" %trajectory.positions[firstDetectionIndex].lat
    alertString += "div-alert-longitude:%s\n" %trajectory.positions[firstDetectionIndex].lon
    alertString += "div-alert-timestamp:%s\n" %trajectory.positions[firstDetectionIndex].date
    predictLogger.debug("Diversion detection alert%s" %alertString)

def printResultsAsCSV(diversionDetections, classification, firstDetectionIndex, decfunout, severities, trajectory):
    try:
        data = trajectory.getVectors()
        positions = trajectory.getPositions()
        # header
        csv = "action-code;filename;flightId;departureCode;arrivalCode;firstEventDateTime;lastEventDateTime;predictionDateTime;latitude;longitude;speed;altitude;distLeft;distGain;dspeed;dalt;anomaly;distance;severity;diversionDetected;firstAlert\n"
        
        i = 0
        j = 0
        while (i < len(positions) - len(classification)):
            csv = csv + "%s;%s;%s;%s;%s;%s;%s;%s;%f;%f;%d;%d;%s;%s;%s;%s;%s;%f;%f;%s;%s\n" %("div-check",trajectory.filename, trajectory.flightId, trajectory.origin.code, trajectory.destination.code, trajectory.positions[0].date, trajectory.positions[-1].date, positions[i].date, positions[i].lat, positions[i].lon, positions[i].speed, positions[i].alt, "", "", "", "", "", 0.0, severities[i], "", "")
            i += 1

        while j < len(classification):
            csv = csv + "%s;%s;%s;%s;%s;%s;%s;%s;%f;%f;%d;%d;%s;%s;%s;%s;%s;%f;%f;%s;%s\n" %("div-check",trajectory.filename, trajectory.flightId, trajectory.origin.code, trajectory.destination.code, trajectory.positions[0].date, trajectory.positions[-1].date, positions[i+j].date, positions[i+j].lat, positions[i+j].lon, positions[i+j].speed, positions[i+j].alt, data[j][0], data[j][1], data[j][2], data[j][3], (classification[j] == -1), decfunout[j], severities[i+j], diversionDetections[i+j], "Alert!" if firstDetectionIndex is not None and firstDetectionIndex == i+j else "")
            # at what (date)time was the diversion predicted?
#             if not diversionAlreadyPredicted:
#                 if numOfConsecutiveAnomalies == threshold:
#                     diversionDetectedDate = positions[i].date
#                     landingDate = landingPosition[-1].date
#                     timeDiff = landingDate - diversionDetectedDate
#                     #print "Diversion predicted " + str(timeDiff) + " before landing  (minutes: " + str(int(timeDiff.total_seconds() / 60)) + ")"
#                     total_time_saved += int(timeDiff.total_seconds() / 60)
#                     diversionAlreadyPredicted = True
            j += 1
#        print " = "
#        print fsum(scores)

        predictLogger.debug("Diversion detection CSV traceback\n%s" %csv)
    except Exception as e:
        predictLogger.error("Error in diversion detection CSV dump for flight %s: %s" %(trajectory.flightId, format(e)))