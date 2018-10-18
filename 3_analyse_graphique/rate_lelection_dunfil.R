library(dplyr)
library(readr)
library(ggplot2)


#On importe et visualise le fichier csv issu des scraping
data <- read_csv("GitHub/AJPRO_dataj/1_scraping/code/scraping_2018_wallonie_bruxelles_communales.csv")
View(data)

#ajouter une colonne avec le nombre de voix du dernier élu
#calculer la différence entre cette colonne et le nombre de voix des premiers suppléants
rate_lelection = 
  data %>% 
  group_by(liste) %>% 
  mutate(voix_last_elu = min(Votes[which(elu=="oui")]),
         difference = Votes - voix_last_elu) %>% 
  filter(elu=="non", difference<=0 & difference >=-3) 



View(rate_lelection)

#on sauvegarde les résultats
write_excel_csv(rate_lelection, "rate_lelection.csv")