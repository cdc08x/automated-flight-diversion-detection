import iso8601
import math
import numpy
import logging

classdefLogger = logging.getLogger(__name__)

class Position:
    def __init__(self, lat, lon, speed = 0, alt = 0, date = "2013-07-24T01:00:00.000Z", bearing = 0) :
        self.lat = float(lat)
        self.lon = float(lon)
        self.speed = int(speed)
        self.alt = float(alt)
        self.date = iso8601.parse_date(date)
        self.bearing = int(bearing)
         
    def __str__(self):
        return "lat: " + str(self.lat) + " lon: " + str(self.lon) + \
        " speed: " + str(self.speed) + " alt: " + str(self.alt) + " date: " + str(self.date) + " bearing: " + str(self.bearing)

class Airport:
    def __init__(self, position, code) :
        self.position = position
        self.code = code
         
    def __str__(self):
        return "code: " + str(self.code) + \
        " position: " + str(self.position)
    
class Trajectory:
    
    def __init__(self, filename, origin, destination, positions = [], flightId = "", aircraftId = "", flightCode = ""):
        self.filename = filename
        self.origin = origin
        self.destination = destination
        self.positions = positions
        self.totaldist = self.sphericalDistance(origin.position, destination.position)
        self.flightId = flightId
        self.aircraftId = aircraftId
        self.flightCode = flightCode
        
        if self.totaldist != 0:
            self.vectors = self.computeVectors()
        
    def getOrigin(self):
        return self.origin
        
    def getaircraftId(self):
        return self.aircraftId
        
    def getFlightCode(self):
        return self.flightCode
        
    def getDestination(self):
        return self.destination
        
    def createTrajectoryForAnalysis(self, interval, timeCutOff = 0):
        try:
            if not self.positions:
                return self
            # take first position
            sample = [self.positions[0]]
            # positions with altitude > 0
            positionsInTheSky = []
            # in this array, we will take only positions of the flight that have time difference of "interval"
            positionsForAnalysis = []
            # fast way to make this value float-typed
            interval = interval * 1.0
            # 
            for i in range(1, len(self.positions)):
                if (self.positions[i].alt > 0):
                    positionsInTheSky.append(self.positions[i])
                
            for i in range(1, len(positionsInTheSky)):
                # if the array is empty, we will add in the first position where aircraft is in the air and is "minutes" after the take-off or first position where altitude is != 0
                if not positionsForAnalysis:
                    if (positionsInTheSky[i].date - sample[-1].date).seconds >= timeCutOff:
                        if positionsInTheSky[i] != sample[-1]:
                            positionsForAnalysis.append(positionsInTheSky[i])
                # if there is already a position in positionsForAnalysis, than we take the next position with time difference of "interval"
                else:
                    if (positionsInTheSky[i].date - positionsForAnalysis[-1].date).seconds >= interval and (positionsInTheSky[-1].date - positionsInTheSky[i].date).seconds >= timeCutOff and (positionsInTheSky[-1].date - positionsForAnalysis[-1].date).seconds >= timeCutOff:
                        if positionsInTheSky[i] != positionsForAnalysis[-1]:
                            positionsForAnalysis.append(positionsInTheSky[i])
    
        except Exception as e:
            #print "Error in method filterPositions", format(e)
            classdefLogger.error("Error in the creation of the trajectory for diversion analysis for flight %s: %s" %(self.flightId, format(e)))
    
        return Trajectory(self.filename, self.origin, self.destination, positionsForAnalysis, self.flightId, self.aircraftId, self.flightCode)

    
    def getPositions(self):
        return self.positions
        
    def getVectors(self):
        return self.vectors
        
    def computeVectors(self):
        poss = self.positions
        return [self.computeVector(poss[i-2], poss[i-1], poss[i]) \
                    for i in range(2, len(self.positions))]
            
    def computeVector(self, pos0, pos1, pos2):
        length = math.fabs((pos1.date - pos2.date).seconds)
        dist1 = self.sphericalDistance(pos1, self.destination.position)
        dist2 = self.sphericalDistance(pos2, self.destination.position)
        try:
            distLeft = 1 - dist2/self.totaldist
        except Exception as e:
            classdefLogger.error("Error in the computation of the feature vector:%s" %format(e))
            return False
        
        try:
            distGain = (dist1 - dist2)/self.totaldist/length
        except Exception as e:
            distGain = 0
        avgspeed = (pos1.speed + pos2.speed)*1.0/2
        if avgspeed != 0:
            try:
                dspeed = (pos2.speed - pos1.speed)*1.0/avgspeed/length
            except Exception as e:
                dspeed = 0    
        else:
            dspeed = 0
        avgalt = (pos1.alt + pos2.alt)*1.0/2
        if avgalt != 0:
            try:
                dalt = (pos2.alt - pos1.alt)*1.0/avgalt/length
            except Exception as e:
                dalt = 0      
        else:
            dalt = 0
        # dBearing removed, as it hampered the quality of results rather than improving them
        #dbearing = self.bearing(pos1, pos2) - self.bearing(pos0, pos1)
        return numpy.array( (distLeft, distGain, dspeed, dalt ) )#, dbearing) )
        
    def sphericalDistance(self, pos1, pos2):
        return self.sphericalDistanceLL(pos1.lat, pos1.lon, pos1.lat, pos2.lon)
        
    def sphericalDistanceLL(self, lat1, lon1, lat2, lon2):
        degrees_to_radians = math.pi/180.0
        phi1 = (90.0 - lat1)*degrees_to_radians
        phi2 = (90.0 - lat2)*degrees_to_radians
        theta1 = lon1*degrees_to_radians
        theta2 = lon2*degrees_to_radians
        cos = (math.sin(phi1)*math.sin(phi2)*math.cos(theta1 - theta2) + 
               math.cos(phi1)*math.cos(phi2))
        return math.acos( cos )#*180.0/math.pi      

    def computeBearing(self, pos1, pos2):
        return self.computeBearingLL(pos1.lat, pos1.lon, pos1.lat, pos2.lon)
        
    def computeBearingLL(self, lat1, lon1, lat2, lon2):
        lat1 = lat1*math.pi/180.0
        lon1 = lon1*math.pi/180.0
        lat2 = lat2*math.pi/180.0
        lon2 = lon2*math.pi/180.0
        return math.atan2(math.sin(lon1-lon2)*math.cos(lat2), \
               math.cos(lat1)*math.sin(lat2)-math.sin(lat1)* \
               math.cos(lat2)*math.cos(lon1-lon2)) % 2*math.pi

class Alert:
    def __init__(self, flightId, aircraftId, flightCode, originAirport, destinationAirport, diversionDetectionPosition, diversionDetectionDate) :
        self.flightId = flightId
        self.aircraftId = aircraftId
        self.flightCode = flightCode
        self.originAirport = originAirport
        self.destinationAirport = destinationAirport
        self.diversionDetectionPosition = diversionDetectionPosition
        self.timestamp = diversionDetectionDate