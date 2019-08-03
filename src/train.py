import logging
import re
logging.basicConfig(format='%(asctime)s - %(name)s:%(funcName)s()@%(lineno)d - %(levelname)s:\t%(message)s', level=logging.DEBUG)

detectLogger = logging.getLogger(__name__)

if __name__ == "__main__":
    import argparse
    import ConfigParser
    from svm import trainAndStoreSVM

    config = ConfigParser.RawConfigParser()
    config.read('../diversion-detector.ini')


    nu = config.getfloat('svm-parameters', 'nu')
    gamma = config.getfloat('svm-parameters', 'gamma')
    interval = config.getint('classification-parameters', 'interval_length')
    threshold = config.getint('classification-parameters', 'consecutive_anomalies_threshold')
    trainingFolders = config.get('folders', 'training_folders') 
    svmFolder = config.get('folders', 'svm_folder')
    timeCutOff = config.getint('data-treatment', 'time_cut_off')

    parser = argparse.ArgumentParser()
    parser.add_argument("--nu", type=float, help="nu parameter for the SVM") 
    parser.add_argument("--gamma", type=float, help="gamma parameter for the SVM")
    parser.add_argument("--interval", type=int, help="intervals of time to calculate the trend of updated data (in seconds)")
    parser.add_argument("--trainingfolders", help=":-separated paths to the folders with training data")
    parser.add_argument("--svmfolder", help="path to the folder where to store and retrieve SVMs")
#    parser.add_argument("--threshold", type=int, help="number of consecutive anomalies to consider to raise an alert")
    args = parser.parse_args()
    if args.nu:
        nu = args.nu
    if args.gamma:
        gamma = args.gamma
    if args.interval:
        interval = args.interval
    if args.trainingfolders:
        trainingFolders = args.trainingfolders
    if args.svmfolder:
        svmFolder = args.svmfolder

    detectLogger.debug("Training is about to start with the following parameters:\n" +
        "nu = %f\n" %nu +
        "gamma = %f\n" %gamma +
        "interval = %d\n" %interval +
        "threshold = %d\n" %threshold +
        "trainingFolders = %s\n" %trainingFolders +
        "svmFolder = %s\n" %svmFolder +
        "timeCutOff = %d\n" %timeCutOff
    )

    trainingFolders = re.split(r':', trainingFolders)

    trainAndStoreSVM(trainingFolders, svmFolder, nu, gamma, interval, threshold, timeCutOff) 