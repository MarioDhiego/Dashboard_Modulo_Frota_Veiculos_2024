# Interface do usuário---------------------------------------
#Carregando----
source('global.R')
shinyApp(
  ui = dashboardPage(
    header = dashboardHeader(
      title = dashboardBrand(
        title = tags$strong("Detran - PA"),
        href = "https://www.detran.pa.gov.br/index_.php",
        image = "detran_pa.png",
        color ="gray",
      )
    ), 
    # dbHeader,
    skin = "black",
    scrollToTop = T,
    options = list(sidebarExpandOnHover = T),
    sidebar = dashboardSidebar(
      skin = "dark",
      minified = T,
      collapsed = F,
      sidebarMenu(
        menuItem("Visão Geral", tabName = "visao_geral",icon = icon("display")),
        menuItem("Perfil dos Veículos", tabName = "carac_veiculo",icon = icon("magnifying-glass"),
                 menuSubItem("Pará e R.I's",tabName = "carac_loc",icon = icon("map")),
                 menuSubItem("Municípios",tabName = "carac_muni",icon = icon("location-dot")),
                 menuSubItem("Por Tipo de Veículo",tabName = "carac_tipo",icon = icon("car"))
                 ),
        menuItem("Frota",tabName = "frota",icon = icon("car"),
                 menuSubItem("Pará",tabName = "pa"),
                 menuSubItem("Municípios",tabName = "muni")),
        menuItem("Sobre", tabName = "sobre",icon = icon("book"))
      )      
    ),
    body = dashboardBody(
      tabItems(
        tabItem(tabName = "visao_geral",fluidPage(total_ui("geral"))),
        tabItem(tabName = "carac_loc",fluidPage(loc_ui("loc"))),
        tabItem(tabName = "carac_muni",fluidPage(muni_ui("muni"))),
        tabItem(tabName = "carac_tipo",fluidPage(tipo_ui("tipo"))),
        tabItem(tabName = "pa",fluidPage(frotapa_ui("frotapa"))),
        tabItem(tabName = "muni",fluidPage(frotamuni_ui("frotamuni"))),
        tabItem(tabName = "sobre",fluidPage(
          panel(
            title = "Sobre R, ShinyR e bs4dash",
            width = 6,  # Ajuste a largura conforme necessário
            status = "primary",
            solidHeader = TRUE,
            align = "center",
            justify = "justify",
            fluidRow(
              column(4,
              div(
                style = "text-align: left; text-justify: inter-word;",  # Adiciona estilo CSS para centralizar e justificar o texto
                HTML("
                <h2>Sobre as tecnologias usadas</h2>
                <p>R é uma linguagem de programação estatística amplamente utilizada. 
             ShinyR é um pacote para criar aplicativos web interativos usando R. 
             bs4dash é uma extensão do shinydashboard que utiliza o Bootstrap 4. 
             Ele fornece uma variedade de componentes e funcionalidades para criar dashboards modernos e responsivos em R. 
             O pacote é particularmente útil para a criação de aplicações web interativas e visualmente atraentes, 
             aproveitando as capacidades do Bootstrap 4 para o design de interface do usuário. 
             Além disso, a integração com o Shiny facilita a construção de dashboards dinâmicos e interativos 
             que respondem às interações do usuário em tempo real. 
             Ao combinar R, ShinyR e bs4dash, os desenvolvedores têm à disposição uma poderosa combinação 
             para a criação de aplicações web estatísticas avançadas e dashboards envolventes.</p>")
              )),
              column(8, align = "center", img(src = "Dashboard.gif", height = 350))
              
            ),
            footer = fluidRow(
              column(4, align = "center", tags$img(src = "R_logo.svg.png", height = 100)),
              column(4, align = "center", tags$img(src = "hex-shiny.png", height = 100)),
              column(4, align = "center", tags$img(src = "bs4dash.png", height = 100))
            )
          )        ))
        )
    ),
    footer = dashboardFooter(
      left = tags$b("Detran-PA"), 
      right = "Belém-PA, 2024 v.1"
    ),
    title = "Dashboard Detran-PA"
  ),
  server = function(input, output,session) {
    total_Server("geral")
    loc_Server("loc")
    muni_Server("muni")
    tipo_Server("tipo")
    frotapa_Server("frotapa")
    frotamuni_Server("frotamuni")
    
  }
)




