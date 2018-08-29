calcul_sieges <- function (parties, votes, n_seats, method) 
{
  if (length(unique(parties)) != length(parties)) {
    stop("every party name must be unique")
  }
  if (n_seats < 1 | floor(n_seats) != ceiling(n_seats)) {
    stop("n_seats must be an integer greater than 0")
  }
  s <- 1:n_seats
  if (method == "dhondt") {
    divisores = s
  }
  else if (method == "webster") {
    divisores <- 2 * s - 1
  }
  else if (method == "danish") {
    divisores <- 3 * s - 2
  }
  else if (method == "imperiali") {
    divisores <- s + 1
  }
  else if (method == "imperiali_belge") {
    divisores <- (s + 1)/2
  }
  else if (method == "hill-huntington") {
    divisores <- sqrt(s * (s + 1))
  }
  else if (method == "dean") {
    divisores <- (2 * s) * (s + 1)/(2 * s + 1)
  }
  else if (method == "mod-saint-lague") {
    divisores <- (10 * s - 5)/7
    divisores[1] <- 1
  }
  else if (method == "equal-proportions") {
    divisores <- sqrt(s * (s - 1))
  }
  else if (method == "adams") {
    divisores <- s - 1
  }
  else {
    stop("No implemented method.")
  }
  votacion <- tibble(PARTY = as.character(parties), VOTES = votes)
  cocientes <- as_tibble(expand.grid(PARTY = parties, DIVISOR = divisores)) %>% 
    mutate(PARTY = as.character(PARTY)) %>% left_join(votacion, 
                                                      by = "PARTY") %>% mutate(COCIENTES = VOTES/DIVISOR) %>% 
    mutate(ORDEN = rank(-COCIENTES, ties.method = "max"))
  seats <- cocientes %>% arrange(ORDEN) %>% filter(ORDEN <= 
                                                     length(divisores)) %>% group_by(PARTY) %>% summarise(SEATS = n())
  if (sum(seats$SEATS) != n_seats) {
    empates <- cocientes %>% filter(ORDEN > length(divisores)) %>% 
      mutate(ORDEN_EMPATES = rank(ORDEN, ties.method = "min")) %>% 
      filter(ORDEN_EMPATES == 1)
    print(paste("IMPORTANT: ", sum(seats$SEATS), "seats had been allocated. There is(are)", 
                n_seats - sum(seats$SEATS), "seat(s) with tie."))
    print(c("Parties in tie:", empates$PARTY))
  }
  seats <- votacion %>% left_join(seats, by = "PARTY") %>% 
    mutate(SEATS = ifelse(is.na(SEATS), 0L, as.integer(SEATS)))
  invisible(as.vector(seats$SEATS))
}
