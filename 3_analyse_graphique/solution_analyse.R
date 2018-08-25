library(tidyverse)
library(readr)

#On importe et visualise le fichier csv issu des scraping
data = 
  read_csv("C:/Users/ettor/Desktop/AJPRO_dataj/3_analyse_graphique/scrapings_wallonie_bruxelles.csv")

View(data)

#1 On crée une copie du dataframe data sans les trois derniers de chaque liste
#Chercher une solution plus élégante que trois filter
data_filtered = 
  data %>% 
  group_by(liste) %>% 
  filter(place_liste != max(place_liste)) %>% 
  filter(place_liste != max(place_liste)) %>% 
  filter(place_liste != max(place_liste))
  

#2 On calcule la probabilité d'être élu en fonction de chaque place
probabilite_selon_place = table(data_filtered$place_liste, data_filtered$elu) %>% 
  as.data.frame.matrix() %>% 
  mutate(total = non + oui, pourcent = (oui/total)*100) %>% 
  rowid_to_column("place_liste")

View(probabilite_selon_place)

#3 on joint data_filtered et probabilité en ne gardant que les élus
#4 on trie place_positionelu ascendant et pourcent descendant 
result =
  data_filtered %>% 
  filter(elu=="oui") %>% 
  left_join(probabilite_selon_place ) %>% 
  arrange(pourcent, desc(place_positionelu), pourcent_liste) %>% 
  filter(pourcent < 16)

View(result)

#on sauvegarde dans un fichier csv
write_csv(result, "resultats.csv")


# exemple de graphique barchart avec ggplot2
ggplot(data = result) +
  aes(x = Province, fill=Province) +
  geom_bar() +
  theme_minimal()


