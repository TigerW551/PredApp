
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Wine quality prediction"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
        helpText("You can change learning option here:"),
      numericInput("seed", "Set seed:", 123456789),
      sliderInput("split",
                  "Select split point for training and test data:",
                  min = 0.05,
                  max = 1,
                  value = 0.75),
      selectInput("method", "Select learning method", 
                  choices = list("Stochastic Gradient Boosting" = "gbm", "Random Forrest" = "rf",
                                 "Neural Network" = "nnet"), selected = "gbm"),
      sliderInput("cv_k",
                  "select k for k-fold cross validation:",
                  min = 2,
                  max = 8,
                  value = 2),
      sliderInput("pred_tresh",
                  "select treshold probability for prediction:",
                  min = 0,
                  max = 1,
                  value = 0.5),
      br(),
      h5("Cases in training data:"),
      verbatimTextOutput("n_training"),
      h5("Cases in test data:"),
      verbatimTextOutput("n_testing"),
      h5("Method selected:"),
      verbatimTextOutput("method"),
      h5("k-fold cross validation:"),
      verbatimTextOutput("cv_k"),
      h5("Probability treshold:"),
      verbatimTextOutput("pred_tresh")     
    ),

    # Show a plot of the generated distribution
    mainPanel(
        tabsetPanel(
            tabPanel("Prediction",
                helpText("This app attempts to learn how to distinguish red wine quality based on physicochemical tests. The data is taken from UCI Machine Learning Repository and is related to red vinho verde wine samples, from the north of Portugal. You can view the description of the data and download the original file ",a("[here]", href="http://archive.ics.uci.edu/ml/datasets/Wine+Quality",target="_blank"),". Please be patient while the app initializes."),
                plotOutput("ROCPlot"),
                h5("Confusion Matrix"),
                tableOutput("confusionMatrixTable"),
                helpText("rows - prediction, columns - reference"),
                h5("Performance measures"),
                verbatimTextOutput("cfAccuracy"),
                verbatimTextOutput("cfSensitivity"),
                verbatimTextOutput("cfSpecificity"),
                verbatimTextOutput("cfBalanced")
            ),
            tabPanel("Documentation",includeHTML("PredAppDocumentation.html"))
        )
        #verbatimTextOutput("confusionMatrixTable")
    )
  )
))
