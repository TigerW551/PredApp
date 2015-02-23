# Wine qualtity prediction by marozet
# This is the server logic for a Shiny web application.
# 
#
# http://shiny.rstudio.com
#
# http://archive.ics.uci.edu/ml/datasets/Wine+Quality
# data source: http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/

library(shiny)
library(ROCR)
library(caret)
#prepare dataset
red.wine<-read.csv("winequality-red.csv",sep=";")
red.wine$quality2<-0
red.wine$quality2[red.wine$quality>=6]<-1 #consider wines scored as 6 or above as good
red.wine$quality2<-as.factor(red.wine$quality2)
levels(red.wine$quality2)<-c("mediocre","good")

shinyServer(function(input, output) {

    inTrain <- reactive({set.seed(input$seed);inTrain <- createDataPartition(red.wine$quality2,p=0.75,list=FALSE)})
    training <- reactive({
        inTrain <- inTrain()
        training<-red.wine[inTrain,-grep("quality$",names(red.wine))]
    })
    testing <- reactive({
        inTrain <- inTrain()
        testing<-red.wine[-inTrain,-grep("quality$",names(red.wine))]
    })
    
    model <- reactive({
        training <- training()
        ctrl <- trainControl(method = "cv",number=input$cv_k)
        model<-train(quality2~.,data=training,method="gbm",verbose=FALSE,trControl=ctrl)
    })
    
    pred <- reactive({
        model <- model()
        testing <- testing()
        pred<-predict(model,testing,type="prob")
    })
    
    output$distPlot <- renderPlot({

      # run predictions
 
      testing <- testing()  
      pred <- pred()
      ROCpred<-prediction(pred$good,testing$quality2,label.ordering=c("mediocre","good"))
      ROCperf<-performance(ROCpred,"tpr","fpr")


    # draw the ROC curve
    plot(ROCperf,main="ROC Curve")
    x<-ROCperf@x.values[[1]][ROCperf@x.values[[1]]>input$pred_tresh][1]
    x_index<-which(ROCperf@x.values[[1]]==x)[1]
    y<-ROCperf@y.values[[1]][x_index]
    points(x,y,pch=4,cex=3,col="blue",lw=3)
  })
  confMatrix <- reactive({
      input$pred_tresh
      pred <- pred()
      testing <- testing()
      pred2 <- rep(0,nrow(pred))
      pred2[pred$good>as.numeric(input$pred_tresh)]<-1
      pred2<-as.factor(pred2)
      levels(pred2)<-c("mediocre","good")
      confusionMatrix(pred2,testing$quality2)
  })
    
    output$confusionMatrixTable<-renderTable({
        c <- confMatrix()
        c$table
    })
  
    output$cfAccuracy<-renderText({
        c <- confMatrix()
        paste("Accuracy: ",c$overall["Accuracy"])
    })
    output$cfSensitivity<-renderText({
        c <- confMatrix()
        paste("Sensitivity: ",c$byClass["Sensitivity"])
    })
  output$cfSpecificity<-renderText({
      c <- confMatrix()
      paste("Specificity: ",c$byClass["Specificity"])
  })
  output$cfBalanced<-renderText({
      c <- confMatrix()
      paste("Balanced Accuracy: ",c$byClass["Balanced Accuracy"])
  })

})
