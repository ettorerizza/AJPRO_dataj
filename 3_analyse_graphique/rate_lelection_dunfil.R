library(dplyr)
library(readr)
library(ggplot2)


#On importe et visualise le fichier csv issu des scraping
library(readr)
data <- read_csv("C:/Users/ettor/Desktop/scraping_2018_wallonie_bruxelles_communales.csv")
View(scraping_2018_wallonie_bruxelles_communales)

#ajouter une colonne avec le nombre de voix du dernier élu
#calculer la différence entre cette colonne et le nombre de voix des premiers suppléants
rate_lelection = 
  data %>% 
  group_by(liste) %>% 
  mutate(voix_last_elu = min(Votes[which(elu=="oui")]),
         difference = Votes - voix_last_elu) %>% 
  filter(elu=="non", difference==0) 



View(rate_lelection)

#on sauvegarde les résultats
write_csv(result, "rate_lelection.csv")