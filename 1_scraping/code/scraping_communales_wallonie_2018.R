# Start the clock! Pour mesurer (par curiosité) le temps que prendra l'execution de ce script
start_time <- Sys.time()


library("rvest") #le package de scraping
library("tidyverse") #contient tout ce qu'il faut pour manipuler les données

#URL de la page contenant les liens vers chaque commune (page de départ)
start_url = "https://elections2018.wallonie.be/fr/election?el=CG"

#Url de base du site 
base_url = "https://elections2018.wallonie.be"


#étape 1 : On récupère les urls des communes
url_communes =
  start_url %>%
  read_html() %>%
  #le sélecteur CSS "#block-blockelectionstart a" a été retrouvé (après un peu de chipo...)
  #grâce au selector gadget de Chrome
  html_nodes("#block-blockelectionstart a") %>%
  html_attr("href") %>%
  paste0(base_url, .)

#étape 2 : On récupère les URLs des listes électorales de chaque commune
listes = vector()
for (url in url_communes) {
  urls_listes = url %>%
    read_html() %>%
    html_nodes(".text-center a") %>%
    html_attr("href") %>%
    paste0(base_url, .)
  
  listes = c(listes, urls_listes)
  
}

#étape 3 : On récupère les tableaux de résultats qu'on stocke dans une seule liste
tables_completes = vector()
for (urls_tables in listes) {
  html = urls_tables %>%
    read_html()
  
  block_table = html %>%
    html_table(header = TRUE,
               fill = TRUE,
               dec = ",")
  
  table = block_table[[3]]
  
  #on crée trois nouvelles colonnes pour stocker le nom de la commune, le nom de la liste et l'URL de la page
  table$commune = html %>% html_node(".article-dataheader__title") %>% html_text()
  table$parti = html %>% html_node(".w-100") %>% html_text()
  table$lien = urls_tables
  
  #on fusionne chaque nouvelle table dans un tableau global
  tables_completes = rbind(tables_completes, table)
}

#########################################################################
#étapes 4 : Les opérations qui suivent sont du nettoyage de données. Elles pourraient très bien 
#être effectuée dans OpenRefine, voire dans Excel. Mais ceci vous fera gagner du temps.
#########################################################################



#On met les poucentages sous forme de nombres
tables_completes$pourcent_liste = as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables_completes$pourcent_liste))

#on élimine les mots "Commune de" et on efface les éventuels espaces en trop
tables_completes$commune = gsub("Commune de ", "", trimws(tables_completes$commune))

#on enlève le numéro devant le nom de parti et on efface les éventuels espaces en trop
tables_completes$parti = gsub("^\\d+ ", "", trimws(tables_completes$parti))

#on crée une colonne "liste" en concaténant (collant) nom de commune et de parti
tables_completes$liste = paste(tables_completes$commune, tables_completes$parti, sep="-")

# Stop the clock : affichera dans la console le temps d'execution du script 
#(environ 15 minutes pour le site de la Wallonie)
Sys.time() - start_time


##################################
#
#SAUVEGARDE DES RESULTATS
#
##################################


#étape 5 : On sauvegarde les résultats dans un csv "Excel compatible" (vous n'aurez pas de symboles bizarres à la place des lettres accentuées)
write_excel_csv(tables_completes, "scraping_2018_wallonie.csv")

