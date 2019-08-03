library(ggplot2)

serious_theme <- theme_classic() + # less fancy colors
  #increase size of gridlines
  theme(panel.grid.major = element_line(size = .5, color = "lightgrey"),
  #increase size of axis lines
  axis.line = element_line(size=.7, color = "black"),
  #Adjust legend position to maximize space, use a vector of proportion
  #across the plot and up the plot where you want the legend. 
  #You can also use "left", "right", "top", "bottom", for legends on t
  #he side of the plot
#  legend.position = c(.2,.9),
  #box around the legend
  legend.background = element_rect(colour = "black", size=.3),
  #increase the font size
  text = element_text(size=24)) 
## http://www.noamross.net/blog/2013/11/20/formatting-plots-for-pubs.html

plotfilename_bestResVsIntervalLength_coarse <- "/home/claudio/Code/DiversionDetector/validation/best-prec_rec_fscore-graph-wrt-length_COARSE.pdf"
plotfilename_bestResVsIntervalLength <- "/home/claudio/Code/DiversionDetector/validation/best-prec_rec_fscore-graph-wrt-length.pdf"
plotfilename_bestresults.coarseF15ScoreBarsAndLength <- "/home/claudio/Code/DiversionDetector/validation/best-prec_rec_f15score-bars-wrt-length.pdf"
plotfilename_bestresults.coarseFScoreBarsAndLength <- "/home/claudio/Code/DiversionDetector/validation/best-prec_rec_fscore-bars-wrt-length.pdf"
plotfilename_acceptableResultsFScoreGraphs <- "/home/claudio/Code/DiversionDetector/validation/fscore-graph-for-acceptable-configurations.pdf"

bestresults.coarse <- read.csv2(file="/home/claudio/Code/DiversionDetector/validation/best-by-fscore-wrt-intervals_COARSE.csv", sep=",", header=TRUE)
bestresults.coarse$precision <- as.double(as.character(bestresults.coarse$precision))
bestresults.coarse$recall <- as.double(as.character(bestresults.coarse$recall))
bestresults.coarse$fscore <- as.double(as.character(bestresults.coarse$fscore))
bestresults.coarse$nu <- as.double(as.character(bestresults.coarse$nu))
bestresults.coarse$gamma <- as.double(as.character(bestresults.coarse$gamma))
bestresults.coarse$threshold <- as.integer(as.character(bestresults.coarse$threshold))
bestresults.coarse$interval <- as.integer(as.character(bestresults.coarse$interval))

#### Derives configurations for best performing parameters.
bestresults.coarse.bestprec <-  bestresults.coarse[which.max( bestresults.coarse$precision),]
bestresults.coarse.bestrec <-  bestresults.coarse[which.max( bestresults.coarse$recall),]
bestresults.coarse.bestfscore <-  bestresults.coarse[which.max( bestresults.coarse$fscore),]

#### Prints a graph with the best precision, recall and f-score trends obtained, w.r.t. the length of the interval (L) -- COARSE grid search. On top of highest  precision & recall points, the best choice for nu, gamma and threshold is specified.
pdf(plotfilename_bestResVsIntervalLength_coarse)

resultypes <- c("F-Score","Precision","Recall")
#customshapetypes <- data.frame( types = resultypes, shapes = c(18,19,15)) # filled
customshapetypes <- data.frame( types = resultypes, shapes = c(5,1,0)) # empty

   scale_label <- "Accuracy metrics"
   plot4bestresults.coarseGroupedByL <- ggplot(data = NULL, aes(x=interval)) +
        geom_line(data = bestresults.coarse, aes(y=precision, linetype="Precision")) +
        geom_line(data = bestresults.coarse, aes(y=recall, linetype="Recall")) +
        geom_line(data = bestresults.coarse, aes(y=fscore, linetype="F-Score")) +
        geom_point(data = bestresults.coarse, aes(y=precision), shape = 19, size = 3, show_guide=FALSE) +
        geom_point(data = bestresults.coarse, aes(y=recall), shape = 15, size = 3, show_guide=FALSE) +
        geom_point(data = bestresults.coarse, aes(y=fscore), shape = 18, size = 3, show_guide=FALSE) +
        geom_text(data = bestresults.coarse.bestprec, aes(x = interval + 0.25, y= precision + 0.01, label = paste('paste(gamma==', gsub(" ", "", gamma, TRUE), ',",",~nu==', gsub(" ", "", nu, TRUE), ',",",~t==', gsub(" ", "", threshold, TRUE), ")"), family = "serif", fontface = 3), size = 5, hjust = 0, show_guide=FALSE, parse = TRUE) +
        geom_point(data = bestresults.coarse.bestprec, aes(y=precision, shape="Precision"), size = 5) +
        geom_text(data = bestresults.coarse.bestrec, aes(x = interval + 0.25, y= recall + 0.01, label = paste("paste(gamma==", gsub(" ", "", gamma, TRUE), ',",",~nu==', gsub(" ", "", nu, TRUE), ',",",~t==', gsub(" ", "", threshold, TRUE), ")"), family = "serif", fontface = 3), size = 5, hjust = 0, show_guide=FALSE, parse = TRUE) +
        geom_point(data = bestresults.coarse.bestrec, aes(y=recall, shape="Recall"), size = 5) +
        geom_text(data = bestresults.coarse.bestfscore, aes(x = interval + 0.25, y= fscore + 0.01, label = paste("paste(gamma==", gsub(" ", "", gamma, TRUE), ',",",~nu==', gsub(" ", "", nu, TRUE), ',",",~t==', gsub(" ", "", threshold, TRUE), ")"), family = "serif", fontface = 3), size = 5, hjust = 0, show_guide=FALSE, parse = TRUE) +
        geom_point(data = bestresults.coarse.bestfscore, aes(y=fscore, shape="F-Score"), size = 5) +
#        labs(list(title = "Best accuracy results w.r.t. the interval length", x = "Interval length [min]", y = "", linetype = scale_label, colour = scale_label)) +
        labs(list(x = "Interval length [sec]", y = "", linetype = scale_label, shape = scale_label)) +
        scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
        scale_x_continuous(breaks=seq(min(bestresults.coarse$interval),max(bestresults.coarse$interval),by=60)) +
        ylim( (floor(min(c(bestresults.coarse$prec,bestresults.coarse$recall,bestresults.coarse$fscore)) *10 ) /10 ), (ceiling(max(c(bestresults.coarse$prec,bestresults.coarse$recall,bestresults.coarse$fscore)) *10 ) /10 ) ) +
        serious_theme +
        theme(legend.position=c(.25,.1))
   print(plot4bestresults.coarseGroupedByL)

   dev.off()
   
#### Prints a bar plot with the best f-score trends, w.r.t. the length of the interval (L). For each value of L, several bars are printed, each representing a given value for t (the number of intervals you wait for, before categorizing a flight as diverting).
pdf(plotfilename_bestresults.coarseFScoreBarsAndLength)

bestresults.coarse.inminutes <- bestresults.coarse
bestresults.coarse.inminutes$interval <- bestresults.coarse.inminutes$interval / 60
   
plot4bestresults.coarseGroupedByLT <- ggplot(data = bestresults.coarse.inminutes, aes(x=interval)) +
     geom_bar(stat="identity", aes(y=fscore * 100), fill="#CFCFCF", color="#CFCFCF", width=.5, alpha=.75) +
     geom_line(aes(y=threshold * interval), size = 1.5) +
     geom_text(aes(y=threshold * interval + 8, label = sprintf( "%02d:00",  threshold * interval ) ), size = 5) +
     scale_x_continuous(breaks=seq(min(bestresults.coarse.inminutes$interval),max(bestresults.coarse.inminutes$interval),by=1)) +
     #         labs(list(title = "Best accuracy results and time-to-prediction\nw.r.t. interval length", x = "Interval length [min]", y = "", fill = "Consecutive\nanomalous\nintervals\nper\ndiverted\nflight"))
     labs(list(x = "Interval length", y = "", fill = "Consecutive\nanomalous\nintervals\nper\ndiverted\nflight")) +
     serious_theme
   
   print(plot4bestresults.coarseGroupedByLT)
   
   dev.off()
   
#### Prints a precision-recall graph. Only acceptable data are printed, where "acceptable" means that the sum of precision and recall is equal to 1.25 at least. nu is fixed and equal to 0.04
data <- read.csv2(file="/home/claudio/Code/DiversionDetector/validation/allresults.csv", sep=",", header=TRUE)

data$precision <- as.double(as.character( data$precision ))
data$recall <- as.double(as.character( data$recall ))
data$fscore <- as.double(as.character( data$fscore ))
data$nu <- as.double(as.character( data$nu ))
data$gamma <- as.double(as.character( data$gamma ))
data$threshold <- as.integer(as.character( data$threshold ))
data$interval <- as.integer(as.character( data$interval ))

bestresults <- read.csv2(file="/home/claudio/Code/DiversionDetector/validation/best-by-fscore-wrt-intervals.csv", sep=",", header=TRUE)
bestresults$precision <- as.double(as.character( bestresults$precision ))
bestresults$recall <- as.double(as.character( bestresults$recall ))
bestresults$fscore <- as.double(as.character( bestresults$fscore ))
bestresults$nu <- as.double(as.character( bestresults$nu ))
bestresults$gamma <- as.double(as.character( bestresults$gamma ))
bestresults$threshold <- as.integer(as.character( bestresults$threshold ))
bestresults$interval <- as.integer(as.character( bestresults$interval ))

bestresults.bestprec <- bestresults[which.max(bestresults$precision),]
bestresults.bestrec <- bestresults[which.max(bestresults$recall),]
bestresults.bestfscore <- bestresults[which.max(bestresults$fscore),]

bestresults.finegrain <- bestresults[bestresults$interval < 360,]

bestresults.finegrain.bestprec <- bestresults.finegrain[which.max(bestresults.finegrain$precision),]
bestresults.finegrain.bestrec <- bestresults.finegrain[which.max(bestresults.finegrain$recall),]
bestresults.finegrain.bestfscore <- bestresults.finegrain[which.max(bestresults.finegrain$fscore),]

pdf(plotfilename_acceptableResultsFScoreGraphs)
   plot4PreferrableResultsFScore <- ggplot(data = data, aes(x=precision, y=recall)) +
     geom_point(size = 3, alpha = 0.0075, shape = 3) +
     geom_smooth() +
     geom_text(data = bestresults.finegrain.bestprec, aes(shape="Precision", x=precision - 0.025, y=recall, label = paste('paste(L==', gsub(" ", "", interval, TRUE), ',",",~t==', gsub(" ", "", threshold, TRUE), ',",",~gamma==', gsub(" ", "", gamma, TRUE), ',",",~nu==', gsub(" ", "", nu, TRUE), ")"), family = "serif", fontface = 3), size = 5, show_guide=FALSE, parse = TRUE, hjust=1, vjust=0.5) +
     geom_point(data = bestresults.finegrain.bestprec, aes(shape="Precision"), size = 6) +
     geom_text(data = bestresults.finegrain.bestrec, aes(shape="Recall", x=precision - 0.025, y=recall, label = paste('paste(L==', gsub(" ", "", interval, TRUE), ',",",~t==', gsub(" ", "", threshold, TRUE), ',",",~gamma==', gsub(" ", "", gamma, TRUE), ',",",~nu==', gsub(" ", "", nu, TRUE), ")"), family = "serif", fontface = 3), size = 5, show_guide=FALSE, parse = TRUE, hjust=1, vjust=0.5) +
     geom_point(data = bestresults.finegrain.bestrec, aes(shape="Recall"), size = 6) +
     geom_text(data = bestresults.finegrain.bestfscore, aes(shape="F-Score", x=precision - 0.025, y=recall, label = paste('paste(L==', gsub(" ", "", interval, TRUE), ',",",~t==', gsub(" ", "", threshold, TRUE), ',",",~gamma==', gsub(" ", "", gamma, TRUE), ',",",~nu==', gsub(" ", "", nu, TRUE), ")"), family = "serif", fontface = 3), size = 5, show_guide=FALSE, parse = TRUE, hjust=1, vjust=0.5) +
     geom_point(data = bestresults.finegrain.bestfscore, aes(shape="F-Score"), size = 6) +
     #        labs(list(title = expression(paste("F-Score graph")), x = "Precision", y = "Recall", alpha = "F-score", shape = "Interval\nlength\n[min]", colour = "Best…")) +
     labs(list(x = "Precision", y = "Recall", shape = "Best…")) +
     scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
     serious_theme +
     theme(legend.position=c(.2,.2))
   print(plot4PreferrableResultsFScore)
   
   dev.off()
   
#### Prints a graph with the best precision, recall and f-score trends obtained, w.r.t. the length of the interval (L). On top of highest precision & recall points, the best choice for nu, gamma and threshold is specified.
pdf(plotfilename_bestResVsIntervalLength)

   resultypes <- c("F-Score","Precision","Recall")
   #customshapetypes <- data.frame( types = resultypes, shapes = c(18,19,15)) # filled
   customshapetypes <- data.frame( types = resultypes, shapes = c(5,1,0)) # empty

   scale_label <- "Accuracy metrics"
   plot4bestresults.groupedByL <- ggplot(data = NULL, aes(x=interval)) +
     geom_line(data = bestresults.finegrain, aes(y=precision, linetype="Precision")) +
     geom_line(data = bestresults.finegrain, aes(y=recall, linetype="Recall")) +
     geom_line(data = bestresults.finegrain, aes(y=fscore, linetype="F-Score")) +
     geom_point(data = bestresults.finegrain, aes(y=precision), shape = 19, size = 3, show_guide=FALSE) +
     geom_point(data = bestresults.finegrain, aes(y=recall), shape = 15, size = 3, show_guide=FALSE) +
     geom_point(data = bestresults.finegrain, aes(y=fscore), shape = 18, size = 4, show_guide=FALSE) +
#     geom_text(data = bestresults.finegrain.bestprec, aes(x = interval, y = precision + 0.01, label = paste('paste(L==',gsub(" ", "", interval, TRUE),',~ t==', gsub(" ", "", threshold, TRUE), ',",",~ gamma==', gsub(" ", "", gamma, TRUE),',",",~~nu==', gsub(" ", "", nu, TRUE), ")"), family = "serif", fontface = 3), size = 5, hjust = 0.5, show_guide=FALSE, parse = TRUE) +
     geom_point(data = bestresults.finegrain.bestprec, aes(y=precision, shape="Precision"), size = 6) +
#     geom_text(data = bestresults.finegrain.bestrec, aes(x = interval, y = recall + 0.01, label = paste('paste(L==',gsub(" ", "", interval, TRUE),',~ t==', gsub(" ", "", threshold, TRUE), ',",",~ gamma==', gsub(" ", "", gamma, TRUE),',",",~~nu==', gsub(" ", "", nu, TRUE), ")"), family = "serif", fontface = 3), size = 5, hjust = 0.5, show_guide=FALSE, parse = TRUE) +
     geom_point(data = bestresults.finegrain.bestrec, aes(y=recall, shape="Recall"), size = 6) +
#     geom_text(data = bestresults.finegrain.bestfscore, aes(x = interval, y= fscore + 0.03, label = paste('paste(L==',gsub(" ", "", interval, TRUE),',~ t==', gsub(" ", "", threshold, TRUE), ',",",~ gamma==', gsub(" ", "", gamma, TRUE),',",",~~nu==', gsub(" ", "", nu, TRUE), ")"), family = "serif", fontface = 3), size = 5, hjust = 0.5, show_guide=FALSE, parse = TRUE) +
     geom_point(data = bestresults.finegrain.bestfscore, aes(y=fscore, shape="F-Score"), size = 6) +
     #        labs(list(title = "Best accuracy results w.r.t. the interval length", x = "Interval length [min]", y = "", linetype = scale_label, colour = scale_label)) +
     labs(list(x = "Interval length [sec]", y = "", linetype = scale_label, shape = scale_label)) +
     scale_shape_manual(breaks = customshapetypes$types, values=customshapetypes$shapes) +
     scale_x_continuous(breaks=seq(min(bestresults.finegrain[bestresults.finegrain$interval < 360,c("interval")]),max(bestresults.finegrain[bestresults.finegrain$interval < 360,c("interval")]),by=15), labels=c("120","","","","180","","","","240","","","","300")) +
     ylim( (floor(min(c(bestresults.finegrain$prec,bestresults.finegrain$recall,bestresults.finegrain$fscore)) *10 ) /10 ), (ceiling(max(c(bestresults.finegrain$prec,bestresults.finegrain$recall,bestresults.finegrain$fscore)) *10 ) /10 ) ) +
     serious_theme +
     theme(legend.position=c(.25,.125))
   print(plot4bestresults.groupedByL)
   
   dev.off()