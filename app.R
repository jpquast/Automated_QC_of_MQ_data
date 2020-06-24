#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# This app is meant to be used in combination with the Automated_QC_of_MQ_data script.
# You can explore the results of the MaxLFQ calculation.

library(shiny)
library(tidyverse)
library(data.table)
library(plotly)

# Increase maximum upload size to 1 GB
options(shiny.maxRequestSize=1000*1024^2)

# Define UI for application
ui <- fluidPage(
  
  # Application title
  titlePanel("MaxLFQ Explorer"),
  
  # Sidebar with a upload and protein selection input. 
  sidebarLayout(
    sidebarPanel(
      fileInput("complete_normalised", 
                "complete_normalised_maxLFQ.txt"),
      selectizeInput("protein", "Select a Protein", choices = NULL)
    ),
    
    # Show a plot of peptide and protein intensity over samples
    mainPanel(
      plotlyOutput("max_lfq")
    )
  )
)

# Define server logic required to load data and display plot
server <- function(input, output, session) {
  complete_normalised <- reactive({
    if(is.null(input$complete_normalised))
      return(NULL)
    # Read complete_normalised
    fread(input$complete_normalised$datapath)%>%
      mutate(precursor = paste0(modified_sequence, charge))%>%
      group_by(experiment, precursor)%>%
      mutate(normalised_precursor_intensity_log2 = log2(sum(normalised_precursor_intensity)))%>%
      ungroup()%>%
      drop_na(intensity)
  })
  
  choice_prot <- reactive({
    if(is.null(complete_normalised()))
      return(NULL)
    # Create vector of protein names for selection
    complete_normalised()$leading_razor_protein
  })
  observe({
    updateSelectizeInput(session, "protein", choices = choice_prot(), server = TRUE)
  })
  
  output$max_lfq <- renderPlotly({
    if(is.null(choice_prot()))
      return(NULL)
    # Create plot of peptide and protein intensity over samples
    plot <- complete_normalised()%>%
      filter(leading_razor_protein == input$protein)%>%
      distinct(precursor, leading_razor_protein, normalised_precursor_intensity_log2, protein_intensity_log2, experiment)%>%
      pivot_longer(c(normalised_precursor_intensity_log2, protein_intensity_log2), values_drop_na = TRUE, values_to = "intensity")%>%
      mutate(precursor = if_else(name == "protein_intensity_log2", "MaxLFQ_iq", precursor))%>%
      select(-name)%>%
      ggplot(aes(experiment, intensity, group = precursor, col = precursor))+
      geom_point()+
      geom_line(size = 1)+
      labs(title = input$protein, x = "Experiment", y = "Intensity [log2]", col = "Precursor")+
      scale_color_manual(values=c(rep("gray", complete_normalised()%>% filter(leading_razor_protein == input$protein)%>% distinct(precursor)%>% nrow()), "green"))+
      theme_bw()+
      theme(axis.text.x = element_text(angle = 45, hjust =1))
    
    ggplotly(plot)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
