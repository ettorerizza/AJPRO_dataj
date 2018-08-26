library(tidyverse)
library(readr)

#On importe et visualise le fichier csv issu des scraping
data = 
  read_csv("scrapings_wallonie_bruxelles.csv")

View(data)

#1 On crée une copie du dataframe data sans les trois derniers de chaque liste
#(Chercher une solution plus élégante que trois filter)
data_filtered = 
  data %>% 
  group_by(liste) %>% 
  filter(place_liste != max(place_liste)) %>% 
  filter(place_liste != max(place_liste)) %>% 
  filter(place_liste != max(place_liste))

View(data_filtered)

#calculer l'indice du dernier du groupe de tête d'élues'élus par liste(sur base du premier non elu)
#calculer la différente cette valeur et la psoiton sur la liste des élus
result = data_filtered %>% 
       group_by(liste) %>% 
       mutate(last_elu = place_liste[which(is.na(position_elu))[1]] - 1, 
              diff_avec_last=place_liste-last_elu) %>% 
       filter(elu=="oui") %>% 
       arrange(desc(place_positionelu), desc(diff_avec_last))

#Ne garder que le top de chaque commune commune
result_commune = 
  result %>%  
  ungroup() %>% 
  group_by(commune) %>% 
  arrange(desc(place_positionelu)) %>% 
  slice(c(1,n())) #pourquoi 560 résultats au lieu de 281 ? ex aequos ?
