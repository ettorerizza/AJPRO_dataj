library(rvest)
library(dplyr)

#création des urls de départ
main_url <- "https://fr.wikipedia.org/wiki/Décès_en_"
annee <- 2011:2016

urls <- paste0(main_url, annee)
#vecteur vide qui contiendra les urls des pages
liens <- vector()
#récolte des urls des pages
for (url in urls) {
  liens <-
    c(liens,
      url %>% read_html() %>% html_nodes("p~ p+ ul a") %>% html_attr("href"))
}
#transforme les urls relatives en urls absolues
liens <- paste0("https://fr.wikipedia.org", liens)
#boucle principale qui récupérera les tableaux html dans chaque page
tableau <- list()
index <- 1
for (lien in liens) {
  #le try({}) permet de passer outre les erreurs dues à de mauvais liens
  try({
    print(lien)
    table <-
      lien %>% read_html() %>% html_table(fill = TRUE) %>% data.frame()
    #on transforme la colonne Source, inutile, pour y stocker l'URL de la page
    table[, "Source"] <- lien
    #on crée une colonne année en récupérant cette dernière dans l'url de la page
    matches <- regexpr("\\d{4}$", lien)
    table$annee <- lien %>% regmatches(matches, invert = FALSE)
  
    
    #ajoute les dataframes à la liste
    tableau[[index]] <- table
    index <- index + 1
  })
  
  # #on récupère le lien vers la fiche des décédés
  # try({
  # links <- lien %>% read_html() %>% html_nodes( css="td:nth-child(2) a:nth-child(1)") %>% html_attr('href')
  # 
  # urls <- paste0("https://fr.wikipedia.org", links)
  # 
  # table['liens'] <- urls})
}

#fusionne la liste de dataframes en un seul
tableau_complet <- do.call("rbind", tableau)
#écriture du fichier
#write.csv(tableau_complet, "tableau_complet.csv", fileEncoding = "UTF-8")