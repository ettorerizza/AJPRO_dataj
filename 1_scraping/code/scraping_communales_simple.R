library(rvest)
library(readr)

#On importe la liste de liens récupérés à l'aide de web scraper chrome

liens_listes_wallonie_bruxelles <-
  read_csv(
    "C:/Users/ettor/Desktop/AJPRO_dataj/1_scraping/data/liens_listes_wallonie_bruxelles.csv"
  )

#on jette un oeil sur le dataframe
View(liens_listes_wallonie_bruxelles)

listes = liens_listes_wallonie_bruxelles$liens

tables = vector()
for (i in listes) {
  html = i %>%
    read_html()
  
  table = html %>%
    #ATTENTION au html_node et pas nodes !
    html_node("#wrn_background_Id") %>%
    html_table(header = FALSE,
               fill = TRUE,
               dec = ",")
  
  #on cree trois colonnes avec le nom de la commune, le nom de la liste et l'URL de la page
  table$commune = html %>% html_node(".uppercaseb") %>% html_text()
  table$parti = html %>% html_node(".subtitle") %>% html_text()
  table$lien = i
  
  #On n'oublie surtout pas de fusionner chaque table avec la liste tables
  tables = rbind(tables, table)
}

#on nettoye un peu lignes et colonnes superflues (pourrait se faire dans OpenRefine)
tables = tables %>% drop_na(X2) %>% select(X2:X10, commune:lien)

#On renomme les colonnes (pourrait se faire dans OpenRefine voire dans le csv)
colnames(tables) = c(
  "place_liste",
  "nom",
  "voix",
  "pourcent_liste",
  "voix_devolues",
  "voix_apres_devolution",
  "voix_restantes",
  "position_elu",
  "position_suppleance",
  "commune",
  "parti",
  "lien"
)

#on visualise le tableau (même chose que de cliquer sur son nom dans le volet)
View(tables)

#On sauvegarde dans un fichier cv
write_csv(tables, "scraping_wallonie_bruxelles.csv")