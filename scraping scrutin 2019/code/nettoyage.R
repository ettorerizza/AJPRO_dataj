#On réimporte les données sauvegardées
load("data.RData")

#On vérifie si toutes les communes y sont. Il faut 581 codes INS différents
length(unique(tables$INS))

#Le cas échéant, on regarde lesquelles manquent
#View(anti_join(communes, tables, by="INS"))

################################
#
#1° NETTOYAGE
#
################################

#On enlève les listes sans numéro (absents des élections 2019)
tables <- tables %>% drop_na(numero)

#On met les pourcentages sous forme de nombres
tables$pourcent_2019 <- 
  as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables$pourcent_2019))
tables$pourcent_2014 <- 
  as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables$pourcent_2014))
tables$evolution_en_pourcent  <- 
  as.numeric(gsub("^(\\W?[0-9]+),?([0-9]+)?%", "\\1.\\2", tables$evolution_en_pourcent))

#On enlève les . dans les résultats 2019 et 2014 - sont considérés comme une virgule décimale en anglais
tables$resultat_2019 <- 
  as.numeric(gsub("\\.", "", tables$resultat_2019))
tables$resultat_2014 <- 
  as.numeric(gsub("\\.", "", tables$resultat_2014))

#Coup d'oeil
View(tables)

#sauvegarde des variables
save.image("data.RData")

#Ecriture en CSV
readr::write_csv(tables, "../scraping_communes_federales_2019_cleaned.csv")




