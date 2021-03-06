# SERVER
peakMonitServer <- shinyServer(function(input, output, session){

  session$onSessionEnded(function(){
  shiny::stopApp()})
  # function
  elCoord <- function (x, y, alfa = 0.95, len = 200){
    N <- length(x)
    A <- 2
    mypi <- seq(0, 2 * pi, length = len)
    r1 <- sqrt(var(x) * qf(alfa, 2, N - 2) * (2 * (N^2 - 1)/(N *
                                                               (N - 2))))
    r2 <- sqrt(var(y) * qf(alfa, 2, N - 2) * (2 * (N^2 - 1)/(N *
                                                               (N - 2))))
    cbind(r1 * cos(mypi) + mean(x), r2 * sin(mypi) + mean(y))
  }

  output$exMetabTable <- DT::renderDataTable({

  })


  subMetabEx <- reactive({
    if(input$Compound == 'MeanAllCompounds'){
    plot.df <- t(data.frame(colMeans(exMetab[, obsNames])))
    } else {
    plot.df <- exMetab[exMetab$name %in% input$Compound, , drop=FALSE]
    }
  if(!is.null(input$Exclude)){
    remIdx <- which(obsNames %in% input$Exclude)
    obsNamesTmp <- obsNames[-remIdx]
    plot.df <- data.frame(obsNames=obsNamesTmp,
                          peakArea=as.numeric(t(plot.df[, obsNamesTmp, drop=FALSE])),
                          sampleType=obsTypeStr[-remIdx],
                          sampleCol=obsTypeCol[-remIdx],
                          paddSampType=paddSampTypes[-remIdx],
                          stringsAsFactors = FALSE)
  } else {
    plot.df <- data.frame(obsNames=obsNames,
                          peakArea=as.numeric(t(plot.df[, obsNames, drop=FALSE])),
                          sampleType=obsTypeStr,
                          sampleCol=obsTypeCol,
                          paddSampType=paddSampTypes,
                          stringsAsFactors = FALSE)
  }
  ###calculate the percentage of the mean
  # if(input$Deviation_mean=="YES")
  # {
  #   plot.df[,2]<-(as.numeric(as.character(plot.df[,2]))/mean(as.numeric(as.character(plot.df[,2]))))*100
  # }
  qcIdx <- plot.df[, 1] %in% qcNames
  plot.df$avg <- mean(plot.df[qcIdx, 2])
  plot.df$sdplus <- plot.df$avg + sd(plot.df[qcIdx, 2])
  plot.df$sdneg <-  plot.df$avg - sd(plot.df[qcIdx, 2])

  if(input$Compound == 'MeanAllCompounds'){
    exMetabSub <- exMetab[, setdiff(names(exMetab), obsNames), drop=FALSE]
  } else {
    exMetabSub <- exMetab[exMetab$name %in% input$Compound,
                          setdiff(names(exMetab), obsNames), drop=FALSE]
  }

  return(list(plotDf=plot.df, exMetabSub=exMetabSub))
  })

  output$exMetabTable <- DT::renderDataTable({
    subExMetab <- subMetabEx()$exMetabSub
  }, options=list(scrollX = TRUE, scrollY='250px'))

  output$exMetabPlot <- shiny::renderPlot({

     plot.df <- subMetabEx()$plotDf

      # plot.df %>% ggvis(~obsNames, ~peakArea, fill = ~sampleType) %>%
      #   layer_bars() %>%
      #   add_tooltip(function(df) df$peakArea) %>%
      #   bind_shiny("exMetabPlot")
      # layer_point(props(fill = ~factor(cyl)))
      par(mar=c(7,4.1,4.1,2.1))
      xx <- barplot(plot.df$peakArea, xaxt='n', width = 0.85,
                    xlab='sample runs', ylab='peakArea', col=plot.df$sampleCol, las=2)

      ## Add text at top of bars
      ## Add x-axis labels
      axis(1, at=xx, labels=substr(plot.df$paddSampType, 1, 50), tick=FALSE, las=3,
           line=-0.5, cex.axis=0.9, srt = 60, adj= 1, xpd = TRUE)
    # rOrdPlot <- rCharts::rPlot(x="obsNames", y=colnames(plot.df)[2],
    #                            color="sampleCol", type="bar", data=plot.df,
    #                            size = list(const = 5))
    #
    # rOrdPlot$set(dom="exMetabPlot")
    # rOrdPlot$layer(y='avg', copy_layer=T, type='line', color=list(const='red'))
    # rOrdPlot$layer(y='sdplus', copy_layer=T, type='line', color=list(const='green'))
    # rOrdPlot$layer(y='sdneg', copy_layer=T, type='line', color=list(const='green'))
    #
    # return(rOrdPlot)

  })



  #
  output$exMetabDataPoints <- DT::renderDataTable({
    plot.df <- subMetabEx()$plotDf
    bpDf <- brushedPoints(plot.df, input$exMetabPlot_brush, xvar='paddSampType', yvar='peakArea')
    return(bpDf[, c('obsNames', 'peakArea', 'sampleType', 'paddSampType')])

  })


  output$pcaPlot1 <- shiny::renderPlot({

    if(!is.null(input$Exclude)){
      remIdx <- which(obsNames %in% input$Exclude)
      remIdx <- setdiff(1:length(obsNames), remIdx)
    } else {
      remIdx <- 1:length(obsNames)
    }

    if(is.null(input$pcaPlot1_brush)){
      if(input$pcaPlotType == 'scores'){
      xlimTmp <- range(scoresDf[remIdx, 1])
      ylimTmp <- range(scoresDf[remIdx, 2])
      } else {
      xlimTmp <- range(loadingsDf[, 1])
      ylimTmp <- range(loadingsDf[, 2])
      }
    } else {
      xlimTmp <- c(input$pcaPlot1_brush$xmin, input$pcaPlot1_brush$xmax)
      ylimTmp <- c(input$pcaPlot1_brush$ymin, input$pcaPlot1_brush$ymax)
    }

    if(input$pcaPlotType == 'scores'){

    plot(scoresDf[remIdx, , drop=FALSE], col=obsTypeCol[remIdx], xlim=xlimTmp, ylim=ylimTmp)
    abline(h = 0, v = 0, col = "black")
    el <- elCoord(scoresDf[remIdx, 1], scoresDf[remIdx, 2], alfa = 0.95)#input$hotelling)
    lines(el)
    # switch(input$legendPos, topright={
    legend('topright', unique(obsTypeStr[remIdx]), col=unique(obsTypeCol[remIdx]), pch=1)
    if(!is.null(input$pcaPlot1_brush)){
      text(scoresDf[remIdx, , drop=FALSE], row.names(scoresDf)[remIdx], pos=3, cex=0.8)
    }
    } else {
      plot(loadingsDf, xlim=xlimTmp, ylim=ylimTmp)
      abline(h = 0, v = 0, col = "black")
      el <- elCoord(loadingsDf[, 1], loadingsDf[, 2], alfa = 0.95)#input$hotelling)
      lines(el)
      text(loadingsDf, exMetab$name, pos=3)
    }
  })
}) # end server
