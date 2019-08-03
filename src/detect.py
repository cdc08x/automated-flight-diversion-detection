import logging
import re
logging.basicConfig(format='%(asctime)s - %(name)s:%(funcName)s()@%(lineno)d - %(levelname)s:\t%(message)s', level=logging.DEBUG)

detectLogger = logging.getLogger(__name__)

if __name__ == "__main__":
    import argparse
    import ConfigParser
    import os
    from svm import getSVM
    from classify import classifyFile, classifyFolder, classifyXml, classifyFsNodes

    config = ConfigParser.RawConfigParser()
    config.read('../diversion-detector.ini')

    interval = config.getint('classification-parameters', 'interval_length')
    threshold = config.getint('classification-parameters', 'consecutive_anomalies_threshold')
    svmFolder = config.get('folders', 'svm_folder')
    timeCutOff = config.getint('data-treatment', 'time_cut_off')

    parser = argparse.ArgumentParser()
    parser.add_argument("xml", help="it can be either (1) the path to the file to check, or (2) the path to the folder with the files to check, or (3) an XML string itself, or (4) a ':'-separated list of files and folders")
    parser.add_argument("--interval", type=int, help="intervals of time to calculate the trend of updated data (in seconds)")
    parser.add_argument("--svmfolder", help="path to the folder where to store and retrieve SVMs")
    parser.add_argument("--threshold", type=int, help="number of consecutive anomalies to consider to raise an alert")
    args = parser.parse_args()
    if args.interval:
        interval = args.interval
    if args.svmfolder:
        svmFolder = args.svmfolder
    if args.threshold:
        threshold = args.threshold

    xml = args.xml

    detectLogger.debug("Detection is about to start with the following parameters:\n" +
        "interval = %d\n" %interval +
        "threshold = %d\n" %threshold +
        "svmFolder = %s\n" %svmFolder +
        "timeCutOff = %d\n" %timeCutOff
    )
    
    (clf, scaler) = getSVM(svmFolder)
    
    csvPattern = ("Diversion detection results:\n" 
    "code;svm;args;threshold;interval;timeCutOff;filesNum;regularOnes;alerts\n"
    "D3t3ct;%s;%s;%d;%d;%d;%d;%d;%d")
    
    if (os.path.isfile(xml)):
        alert = classifyFile(clf, scaler, interval, xml, threshold)
        detectLogger.info(csvPattern %(svmFolder,xml,threshold,interval,timeCutOff,1,1 - alert,alert))
    elif (os.path.isdir(xml)):
        (numOfFiles, numOfAlerts, numOfRegularOnes, files) = classifyFolder(clf, scaler, interval, xml, threshold)
        detectLogger.info(csvPattern %(svmFolder,xml,threshold,interval,timeCutOff,numOfFiles,numOfRegularOnes,numOfAlerts))
    elif ("<?xml" in xml):
        alert = classifyXml(clf, scaler, interval, xml, threshold)
        detectLogger.info(csvPattern %(svmFolder,"?xml",threshold,interval,timeCutOff,1,1 - alert,alert))
    else:
        (numOfFiles, numOfAlerts, numOfRegularOnes, files) = classifyFsNodes(clf, scaler, interval, re.split(r':', xml), threshold)
        detectLogger.info(csvPattern %(svmFolder,xml,threshold,interval,timeCutOff,numOfFiles,numOfRegularOnes,numOfAlerts))
