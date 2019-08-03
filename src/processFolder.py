import os
import logging
from processXML import loadTrajectory

folderProcLogger = logging.getLogger(__name__)

def loadTrajectories(folder):
    try:
        filepaths = [ os.path.join(folder, f) for f in os.listdir(folder) \
                    if os.path.isfile(os.path.join(folder, f))]
        trajectories = []
        for filepath in filepaths:
#            folderProcLogger.info("Analysing file: %s" %filepath)
            # from each .xml get its positions with specified time interval
            trajectory = loadTrajectory(filepath)
            if trajectory:
                trajectories.append(trajectory)
    #                break
        # return list of all flights
        return filepaths, trajectories
    except Exception as e:
        folderProcLogger.error("Error loading trajectories for folder %s:\n%s" %(str(folder), format(e)))
