#calcule le nombre de sièges à pourvoir en fonction de la population de la commune 

nombre_sieges <- function(x) {

 if(x<1000){result <- 7}

 if(x>=1000 && x<=1999){result <- 9}

 if(x>=2000 && x<=2999){result <- 11}

 if(x>=3000 && x<=3999){result <- 13}

 if(x>=4000 && x<=4999){result <- 15}

 if(x>=5000 && x<=6999){result <- 17}

 if(x>=7000 && x<=8999){result <- 19}

 if(x>=9000 && x<=11999){result <- 21}

 if(x>=12000 && x<=14999){result <- 23}

 if(x>=15000 && x<=19999){result <- 25}

 if(x>=20000 && x<=24999){result <- 27}

 if(x>=25000 && x<=29999){result <- 29}

 if(x>=30000 && x<=34999){result <- 31}

 if(x>=35000 && x<=39999){result <- 33}

 if(x>=40000 && x<=49999){result <- 35}

 if(x>=50000 && x<=59999){result <- 37}

 if(x>=60000 && x<=69999){result <- 39}

 if(x>=70000 && x<=79999){result <- 41}

 if(x>=80000 && x<=89999){result <- 43}

 if(x>=90000 && x<=99999){result <- 45}

 if(x>=100000 && x<=149999){result <- 47}

 if(x>=150000 && x<=199999){result <- 49}

 if(x>=200000 && x<=249999){result <- 51}

 if(x>=250000 && x<=299999){result <- 53}

 if(x>300000){result <- 55}

 return(result)
 }
 

 