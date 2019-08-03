# data <- read.csv2(file="/home/claudio/workspace/DiversionDetector/testlog-bestByF1_5.csv",sep=";")
data <- read.csv2(file="/home/claudio/workspace/DiversionDetector/testlog.csv",sep=";")

data$nu <- as.double(as.character(data$nu))
data$gamma <- as.double(as.character(data$gamma))
data$threshold <- as.double(as.character(data$threshold))

data$tp <- ( 1 - data$regular ) * data$alerts
data$fp <- ( data$regular ) * data$alerts
data$tn <- ( data$regular ) * data$regularOnes
data$fn <- ( 1 - data$regular ) * data$regularOnes

comboSummary <- aggregate(data[c("tp","fp","tn","fn")], by=data[c("code","nu","gamma","threshold","interval")], FUN=sum)
comboSummary$precision <- comboSummary$tp / ( comboSummary$tp + comboSummary$fp )
comboSummary$recall <- comboSummary$tp / ( comboSummary$tp + comboSummary$fn )
comboSummary$fscore <- 2 * ( comboSummary$precision * comboSummary$recall ) / ( comboSummary$precision + comboSummary$recall )
comboSummary$f15score <- 3.25 * ( comboSummary$precision * comboSummary$recall ) / ( 2.25 * comboSummary$precision + comboSummary$recall )
comboSummary$f2score <- 5 * ( comboSummary$precision * comboSummary$recall ) / ( 4 * comboSummary$precision + comboSummary$recall )

aggregatedByAllVars <- aggregate(comboSummary[c("precision","recall","fscore","f15score","f2score","tp","fp","tn","fn")], by=comboSummary[c("nu","gamma","threshold","interval")], FUN=mean)
aggregatedByMachine <- aggregate(comboSummary[c("nu","gamma","threshold","interval","precision","recall","fscore","f15score","f2score","tp","fp","tn","fn")], by=comboSummary[c("")], FUN=mean)

options(width=640)

# print("Test performances, ranked by best F_{1.5} score")
# bestF15ScoresByAllVars <- aggregatedByAllVars[ order( -aggregatedByAllVars$f15score, -aggregatedByAllVars$recall, -aggregatedByAllVars$precision ), ]

# bestF15ScoresByAllVars

# print("Test performances")
# aggregatedByAllVars

# write.csv(
#   format(
#     aggregatedByAllVars[ ,c("interval","threshold","nu","gamma","precision","recall","fscore","f15score","tp","fp","tn","fn")],
#     nsmall=2,
#     digits=2),
#   row.names = FALSE,
#   quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/test/testresults-bestByF15.csv")

print("Test performances, ranked by best F-score")
bestFScoresByAllVars <- aggregatedByAllVars[ order( -aggregatedByAllVars$fscore, -aggregatedByAllVars$recall, -aggregatedByAllVars$precision ), ]

write.csv(
  format(
    aggregatedByAllVars[ ,c("interval","threshold","nu","gamma","precision","recall","fscore","tp","fp","tn","fn")],
    nsmall=2,
    digits=2),
  row.names = FALSE,
  quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/test/testresults.csv")

bestByFScore <- comboSummary[which.max(comboSummary$fscore),]
bestByFScoreNoDot <- lapply(bestByFScore, FUN = function(x) as.character(gsub(".", "", x, fixed = TRUE)))
write.table(
  paste('python detect.py',
        ' --svmfolder "$BASE_DIR/SVMs/SVMs_interval-',bestByFScoreNoDot$interval,
        '/SVM-',bestByFScoreNoDot$code,
        '_interval-',bestByFScoreNoDot$interval,
        '_nu-',bestByFScoreNoDot$nu,
        '_gamma-',bestByFScoreNoDot$gamma,
        '"',
        ' --interval ',bestByFScoreNoDot$interval,
        ' --threshold ',bestByFScoreNoDot$threshold,
        ' "%s"',
        sep=""),
  row.names = FALSE, col.names = FALSE)