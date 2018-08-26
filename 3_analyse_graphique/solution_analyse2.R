library(dplyr)
library(readr)
library(ggplot2)

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

#calculer la position sur la liste du dernier du groupe de tête d'élus par liste(sur base du premier non elu)
#calculer la différence entre cette valeur et la position sur la liste des élus
#on pourrait affiner en calculant la place du "premier non élu non suivi d'un élu", mais KISS
result = 
  data_filtered %>% 
       group_by(liste) %>% 
       mutate(last_elu = place_liste[which(is.na(position_elu))[1]] - 1, # trouvé sur SO
              diff_avec_last=place_liste-last_elu) %>% 
       filter(elu=="oui") %>% 
  #question : doit-on privilégier la différence entre la place-place_elu ou l'autre ?
       arrange(desc(place_positionelu), desc(diff_avec_last)) %>% 
  filter(diff_avec_last > 20)

View(result)

#on sauvegarde les résultats
write_csv(result, "resultats.csv")

#Ne garder que le top de chaque commune ?
# top_commune = 
#   result %>%  
#   ungroup() %>% 
#   group_by(commune) %>% 
#   arrange(desc(place_positionelu)) %>% 
#   slice(c(1,n())) #pourquoi 560 résultats au lieu de 281 ? ex aequos ?
# 
# View(top_commune)

#un petit tableau par parti
table_partis_province = 
  result %>%
  group_by(parti_propre,province) %>%
  summarise(nombre=n()) %>% 
  arrange(desc(nombre)) %>% 
  head(10)

View(table_partis_province)

#un petit graphique
ggplot(table_partis_province, 
       aes(x=reorder(parti_propre, -nombre), y = nombre, fill=province, label=nombre)) + 
  geom_bar(stat="identity") +
  theme_minimal()  +
  labs(x = "Parti", y = "Nombre") +
  geom_text(size = 3, position = position_stack(vjust = 0.5))


