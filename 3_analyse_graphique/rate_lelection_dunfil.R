library(dplyr)
library(readr)
library(ggplot2)

#ne faite pas attention à ces lignes de code
#elles servent à définir automatiquement votre
#répertoire de travail dans le bon dossier 
set_wd <- function() {
  library(rstudioapi) # à installer au besoin
  current_path <- getActiveDocumentContext()$path 
  setwd(dirname(current_path ))
  print( getwd() )
}
set_wd()


#On importe et visualise le fichier csv issu des scraping
data = read_csv("scrapings_wallonie_bruxelles.csv")

View(data)


#ajouter une colonne avec le nombre de voix du dernier élu
#calculer la différence entre cette colonne et le nombre de voix des premiers suppléants
rate_lelection = 
  data %>% 
  group_by(liste) %>% 
  mutate(voix_last_elu = min(voix[which(elu=="oui")]),
         difference = voix - voix_last_elu) %>% 
  filter(elu=="non", difference==-1) 



View(rate_lelection)

#on sauvegarde les résultats
write_csv(result, "rate_lelection.csv")