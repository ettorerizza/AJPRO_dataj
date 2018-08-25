# Start the clock!
start_time <- Sys.time()

library(rvest)
library(tidyverse)

start_url = "http://bru2012.irisnet.be/fr/com/results/results_start.html"

url_communes =
  start_url %>%
  read_html() %>%
  html_nodes(".normal a") %>%
  html_attr("href") %>%
  paste0("http://bru2012.irisnet.be/fr/com/results/", .)

listes = vector()
for (i in url_communes) {
  urls = i %>%
    read_html() %>%
    html_nodes(xpath = "//a[contains(@href,'../preferred/preferred_CGM')]") %>%
    html_attr("href") %>%
    gsub("../preferred/", "/preferred/", .) %>%
    paste0("http://bru2012.irisnet.be/fr/com", .)
  
  listes = c(listes, urls)
  
}

tables = vector()
for (i in listes) {
  html = i %>%
    read_html()
  
  table = html %>%
    html_node("#wrn_background_Id") %>%
    html_table(header = FALSE,
               fill = TRUE,
               dec = ",")
  
  #on crée trois colonnes avec le nom de la commune, le nom de la liste et l'URL de la page
  table$commune = html %>% html_node(".uppercaseb") %>% html_text()
  table$parti = html %>% html_node(".subtitle") %>% html_text()
  table$lien = i
  tables = rbind(tables, table)
}

tables = tables %>% drop_na(X2) %>% select(X2:X10, commune:lien)

colnames(tables) = c(
  "place_liste",
  "nom",
  "voix",
  "pourcent_liste",
  "voix_devolues",
  "voix_apres_devolution",
  "voix_restantes",
  "position_elu",
  "position_suppleance",
  "commune",
  "parti",
  "lien"
)

tables$pourcent_liste = as.numeric(gsub("^([0-9]+),?([0-9]+)?%", "\\1.\\2", tables$pourcent_liste))

tables$commune = gsub("Commune de ", "", trimws(tables$commune))

# Stop the clock
Sys.time() - start_time

write_csv(tables, "scraping_bruxelles.csv")
