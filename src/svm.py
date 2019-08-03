from processFolder import loadTrajectories
from sklearn import svm, preprocessing
from sklearn.externals import joblib

import logging
import sys

svmLogger = logging.getLogger(__name__) 

def trainAndStoreSVM(trainFolders, svmDumpFolder, nu, gamma, interval, threshold, timeCutOff):
#    try:
        trajectories = []
        filepaths = []
        for trainFolder in trainFolders:
            svmLogger.info("Loading training data from folder %s..." %trainFolder)
            (nufilepaths, nutrajectories) = loadTrajectories(trainFolder)
            filepaths = filepaths + nufilepaths
            trajectories = trajectories + nutrajectories

        (clf, scaler) = trainSVM(trajectories, nu, gamma, interval, timeCutOff)

        svmLogger.info("Training complete")
        svmLogger.info("Saving SVM in folder %s..." %svmDumpFolder)

        joblib.dump(clf, str(svmDumpFolder) + "/flightmonitoring.svm")
        joblib.dump(scaler, str(svmDumpFolder) + "/flightmonitoring.scaler")

        svmLogger.info("Saving complete")

        return clf, scaler
#    except Exception as e:
#        svmLogger.error("Error in training and storing the SVM:%s" %format(e))

def trainSVM(trainTrajectories, nu, gamma, interval, timeCutOff):
    traindata = []
    for trajectory in trainTrajectories:
        svmLogger.info("Training on '%s'" %trajectory.filename)
        trajectory = trajectory.createTrajectoryForAnalysis(interval, timeCutOff)
        traindata += trajectory.getVectors()
    scaler = preprocessing.StandardScaler().fit(traindata)
    traindata = scaler.transform(traindata)
    clf = svm.OneClassSVM(kernel='rbf', nu = nu, gamma = gamma)
    clf.fit(traindata)
    return clf, scaler

def getSVM(svmDumpFolder):
    svmLogger.info("Loading precomputed SVM from folder %s" %svmDumpFolder)
    
    clf = joblib.load(svmDumpFolder + "/flightmonitoring.svm")
    scaler = joblib.load(svmDumpFolder + "/flightmonitoring.scaler")
    
    svmLogger.info("Loading complete")
    return clf, scaler