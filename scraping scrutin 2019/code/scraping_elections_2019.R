# Start the clock! Pour mesurer (par curiosité) le temps que prendra l'execution de ce script
start_time <- Sys.time()

library(rvest) #le package de scraping
library(tidyverse) #contient tout ce qu'il faut pour lire et manipuler les données

#Plutôt que de scraper les liens vers les résultats, j'ai reconstruit leurs URLs en 
#utilisant le code INS de la commune. 
#Pour scraper les régionales, il faudra changer la variable url_base_chambre_communes 
#en "https://elections2019.belgium.be/fr/resultats-chiffres?el=VL&id=VLX" (pour la Flandre) 
#ou "https://elections2019.belgium.be/fr/resultats-chiffres?el=WL&id=WLX" (Wallonie) 
#ou "https://elections2019.belgium.be/fr/resultats-chiffres?el=BR&id=BRX" (BXL).

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

#On renomme les colonnes
colnames(tables) = c(
  "numero",
  "liste",
  "colonne_vide",
  "resultat_2019",
  "resultat_2014",
  "pourcent_2019",
  "pourcent_2014",
  "evolution_en_pourcent",
  "commune",
  "lien",
  "INS"
)

#on visualise le tableau (même chose que de cliquer sur son nom dans le volet)
View(tables)

#Petit nettoyage
#On supprime la colonne vide
tables <- tables %>% select(-colonne_vide)

#On fusionne avec le fichier d'origine de Statbel, ce qui permettra de trier par région, par province ou par langue
tables <- left_join(tables, communes, by = "INS")

#Dernier coup d'oeil au tableau
View(tables)

#On sauvegarde les variables
save.image("data.RData")

#On sauvegarde dans un fichier csv
write_csv(tables, "scraping_communes_federales_2019_original.csv")

# Stop the clock : affichera dans la console le temps d'execution du script
#(Moins de 5 minutes normalement pour les élections fédérales)
Sys.time() - start_time
