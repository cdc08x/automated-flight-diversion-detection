import logging
import os

from processFolder import loadTrajectories
from processXML import loadTrajectory
from processXML import loadTrajectoryFromString
from predict import predictDiversion

classifyLogger = logging.getLogger(__name__)

def classifyXml(clf, scaler, interval, xmlstring, threshold):
    try:
        trajectory = loadTrajectoryFromString(xmlstring)
        diversionDetected = classifyTrajectory(clf, scaler, trajectory, interval, threshold)
        return diversionDetected
    except Exception as e:
        classifyLogger.error("Error classifying XML: %s" %format(e))

def classifyFile(clf, scaler, interval, filepath, threshold):
    try:
        trajectory = loadTrajectory(filepath)
        diversionDetected = classifyTrajectory(clf, scaler, trajectory, interval, threshold)
        return diversionDetected
    except Exception as e:
        classifyLogger.error("Error classifying file %s: %s" %(filepath, format(e)))

def classifyFolder(clf, scaler, interval, folder, threshold):
    filepahtsClassifiedAsDiverted = []
    try:
        (filepaths, trajectories) = loadTrajectories(folder)
        i = 0
        for trajectory in trajectories:
            diversionDetected = classifyTrajectory(clf, scaler, trajectory, interval, threshold)
            if diversionDetected:
                filepahtsClassifiedAsDiverted.append(filepaths[i])
            i += 1
        return len(trajectories), len(filepahtsClassifiedAsDiverted), len(trajectories) - len(filepahtsClassifiedAsDiverted), filepahtsClassifiedAsDiverted
    except Exception as e:
        classifyLogger.error("Error classifying folder '%s': %s" %(folder, format(e)))

def classifyFsNodes(clf, scaler, interval, fsNodesPaths, threshold):
    filepahtsClassifiedAsDiverted = []
    trajectories = []
    for fsNodePath in fsNodesPaths:
        if (os.path.isfile(fsNodePath)):
            try:
                nutrajectory = loadTrajectory(fsNodePath)
                diversionDetected = classifyTrajectory(clf, scaler, nutrajectory, interval, threshold)
                if diversionDetected:
                    filepahtsClassifiedAsDiverted.append(fsNodePath)
                trajectories = trajectories + nutrajectory
            except Exception as e:
                classifyLogger.error("Error classifying file '%s': %s" %(fsNodePath, format(e)))
        elif (os.path.isdir(fsNodePath)):
            try:
                (filepaths, nutrajectories) = loadTrajectories(fsNodePath, interval)
                i = 0
                for nutrajectory in nutrajectories:
                    i += 1
                    diversionDetected = classifyTrajectory(clf, scaler, nutrajectory, interval, threshold)
                    if diversionDetected:
                        filepahtsClassifiedAsDiverted.append(filepaths[i])
                    trajectories = trajectories + nutrajectory
            except Exception as e:
                classifyLogger.error("Error classifying folder '%s': %s" %(fsNodePath, format(e)))
    return len(trajectories), len(filepahtsClassifiedAsDiverted), len(trajectories) - len(filepahtsClassifiedAsDiverted), filepahtsClassifiedAsDiverted

def classifyTrajectory(clf, scaler, trajectory, interval, threshold):
    try:
        trajectoryUnderAnalysis = trajectory.createTrajectoryForAnalysis(interval)
        
        if trajectoryUnderAnalysis.totaldist == 0:
            classifyLogger.warn("Trajectory total distance = 0 for flight at '%s'" %(trajectoryUnderAnalysis.filename))
            return True

        data = trajectoryUnderAnalysis.getVectors()

        if not data:
            classifyLogger.debug("Insufficient data for diversion prediction of flight at '%s'" %(trajectoryUnderAnalysis.filename))
            return False # insufficient data

        try:
            datat = scaler.transform(data)
        except Exception as e:
            # print "Error in classification of: ", trajectory.filename, format(e)
            classifyLogger.error("Error while classifying trajectory of flight at '%s': %s", str(trajectoryUnderAnalysis.filename) + ":" + format(e))
            return False
            
        classification = clf.predict(datat)
        
        decfunout = clf.decision_function(datat)
        decfunout = [item for sublist in decfunout for item in sublist] # flatten the list of lists in a "simple" list
        
        (diversionPredicted, severities, firstAlertPosition) = predictDiversion(trajectoryUnderAnalysis, classification, decfunout, threshold)

        return diversionPredicted
    except Exception as e:
        classifyLogger.error("Error while classifying flight %s: %s" %(trajectory.flightId, format(e)))