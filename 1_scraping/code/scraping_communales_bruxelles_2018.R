# Start the clock! Pour mesurer (par curiosité) le temps que prendra l'execution de ce script
start_time <- Sys.time()


library("rvest") #le package de scraping
library("tidyverse") #contient tout ce qu'il faut pour manipuler les données

#URL de la page contenant les liens vers chaque commune (page de départ)
start_url = "http://bru2018.brussels/fr/counting/index.html"

#Url de base du site 
base_url = "http://bru2018.brussels"


#étape 1 : On récupère les urls des communes
url_communes =
  start_url %>%
  read_html() %>%
  #le sélecteur CSS a été retrouvé 
  #grâce au selector gadget de Chrome
  html_nodes(".title a") %>%
  html_attr("href") %>%
  paste0(base_url, .)


#étape 2 : On récupère les URLs des listes électorales de chaque commune
listes = vector()
for (url in url_communes) {
  urls_listes = url %>%
    read_html() %>%
    html_nodes(".candidats a") %>%
    html_attr("href") %>%
    paste0(base_url, .)
  
  listes = c(listes, urls_listes)
  
}


#étape 3 : On récupère les tableaux de résultats qu'on stocke dans une seule liste
tables_completes = vector()

for(urls_tables in listes){
  html = urls_tables %>%
    read_html()
  
  candidats = html %>%
    html_nodes(".col-xs-5") %>% 
    html_text() %>% 
    trimws()
  
  voix = html %>%
    html_nodes(".col-xs-2 div+ div") %>% 
    html_text() %>% 
    trimws()
  
  elu = html %>%
    html_nodes(".inline-block:nth-child(6)") %>% 
    html_text() %>% 
    trimws()
  
  table = as.tibble(cbind(candidats, voix, elu))
  
  #on crée trois nouvelles colonnes pour stocker le nom de la commune, le nom de la liste et l'URL de la page
  table$commune = html %>% html_node(".col-xs-8 a") %>% html_text()
  table$parti = html %>% html_node(".subtitle+ .title-print-info button") %>% html_text()
  table$lien = urls_tables
  
  #on fusionne chaque nouvelle table dans un tableau global
  tables_completes = rbind(tables_completes, table)
}


# Stop the clock : affichera dans la console le temps d'execution du script 
#(environ 15 minutes pour le site de la Wallonie)
Sys.time() - start_time

#########################################################################
#Pas le temps de nettoyer les résultats automatiquement
#à faire dans OpenRefine
#vérifier s'il y a bien 4107 candidats à BXL
#########################################################################

#étape 5 : On sauvegarde les résultats dans un csv "Excel compatible" (vous n'aurez pas de symboles bizarres à la place des lettres accentuées)
write_excel_csv(tables_completes, "scraping_2018_bruxelles.csv")



