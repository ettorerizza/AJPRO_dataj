# Start the clock! Pour mesurer le temps que prendra ce script
start_time <- Sys.time()

#On importe les packages nécessaires (à installer au besoin)
library(rvest)
library(tidyverse)

#Url de départ
start_url = "http://electionslocales.wallonie.be/2012/fr/com/results/results_start.html"

#On récupère les urls des communes
url_communes =
  start_url %>%
  read_html() %>%
  html_nodes(".normal a") %>%
  html_attr("href") %>%
  paste0("http://electionslocales.wallonie.be/2012/fr/com/results/",
         .)

#On récupère les URLs des listes électorales de chaque commune
listes = vector()
for (i in url_communes) {
  urls = i %>%
    read_html() %>%
    html_nodes(xpath = "//a[contains(@href,'../preferred/preferred_CGM')]") %>%
    html_attr("href") %>%
    gsub("../preferred/", "/preferred/", .) %>%
    paste0("http://electionslocales.wallonie.be/2012/fr/com", .)
  
  listes = c(listes, urls)
  
}

#On récupère les tableaux de résultats qu'on stocke dans une seule liste
tables = vector()
for (i in listes) {
  html = i %>%
    read_html()
  
  table = html %>%
    html_node("#wrn_background_Id") %>%
    html_table(header = FALSE,
               fill = TRUE,
               dec = ",")
  
  #on crée trois colonnes avec le nom de la commune, le nom de la liste et l'URL de la page
  table$commune <- html %>% html_node(".uppercaseb") %>% html_text()
  table$parti = html %>% html_node(".subtitle") %>% html_text()
  table$lien = i
  tables = rbind(tables, table)
}

#On supprime les lignes inutiles et on sélectionne les colonnes intéressantes
tables = tables %>% drop_na(X2) %>% select(X2:X10, commune:lien)

#on change le nom de ces colonnes
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

#On crée une colonne avec les poucentages sous forme de nombres
tables$pourcent_liste = as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables$pourcent_liste))

#on élimine les mots "Commune de" et on efface les espaces et retour chariot en trop
tables$commune = gsub("Commune de ", "", trimws(tables$commune))

# Stop the clock : affichera dans la console le temps d'execution
Sys.time() - start_time

#On sauvegarde les tables de résultats dans un csv
write_csv(tables, "scraping_wallonie.csv")