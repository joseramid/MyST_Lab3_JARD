# -- Borrar todos los elementos del environment
rm(list=ls())
mdir <- getwd()


#PiP por covencionalidad va a ser .0001, en el cambio dolar euro
#Se restan el precio de cierre, al precio de apertura, y lo multiplicas por el PiP.
#esta diferencia, se llama PiP.


# -- Establecer el sistema de medicion de la computadora
Sys.setlocale(category = "LC_ALL", locale = "")

# -- Huso horario
Sys.setenv(tz="America/Monterrey", TZ="America/Monterrey")
options(tz="America/Monterrey", TZ="America/Monterrey")

# -- Cargar y/o instalar en automatico paquetes a utilizar -- #

pkg <- c("base","downloader","dplyr","fBasics","forecast","grid",
         "gridExtra","httr","jsonlite","lmtest","lubridate","moments",
         "matrixStats", "PerformanceAnalytics","plyr","quantmod",
         "reshape2","RCurl","RMySQL", "stats","scales","tseries",
         "TTR","TSA","XML","xts","zoo")

inst <- pkg %in% installed.packages()
if(length(pkg[!inst]) > 0) install.packages(pkg[!inst])
instpackages <- lapply(pkg, library, character.only=TRUE)

# -- Cargar archivos desde GitHub -- #

RawGitHub <- "https://raw.githubusercontent.com/IFFranciscoME/"
ROandaAPI <- paste(RawGitHub,"ROandaAPI/master/ROandaAPI.R",sep="")
downloader::source_url(ROandaAPI,prompt=FALSE,quiet=TRUE)

# -- Parametros para usar API-OANDA

# Tipo de cuenta practice/live
OA_At <- "practice"
# ID de cuenta
OA_Ai <- 1742531
# Token para llamadas a API
OA_Ak <- "ada4a61b0d5bc0e5939365e01450b614-4121f84f01ad78942c46fc3ac777baa6" 
# Hora a la que se considera "Fin del dia"
OA_Da <- 17
# Uso horario
OA_Ta <- "America/Mexico_City"
# Instrumento
OA_In <- "EUR_USD"
# Granularidad o periodicidad de los precios H4 = Cada 4 horas
# S5, S10, S30, M1, 
OA_Pr <- "H4" #esto es lo unico que le puedes cambiarle
# Multiplicador de precios para convertir a PIPS
MultPip_MT1 <- 10000

Precios_Oanda <- HisPrices(AccountType = OA_At, Granularity = OA_Pr,
                           DayAlign = OA_Da, TimeAlign = OA_Ta, Token = OA_Ak,
                           Instrument = OA_In, 
                           Start = NULL, End = NULL, Count = 900)

EMA <- EMA(Precios_Oanda$Close)

plot.ts(Precios_Oanda$Close)
plot.ts(EMA)

par(new=T)
plot.ts(Precios_Oanda$Close)
plot.ts(EMA)

EMA21 <- monthlyReturn(ts(EMA))

lista <- list()

for(i in 10:length(EMA)){ #porque los 10 primeros son NaN
  
  if(Precios_Oanda$Close[i] > EMA[i])lista[i] <- 'Vende'
  else lista[i] <- 'Conserva'
}

