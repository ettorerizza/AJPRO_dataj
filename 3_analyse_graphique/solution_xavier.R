#on importe les packages nécessaires
library(dplyr) #à installer d'abord si ce n'est fait
library(readr) #à installer d'abord si ce n'est fait

#ne faite pas attention à ces lignes de code
#elles servent à définir automatiquement votre
#répertoire de travail dans le bon dossier 
#ce qui vous évitera des chipotages
set_wd <- function() {
  library(rstudioapi) # à installer au besoin
  current_path <- getActiveDocumentContext()$path 
  setwd(dirname(current_path ))
  print( getwd() )
}
set_wd()



#On importe et visualise le fichier csv issu des scraping et nettoyé dans Refine
data = read_csv("scrapings_wallonie_bruxelles.csv")

View(data)

#On crée une copie du dataframe "data" sans les trois derniers de chaque liste
#(Chercher une solution plus élégante que trois filter)
data_filtered = 
  data %>% 
  group_by(liste) %>% 
  filter(place_liste != max(place_liste)) %>% 
  filter(place_liste != max(place_liste)) %>% 
  filter(place_liste != max(place_liste))

View(data_filtered)



#calculer le nombre d'élus de chaque liste (le nombre de "oui" dans la colonne "elu")
#calculer la différence entre la place de chacun sur la liste et ce nombre
#ne garder que ceux dont la différence est positive.
#on classe ensuite par colonnes "position_moins_elus" et "place_positionelu"

result = 
  data_filtered %>% 
       group_by(liste) %>% 
       filter(elu=="oui") %>% 
       add_tally() %>% 
       mutate(position_moins_elus = place_liste - n) %>% 
       filter(position_moins_elus > 0) %>% 
       arrange(desc(place_positionelu), desc(position_moins_elus))

  
View(result)

#on sauvegarde les résultats
write_csv(result, "resultats.csv")