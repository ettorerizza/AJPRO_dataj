# Start the clock! Pour mesurer (par curiosité) le temps que prendra l'execution de ce script
start_time <- Sys.time()

#CONSEIL : avant d'executer l'ensemble du code (raccourci : CTRL+a (pour tout sélectionner)
#, puis CTRL+shift+enter), essayez d'abord d'executer chaque étape dans l'ordre 
#(selectionnez une partie du code, CTRL+shif+enter). Cela vous permettra de mieux 
#comprendre son fonctionnement et d'identifier les éventuels bugs

#étape 1 : On importe les trois packages nécessaires
#cette fonction installera automatiquement les packages au besoin
usePackage <- function(p) 
{
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

usePackage("rvest") #le package de scraping
usePackage("tidyverse") #contient tout ce qu'il faut pour manipuler les données
usePackage("rstudioapi") #ne sert que pour la fonction setwd()


#étape 2 : Les six lignes de code suivantes
# servent juste à définir automatiquement votre
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

#étape 3 : ATTENTION, ces deux URL devront être modifiées le 14 octobre !

#URL de la page contenant les liens vers chaque commune (page de départ)
start_url = "https://rwa-ma5.martineproject.be/fr/election?el=CG"

#Url de base du site (sera différente pour la Wallonie et Bruxelles)
base_url = "https://rwa-ma5.martineproject.be"

#####################################################################


#étape 4 : On récupère les urls des communes
url_communes =
  start_url %>%
  read_html() %>%
  #le sélecteur CSS "#block-blockelectionstart a" a été retrouvé (après un peu de chipo...)
  #grâce au selector gadget de Chrome
  html_nodes("#block-blockelectionstart a") %>%
  html_attr("href") %>%
  paste0(base_url, .)

#étape 5 : On récupère les URLs des listes électorales de chaque commune
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

#étape 6 : On récupère les tableaux de résultats qu'on stocke dans une seule liste
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
#étapes 7 : Les opérations qui suivent sont du nettoyage de données. Elles pourraient très bien 
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
#(environ 15 minutes pour le site de test wallon, son serveur étant lent)
Sys.time() - start_time



#étape 8 : On sauvegarde les résultats dans un csv "Excel compatible"
write_excel_csv(tables_completes, "scraping_2018_test.csv")

