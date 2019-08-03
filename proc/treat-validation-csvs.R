data <- read.csv2(file="/home/claudio/workspace/DiversionDetector/validatelog.csv",sep=";")
# data <- read.csv2(file="/home/claudio/workspace/DiversionDetector/testlog.csv",sep=";")

data$nu <- as.double(as.character(data$nu))
data$gamma <- as.double(as.character(data$gamma))
data$threshold <- as.double(as.character(data$threshold))

data$tp <- ( 1 - data$regular ) * data$alerts
data$fp <- ( data$regular ) * data$alerts
data$tn <- ( data$regular ) * data$regularOnes
data$fn <- ( 1 - data$regular ) * data$regularOnes

unique(data$interval)

comboSummary <- aggregate(data[c("tp","fp","tn","fn")], by=data[c("code","nu","gamma","threshold","interval")], FUN=sum)
comboSummary$precision <- comboSummary$tp / ( comboSummary$tp + comboSummary$fp )
comboSummary$recall <- comboSummary$tp / ( comboSummary$tp + comboSummary$fn )
comboSummary$fscore <- 2 * ( comboSummary$precision * comboSummary$recall ) / ( comboSummary$precision + comboSummary$recall )
comboSummary$f15score <- 3.25 * ( comboSummary$precision * comboSummary$recall ) / ( 2.25 * comboSummary$precision + comboSummary$recall )
comboSummary$f2score <- 5 * ( comboSummary$precision * comboSummary$recall ) / ( 4 * comboSummary$precision + comboSummary$recall )

aggregatedByAllVars <- aggregate(comboSummary[c("precision","recall","fscore","f15score","f2score","tp","fp","tn","fn")], by=comboSummary[c("nu","gamma","threshold","interval")], FUN=mean)

bestByFScoreWrtIntervals <- do.call(rbind, lapply(split(aggregatedByAllVars, aggregatedByAllVars[,c("interval")]), function(x) x[which.max(x$fscore),]))
bestByF15ScoreWrtIntervals <- do.call(rbind, lapply(split(aggregatedByAllVars, aggregatedByAllVars[,c("interval")]), function(x) x[which.max(x$f15score),]))
options(width=640)

print("Mean results, aggregated by nu, gamma, threshold, interval (COARSE)")
write.csv(
  format(
    aggregatedByAllVars[ aggregatedByAllVars$interval %% 60 == 0,c("interval","threshold","nu","gamma","precision","recall","fscore","tp","fp","tn","fn")],
    nsmall=2,
    digits=2),
  row.names = FALSE,
  quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/validation/allresults_COARSE.csv")

print("Mean results, aggregated by nu, gamma, threshold, interval")
write.csv(
  format(
    aggregatedByAllVars[,c("interval","threshold","nu","gamma","precision","recall","fscore","tp","fp","tn","fn")],
    nsmall=2,
    digits=2),
  row.names = FALSE,
  quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/validation/allresults.csv")

print("Best combos in terms of F-measure, with respect to the interval (COARSE)")
write.csv(
  format(
    bestByFScoreWrtIntervals[ bestByFScoreWrtIntervals$interval %% 60 == 0,c("interval","threshold","nu","gamma","precision","recall","fscore","tp","fp","tn","fn")],
    nsmall=2,
    digits=2),
  row.names = FALSE,
  quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/validation/best-by-fscore-wrt-intervals_COARSE.csv")

print("Best combos in terms of F-measure, with respect to the interval (overall)")
write.csv(
  format(
    bestByFScoreWrtIntervals[, c("interval","threshold","nu","gamma","precision","recall","fscore","tp","fp","tn","fn")],
    nsmall=2,
    digits=2),
  row.names = FALSE,
  quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/validation/best-by-fscore-wrt-intervals.csv")

print("Best combos in terms of F_{1.5}-measure, with respect to the interval (FINE)")
write.csv(
  format(
    bestByF15ScoreWrtIntervals[ bestByF15ScoreWrtIntervals$interval < 360,c("interval","threshold","nu","gamma","precision","recall","f15score","fscore","tp","fp","tn","fn")],
    nsmall=2,
    digits=2),
  row.names = FALSE,
  quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/validation/best-by-fscore-wrt-intervals_FINE.csv")

print("Best combos in terms of F_{1.5}-measure, with respect to the interval (overall)")
write.csv(
  format(
    bestByF15ScoreWrtIntervals[ ,c("interval","threshold","nu","gamma","precision","recall","f15score","fscore","tp","fp","tn","fn")],
    nsmall=2,
    digits=2),
  row.names = FALSE,
  quote = FALSE, file = "/home/claudio/workspace/DiversionDetector/validation/best-by-f15score-wrt-intervals.csv")

print("Best 25 combos in terms of F-measure")
# Best 25 combos in terms of F-measure

bestFScoresByAllVars <- aggregatedByAllVars[ order( -aggregatedByAllVars$fscore, -aggregatedByAllVars$recall, -aggregatedByAllVars$precision ), ]
bestFScoresByAllVars[1:25,]
# bestF2Scores <- aggregatedByAllVars[ order( -aggregatedByAllVars$f2score, -aggregatedByAllVars$recall, -aggregatedByAllVars$precision ), ]
# bestF2Scores[1:20,]


print("Best 25 combos in terms of F_{1.5}-measure")
# Best 25 combos in terms of F_{1.5}-measure
# See: Dirk Guijt, Claudia Hauf, "Using Query-Log Based Collective Intelligence to Generate Query Suggestions for Tagged Content Search"
# 
bestF15ScoresByAllVars <- aggregatedByAllVars[ order( -aggregatedByAllVars$f15score, -aggregatedByAllVars$recall, -aggregatedByAllVars$precision ), ]
best25inF15 <- bestF15ScoresByAllVars[1:25,]

best25inF15

print("25 launch commands, based on SVMs and thresholds performing best in terms of F_{1.5}-measure")
#
# Remove dots from numeric values
best25inF15nodot <- lapply(best25inF15, FUN = function(x) as.character(gsub(".", "", x, fixed = TRUE)))
write.table(
  paste('python detect.py',
        ' --svmfolder "$BASE_DIR/SVMs/SVMs_interval-',best25inF15$interval,
        '/SVM-%s_interval-',best25inF15$interval,
        '_nu-',best25inF15nodot$nu,
        '_gamma-',best25inF15nodot$gamma,
        '"',
        ' --interval ',best25inF15nodot$interval,
        ' --threshold ',best25inF15nodot$threshold,
        ' "%s"',
        sep=""),
  row.names = FALSE, col.names = FALSE)

print("25 launch commands, based on SVMs and thresholds performing best in terms of F_{1.5}-measure, w.r.t. the interval length")
#
# Remove dots from numeric values
bestByF15ScoreWrtIntervalsNoDot <- lapply(bestByF15ScoreWrtIntervals, FUN = function(x) as.character(gsub(".", "", x, fixed = TRUE)))
write.table(
  paste('python detect.py',
        ' --svmfolder "$BASE_DIR/SVMs/SVMs_interval-',bestByF15ScoreWrtIntervalsNoDot$interval,
        '/SVM-%s_interval-',bestByF15ScoreWrtIntervalsNoDot$interval,
        '_nu-',bestByF15ScoreWrtIntervalsNoDot$nu,
        '_gamma-',bestByF15ScoreWrtIntervalsNoDot$gamma,
        '"',
        ' --interval ',bestByF15ScoreWrtIntervalsNoDot$interval,
        ' --threshold ',bestByF15ScoreWrtIntervalsNoDot$threshold,
        ' "%s"',
        sep=""),
  row.names = FALSE, col.names = FALSE)

print("25 launch commands, based on SVMs and thresholds performing best in terms of F-measure, w.r.t. the interval length")
#
# Remove dots from numeric values
bestByFScoreWrtIntervalsNoDot <- lapply(bestByFScoreWrtIntervals, FUN = function(x) as.character(gsub(".", "", x, fixed = TRUE)))
write.table(
  paste('python detect.py',
        ' --svmfolder "$BASE_DIR/SVMs/SVMs_interval-',bestByFScoreWrtIntervalsNoDot$interval,
        '/SVM-%s_interval-',bestByFScoreWrtIntervalsNoDot$interval,
        '_nu-',bestByFScoreWrtIntervalsNoDot$nu,
        '_gamma-',bestByFScoreWrtIntervalsNoDot$gamma,
        '"',
        ' --interval ',bestByFScoreWrtIntervalsNoDot$interval,
        ' --threshold ',bestByFScoreWrtIntervalsNoDot$threshold,
        ' "%s"',
        sep=""),
  row.names = FALSE, col.names = FALSE)