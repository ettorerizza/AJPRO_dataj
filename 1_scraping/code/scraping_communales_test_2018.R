# Start the clock! Pour mesurer (par curiosité) le temps que prendra l'execution de ce script
start_time <- Sys.time()

#On importe les trois packages nécessaires (en les installant si nécessaire)
library(rvest) #le package de scraping
library(tidyverse) #contient tout ce qu'il faut pour manipuler les données
library(rstudioapi) #ne sert que pour la fonction setwd()

#ne faite pas attention aux six lignes de code suivantes.
#elles servent juste à définir automatiquement votre
#répertoire de travail dans le bon dossier, 
#ce qui vous évitera des chipotages. 
#Votre répértoire de travail (l'endroit où vous pourrez retrouver les résultats)
#sera affiché dans votre concole, en bas.
set_wd <- function() {
  current_path <- getActiveDocumentContext()$path 
  setwd(dirname(current_path ))
  print( getwd() )
}
set_wd()


#####################################################################

#ATTENTION, ces deux URL devront être modifiées le 14 octobre !

#URL de la page contenant les liens vers chaque commune (page de départ)
start_url = "https://rwa-ma5.martineproject.be/fr/election?el=CG"

#Url de base du site (sera différente pour la Wallonie et Bruxelles)
base_url = "https://rwa-ma5.martineproject.be"

#####################################################################

#On récupère les urls des communes
url_communes =
  start_url %>%
  read_html() %>%
  #le sélecteur CSS "#block-blockelectionstart a" a été retrouvé (après un peu de chipo...)
  #grâce au selector gadget de Chrome
  html_nodes("#block-blockelectionstart a") %>%
  html_attr("href") %>%
  paste0(base_url, .)

#On récupère les URLs des listes électorales de chaque commune
listes = vector()
for (url in url_communes) {
  urls_listes = url %>%
    read_html() %>%
    html_nodes(".text-center a") %>%
    html_attr("href") %>%
    gsub("../preferred/", "/preferred/", .) %>%
    paste0(base_url, .)
  
  listes = c(listes, urls_listes)
  
}

#On récupère les tableaux de résultats qu'on stocke dans une seule liste
tables = vector()
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
  tables = rbind(tables, table)
}

#########################################################################
#La partie qui suit est du nettoyage de données. Elle pourrait très bien 
#être effectuée dans OpenRefine, voire dans Excel. Mais ceci vous fera gagner du temps.
#########################################################################



#On met les poucentages sous forme de nombres
tables$pourcent_liste = as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables$pourcent_liste))

#on élimine les mots "Commune de" et on efface les éventuels espaces en trop
tables$commune = gsub("Commune de ", "", trimws(tables$commune))

#on enlève le numéro devant le nom de parti et on efface les éventuels espaces en trop
tables$parti = gsub("^\\d+ ", "", trimws(tables$parti))

#on crée une colonne "liste" en concaténant (collant) nom de commune et de parti
tables$liste = paste(tables$commune, table$parti, sep="-")

# Stop the clock : affichera dans la console le temps d'execution du script 
#(environ 15 minutes pour le site de test wallon, son serveur étant lent)
Sys.time() - start_time

#On sauvegarde les tables de résultats dans un csv "Excel compatible"
write_excel_csv(tables, "scraping_2018.csv")

