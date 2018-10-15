library(rvest) #à installer d'abord si ce n'est fait
library(readr) #à installer d'abord si ce n'est fait

#ne faite pas attention à ces lignes de code
#elles servent à définir automatiquement votre
#répertoire de travail dans le bon dossier 
#cela vous évitera de devoir chipoter
set_wd <- function() {
  library(rstudioapi) # à installer au besoin
  current_path <- getActiveDocumentContext()$path 
  setwd(dirname(current_path ))
  print( getwd() )
}
set_wd()

#On importe la liste de liens récupérés à l'aide de web scraper chrome

liens_listes_wallonie_bruxelles <-
  read_csv("../data/liens_listes_wallonie_bruxelles.csv")

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

#on élimine les mots "Commune de" et on efface les espaces et retour chariot en trop
tables$commune = gsub("Commune de ", "", trimws(tables$commune))

#On sauvegarde dans un fichier cv
write_csv(tables, "scraping_wallonie_bruxelles.csv")