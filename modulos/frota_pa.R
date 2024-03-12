# Funções de módulo de Infraestrutura - Estadual
# Função de UI
frotapa_ui <- function(id) {
  fluidPage(
    #Controle----
            panel(
              fluidRow(
              column(
                2,
                selectInput(
                  inputId = NS(id, "ri"),
                  label = "Localidade",
                  choices = unique(frota2[["ri"]]),
                  width = "200px"
                )
              ),
              column(
                2,
                selectInput(
                  inputId = NS(id, "cat"),
                  label = "Tipo de Frota/Total",
                  choices = unique(frota2[["categoria"]]),
                  width = "200px"
                )
              ),
              column(
                2,
                selectInput(
                  inputId = NS(id, "ano"),
                  label = "Ano",
                  choices = sort(unique(frota2[["ano"]]), decreasing = T),
                  width = "100px"
                )
              )
            )),
            fluidRow(
              ## Mapa - Total da Frota de Veículos Subdivididos em Licenciados e Não Licenciados----
              box(
                title = textOutput(NS(id, "txtmap")),
                status = "primary",
                collapsed = F,
                headerBorder = T,
                width = 12,
                withSpinner(
                  leafletOutput(NS(id, "map"), height = "600px"),
                  type = 8,
                  color = "#c800c8",
                  size = 0.5
                ),
                footer = 
                  list(
                    div(
                      style = "display: flex; justify-content: space-between;",
                      div(
                        tags$h6(tags$b("Fonte:", style = 'font-family: sans-serif;'), "Detran-PA"),
                        tags$h6(tags$b("Elaboração:"), "Detran-PA")
                      ),
                      div(
                        style = "display: flex; justify-content: center; align-items: center;"
                      )
                    )
                  )
              ),
              ## Tabela - Total da Frota de Veículos Subdivididos em Licenciados e Não Licenciados----
              box(
                title = textOutput(NS(id, "txttab")),
                status = "primary",
                collapsed = F,
                headerBorder = T,
                width = 12,
                withSpinner(
                  reactableOutput(NS(id, "tab"),height = "600px"),
                  type = 8,
                  color = "#c800c8",
                  size = 0.5
                ),
                footer = 
                  list(
                    div(
                      style = "display: flex; justify-content: space-between;",
                      div(
                        tags$h6(tags$b("Fonte:", style = 'font-family: sans-serif;'), "Detran-PA"),
                        tags$h6(tags$b("Elaboração:"), "Detran-PA")
                      ),
                      div(
                        style = "display: flex; justify-content: center; align-items: center;",
                        downset_ui(NS(id, "tabdown"))
                      )
                    )
                  )
            )
          ),
    fluidRow(
      ## Gráfico Total da Frota de Veículos Subdivididos em Licenciados e Não Licenciados----
      box(
        title = textOutput(NS(id, "txtgraf")),
        status = "primary",
        collapsed = F,
        headerBorder = T,
        width = 12,
        withSpinner(
          echarts4rOutput(NS(id, "graf")),
          type = 8,
          color = "#c800c8",
          size = 0.5
        ),
        footer = 
          list(
            div(
              style = "display: flex; justify-content: space-between;",
              div(
                tags$h6(tags$b("Fonte:", style = 'font-family: sans-serif;'), "Detran-PA"),
                tags$h6(tags$b("Elaboração:"), "Detran-PA")
              ),
              div(
                style = "display: flex; justify-content: center; align-items: center;",
                downset_ui(NS(id, "grafdown"))
              )
            )
          )
       )
    )
  )
}

# Função do modulo servidor
frotapa_Server <- function(id) {
  moduleServer(id, function(input, output, session) {
  #Mapa - Total da Frota de Veículos----
    titulo1 <- reactive({
      if (input$ri == "Pará") {
        paste0("Frota de Veículos ",
               input$cat,", ",
               input$ri," - ",
               input$ano)
      }else{
        paste0("Frota de Veículos ",
               input$cat,", Região de Integração ",
               input$ri," - ",
               input$ano)
      }
    })
    #Mapa
    output$txtmap <- renderText({
      titulo1()
    })

    output$map <- renderLeaflet({
      # Tratamento da informação
      ## Filtrando informação
      if (input$ri == "Pará") {
        df <- frota2 %>%
          filter(ri != "Pará",
                 ano == input$ano,
                 categoria == input$cat) %>%
          select(ri,municipio, ano, valor)
        x <- cbind(geopa, df)
      } else {
        df <- frota2 %>%
          filter(ri != "Pará",
                 ano == input$ano,
                 categoria == input$cat) %>%
          select(ri,municipio, ano, valor)
        x <- cbind(geopa, df)
        x <- x %>% filter(ri == input$ri)
      }

      z <- x$valor[x$valor > 0]
      bk <- unique(getJenksBreaks(z, 6, subset = NULL))
      x$valor[x$valor == 0] <- NA
      bins <- c(bk)
      if (length(bins) < 2 || length(bins) < 5) {
        bins <- 5
      }

      pal <-
        colorBin(
          c("#FECCFE", "#f2a1f1", "#e676e4", "#d844d5", "#c800c8"),
          domain = x$valor,
          bins = bins
        )
      conteudo <-
        sprintf(
          "<strong>%s</strong><br/><b>%s:</b> %s ",
          x$name_muni,
          input$cat,
          ifelse(
            is.na(x$valor),
            "Não disponível",
            format(x$valor, big.mark = ".", decimal.mark = ",")
          )
        ) %>% lapply(htmltools::HTML)

      # Mapas com leafleft
      leaflet(x,
              options =
                leafletOptions(minZoom = 0,
                               maxZoom = 15)) %>%
        addTiles() %>%
        addPolygons(
          weight = 2,
          opacity = 1,
          color = "black",
          fillOpacity = 1,
          fillColor = ~ pal(valor),
          dashArray = 1,
          smoothFactor = 1.5,
          highlightOptions =
            highlightOptions(
              weight = 3,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.5,
              bringToFront = TRUE
            ),
          label = conteudo,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto"
          )
        ) %>%
        addLegend(
          pal = pal,
          values = ~ valor,
          opacity = 0.7,
          title = input$cat,
          position = "bottomright",
          na.label = "Não disponível",
          labFormat = labelFormat_decimal(
            big.mark = ".",
            decimal.mark = ",",
            digits = 2
          )
        )
    })

    
  #Tabela - Total da Frota de Veículos Subdivididos em Licenciados e Não Licenciados----
    #Título
    texto2 <- reactive({
      if (input$ri == "Pará") {
        paste0(
          "Quantidade de Veículos Total, Licenciado e Não licenciado Município ",
          input$ri,
          " - ",
          input$ano
        )
      } else{
        paste0(
          "Quantidade de Veículos Total, Licenciado e Não licenciado Município, Região de Integração ",
          input$ri,
          " - ",
          input$ano
        )
      }
    })

    output$txttab <- renderText({
      texto2()
    })
    

    # Filtra os dados para download
    frotatabdow <- reactive({
      if (input$ri == "Pará") {
        x <- frota2 %>%
          filter( ri != "Pará", ano == input$ano) %>%
          select(ri,
                 municipio,
                 categoria,
                 valor) %>%
          pivot_wider(names_from = categoria, values_from = valor)
      } else {
        x <- frota2 %>%
          filter( ri != "Pará", ano == input$ano) %>%
          select(ri,
                 municipio,
                 categoria,
                 valor) %>%
          pivot_wider(names_from = categoria, values_from = valor)
        x <- x %>% filter(ri == input$ri)
      }
    })
    
    ## Monitora a base filtrada, defini o texto a ser baixado
    observeEvent(frotatabdow(), {
      texto2()
      downset_Server("tabdown", frotatabdow(), texto2())
    })
  
    #Tabela
    output$tab <- renderReactable({
      if (input$ri == "Pará") {
        x <- frota2 %>%
          filter( ri != "Pará", ano == input$ano) %>%
          select(ri,
                 municipio,
                 categoria,
                 valor) %>%
          pivot_wider(names_from = categoria, values_from = valor)
      } else {
        x <- frota2 %>%
          filter( ri != "Pará", ano == input$ano) %>%
          select(ri,
                 municipio,
                 categoria,
                 valor) %>%
          pivot_wider(names_from = categoria, values_from = valor)
        x <- x %>% filter(ri == input$ri)
      }
      
      x %>% reactable(
        defaultPageSize = 10,
        striped = FALSE,
        highlight = TRUE,
        bordered = TRUE,
        outlined = TRUE,
        resizable = TRUE,
        showSortable = TRUE,
        pagination = FALSE,
        columns = list(
          ri = colDef(name = "Região de Integração"),
          municipio = colDef(name = "Municípios", sticky = "left"),
          Frota = colDef(name = "Frota", format = colFormat(separators = T)),
          Licenciados = colDef(name = "Licenciados", format = colFormat(separators = T)),
          `Não Licenciados` = colDef(name = "Não Licenciados", format = colFormat(separators = T))
        ),
        defaultColDef = colDef(
          footerStyle = list(fontWeight = "bold"),
          na = "-",
          headerStyle = list(background = "#f7f7f8")
        ),
        language = reactableLang(
          noData = "Sem informação",
          pageInfo = "{rowStart} a {rowEnd} de {rows} linhas",
          pagePrevious = "Anterior",
          pageNext = "Próximo",
          pagePreviousLabel = "Anterior",
          pageNextLabel = "Proximo"
        )
      )
    })
    #Gráfico - Total da Frota de Veículos Subdivididos em Licenciados e Não Licenciados----
    texto3 <- reactive({
      paste0(
        "Total da Frota de Veículos Subdivididos em Licenciados e Não Licenciados, Pará - ",
        min(frota2$ano),
        " a ",
        max(frota2$ano)
      )
    })
    #Texto
        output$txtgraf <- renderText({
          texto3()
        })
    # Filtra os dados para download     
        frotagrafdow <- reactive({
          frota2 %>%
            filter(municipio == "Pará") %>%
            pivot_wider(names_from = categoria, values_from = valor)
        })
        # Monitora a base filtrada, defini o texto a ser baixado
        observeEvent(frotagrafdow(), {
          texto3()
          downset_Server("grafdown", frotagrafdow(), texto3())
        })

    output$graf <- renderEcharts4r({
      frota2 %>%
        filter(municipio == "Pará") %>%
        pivot_wider(names_from = categoria, values_from = valor) %>%
        e_chart(x = ano) %>%
        e_line(
          serie = Licenciados,
          name = "Licenciados",
          legend = T,
          symbol = "roundRect",
          symbolSize = 6,
          legendHoverLink = T,
        ) %>%
        e_line(
          serie = `Não Licenciados`,
          name = "Não Licenciados",
          legend = T,
          symbol = "roundRect",
          symbolSize = 6,
          legendHoverLink = T,
          itemStyle = list(barBorderRadius = 5)
        ) %>%
        e_line(
          serie = Frota,
          name = "Frota",
          legend = T,
          symbol = "roundRect",
          symbolSize = 6,
          legendHoverLink = T,
          itemStyle = list(barBorderRadius = 5)
        ) %>%
        e_tooltip(
          trigger = "axis",
          formatter = e_tooltip_pointer_formatter("decimal", digits = 0, locale = "pt-BR"),
          axisPointer = list(type = "shadow")
        ) %>%
        e_x_axis(
          axisLabel = list(show = T, fontSize = 11),
          name = "Ano",
          splitLine = list(show = T),
          nameTextStyle = list(fontWeight = "bold", fontSize = 14)
        ) %>%
        e_y_axis(
          name = "Quantidade",
          nameTextStyle = list(fontWeight = "bold", fontSize = 14),
          scale = T,
          axisLabel = list(
            formatter = htmlwidgets::JS(
              "
              function (value, index) {
              return value.toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
              }
            "
            )
          )
        ) %>%
        e_locale("pt-Br") %>%
        e_datazoom(toolbox = F, fillerColor = "#E5F5F9") %>%
        e_grid(show = T)
    })

  })
}

# Play do Módulo
ui <- dashboardPage(header = dashboardHeader(),
                    sidebar = dashboardSidebar(),
                    body = dashboardBody(fluidPage(
                      frotapa_ui("frotapa")
                    )))


server <- function(input, output) {
  frotapa_Server("frotapa")
}

shinyApp(ui, server)
