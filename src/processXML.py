import logging
import os
from classdef import Trajectory
from classdef import Airport
from classdef import Position
from operator import attrgetter

import xml.etree.ElementTree as ET

xmlprocLogger = logging.getLogger(__name__)

def loadTrajectory(filepath):
    try:
        treeroot = ET.parse(filepath).getroot()

        (flightId, aircraftId, flightCode) = getFlightInfo(treeroot)
        (origin, destination) = getAirports(treeroot, flightId)
        positions = getPositions(treeroot, flightId)

        if not positions:
            xmlprocLogger.warn("No positions found in flight located at '%s'" %filepath)
            return False
        if not origin or not destination:
            xmlprocLogger.warn("No landing or no take-off positions found in flight located at'%s'" %filepath)
            return False
        return Trajectory(os.path.basename(filepath), origin, destination, positions, flightId, aircraftId, flightCode)
    except Exception as e:
        xmlprocLogger.error("Error loading trajectory for flight at '%s': %s" %(filepath, format(e)))

def loadTrajectoryFromString(xmlstring):
    try:
        treeroot = ET.fromstring(xmlstring)

        (flightId, aircraftId, flightCode) = getFlightInfo(treeroot)
        (origin, destination) = getAirports(treeroot, flightId)
        positions = getPositions(treeroot, flightId)

        if not positions:
            xmlprocLogger.warn("No positions found in flight")
            return False
        if not origin or not destination:
            xmlprocLogger.warn("No landing or no take-off positions found in flight")
            return False
        return Trajectory("In-memory", origin, destination, positions, flightId, aircraftId, flightCode)
    except Exception as e:
        xmlprocLogger.error("Error loading trajectory for flight: %s" %format(e))

def getAirports(treeroot, flightId):
    try:        
        appendix = treeroot.find('appendix')
        airports = appendix.find('airports')
        flightAirports = {}
        for airport in airports.iter('airport'):
            code = airport.find('fs').text
            lat = airport.find('latitude').text
            lon = airport.find('longitude').text
            flightAirports[code] = (Airport(Position(lat, lon),code))
        tracks = treeroot.find('flightTracks')
        flighttrack = tracks.find('flightTrack')
        depcode = flighttrack.find('departureAirportFsCode').text
        arrcode = flighttrack.find('arrivalAirportFsCode').text
        return flightAirports[depcode], flightAirports[arrcode]
    except Exception as e:
        xmlprocLogger.error("Error retrieving origin and destination airports for flight %s: %s" %(flightId, str(e)))

def getFlightInfo(treeroot):
    global errors_exceptions_list
    try:        
        trax = treeroot.find('flightTracks')
        flighttrack = trax.find('flightTrack')
        
        flightId = flighttrack.find('flightId')
        flightId = flightId.text if not flightId == None else ""
        aircraftId = flighttrack.find('aircraftId')
        aircraftId = aircraftId.text if not aircraftId == None else ""
        flightCode = flighttrack.find('flightCode')
        flightCode = flightCode.text if not flightCode == None else ""

        return flightId, aircraftId, flightCode
    except Exception as e:
        xmlprocLogger.error("Error getting additional information for flight: %s" %format(e))
        
#def getPositions(tree, option, lastDateTime, flight):
def getPositions(treeroot, flight):
    try:
        positions = []
        tracks = treeroot.find('flightTracks')
        flighttrack = tracks.find('flightTrack')    

        for position in flighttrack.iter('position'):
            lat = position.find('lat').text
            lon = position.find('lon').text
            date = position.find('date').text
            speed = position.find('speedMph')
            alt = position.find('altitudeFt')
            bearing = position.find('bearing')
            bearing = bearing.text if not bearing == None else 0
            if (speed != None) and (alt != None):
                instance = Position(lat, lon, speed.text, alt.text, date, bearing)
                positions.append(instance)
            positions = sorted(positions, key=attrgetter('date'))
    except Exception as e:
        xmlprocLogger.error("Error getting positions for flight %s: %s" %(flight, format(e)))
    
    return positions#[::-1] 

















def getCoordinates(filepath, year, month, day, folder):
    tree = ET.parse(filepath)
    root = tree.getroot()
    tracks = root.find('flightTracks')
    flighttrack = tracks.find('flightTrack')
    docstring = ''
    callsignRef = "1"#flighttrack.find('callsign')
    i = 0
    if callsignRef is not None:
        callsign = "1"#flighttrack.find('callsign').text
        for position in flighttrack.iter('position'):
            lon = position.find('lon').text
            lat = position.find('lat').text
            posstring = lat + ", " + lon + "\n"
            docstring = docstring + posstring
            i += 1
        print i, 'positions found for', callsign
        outpath =  folder + "/" + str(year) + str(month) + str(day) + " " + callsign + " " +   str(i) + " positions.txt"
        with open (outpath, 'wb') as f:
            f.write(docstring)
            f.close()
    return i