library(tidyverse)

#On réimporte les données sauvegardées
load("data.RData")

################################
#
#2° ANALYSE
#
################################

#Dans quelles communes le Vlaams belang a-t-il connu sa plus forte progression en % (10 premières) ?
VB_top10 <- 
  tables %>% 
  filter(liste == "VLAAMS BELANG") %>% 
  arrange(desc(evolution_en_pourcent)) %>% 
  head(10)

View(VB_top10)

#Où le MR a-t-il chuté le plus en % ?
MR_flop10 <- 
  tables %>% 
  filter(liste == "MR") %>% 
  arrange(evolution_en_pourcent) %>% 
  head(10)

View(MR_flop10)

#Quel parti a progressé le plus dans les 10 communes où le MR a fait ses plus gros flops ?

best_progress_in_flop_MR <- 
  tables %>% 
  filter(commune %in% MR_flop10$commune) %>% 
  group_by(commune) %>% 
  top_n(1, evolution_en_pourcent)

View(best_progress_in_flop_MR)

#etc.