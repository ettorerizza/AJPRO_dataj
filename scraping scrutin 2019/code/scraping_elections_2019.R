# Start the clock! Pour mesurer (par curiosité) le temps que prendra l'execution de ce script
start_time <- Sys.time()

library(rvest) #le package de scraping
library(tidyverse) #contient tout ce qu'il faut pour lire et manipuler les données

#Url de base pour les élections fédérales par commune
url_base_chambre_communes <-
  "https://elections2019.belgium.be/fr/resultats-chiffres?el=CK&id=CKX"

#CSV contenant la liste des communes, province, région, langue et leur code INS
#Attention, suite à des fusions en Flandre, il n'y a plus que 581 communes belges en 2019
#source : https://statbel.fgov.be/fr/propos-de-statbel/methodologie/classifications/geographie
communes <- read_csv("./Communes_belges_2019.csv",
                     col_types = cols(`INS` = col_character()))

#On récupère la liste des codes INS
INS <- communes$INS

#On reconstruit un lien vers les pages de chaque commune grâce aux codes INS
#exemple : https://elections2019.belgium.be/fr/resultats-chiffres?el=CK&id=CKX45062
liste_communes <- paste0(url_base_chambre_communes, INS)

#étape 2 : On récupère les tableaux de résultats qu'on stocke dans une seule liste
tables = vector()
for (url in liste_communes) {
  html = url %>%
    read_html()
  
  table = html %>%
    html_table(header = TRUE,
               fill = TRUE,
               dec = ",") %>% .[[2]]
  
  #on ajoute trois colonnes avec le nom de la commune, l'INS (pour le join) et l'URL de la page
  table$commune = html %>% html_node(".article-dataheader__title") %>% html_text()
  table$lien = url
  table$INS = stringr::str_extract(url, "(\\d+)$")
  
  #On n'oublie surtout pas de fusionner chaque table avec la liste tables
  tables = rbind(tables, table)
}

#on nettoye un peu lignes et colonnes superflues (pourrait se faire dans OpenRefine)
#tables = tables %>% drop_na(X2) %>% select(X2:X10, commune:lien)

#On renomme les colonnes
colnames(tables) = c(
  "numero",
  "liste",
  "colonne_vide",
  "Resultat_2019",
  "Resultat_2014",
  "pourcent_2019",
  "pourcent_2014",
  "evolution en %",
  "commune",
  "lien",
  "INS"
)

#on visualise le tableau (même chose que de cliquer sur son nom dans le volet)
View(tables)

#Petit nettoyage
#On supprime la colonne vide
tables <- tables %>% select(-colonne_vide)

#On met les poucentages sous forme de nombres pour calculs ultérieurs ?
#tables$pourcent_2019 = as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables$pourcent_2019))
#tables$pourcent_2014 = as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables$pourcent_2014))

#On fusionne avec le fichier d'origine de Statbel, ce qui permettra de trier par région, par province ou par langue
tables <- left_join(tables, communes, by = "INS")

#Dernier coup d'oeil au tableau
View(tables)

#On sauvegarde dans un fichier csv
write_csv(tables, "scraping_communes_federales_2019.csv")

# Stop the clock : affichera dans la console le temps d'execution du script
#(Moins de 5 minutes normalement pour les élections fédérales)
Sys.time() - start_time
