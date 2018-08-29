
# exemple avec Mons : http://electionslocales.wallonie.be/2012/fr/com/results/results_tab_CGM53053.html

PRcalc::PRcalc(nseat = 45, vote = c("Ecolo" = 4490, 
                                      "PS" = 28066, 
                                      "cdH"=4437, 
                                      "MR" = 9106, 
                                      "PTB+" = 1835, 
                                      "Citoyens" = 2197, 
                                      "pa" = 748), 
                 method = "imperiali")

result <- electoral::seats_ha(parties = c("Ecolo", "PS", "cdH", "MR", "PTB+", "Citoyens", "PA"),
         votes = c(4490, 28066, 4437, 9106, 1835, 2197, 748),
         n_seats = 45,
         method = "imperiali")



########################################################################################

library(dplyr)
source('C:/Users/ettor/Desktop/fonction_calcul_sieges.R')
library(readr)


parti <- c("Ecolo", "PS", "cdH", "MR", "PTB+", "Citoyens", "PA")
votes <- c(4490, 28066, 4437, 9106, 1835, 2197, 748)
sieges_mons <- 45

resultats_mons <- data.frame(parti, votes)

# attention, la methode Imperiali du package electoral ne semble pas exactement la même qu'en belgique, où l'on divise par 1, 1.5,2,2.5,etc. aka (s+1)/2 et non s+1 : 
# jeter un oeil au package sciencepo et à sa fonction highestaverages: help(package="SciencesPo")
resultats_mons  <- 
  resultats_mons %>% 
  mutate(sieges = calcul_sieges(parties = parti, 
                                votes = votes, 
                                n_seats = sieges_mons, 
                                method = "imperiali_belge"))

resultats_mons$perc_votes <- round(resultats_mons$votes / sum(resultats_mons$votes) * 100, digits=2)
resultats_mons$perc_sieges <- round(resultats_mons$sieges / sum(resultats_mons$sieges) * 100, digits=2)
resultats_mons$votes_sieges_ratio <- round(resultats_mons$perc_sieges / resultats_mons$perc_votes, digits = 2)

write_csv(resultats_mons, "../Desktop/resultats_mons.csv")
