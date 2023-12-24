rm(list =ls())
library(reshape2)
library(tidyverse)
library(readxl)
library(stringr)

setwd("C:/Users/Juan/Desktop/Programación/Proyectos/Data Analysis/Actividad Económica")


# Limpieza de la base de datos --------------------------------------------

ISE <- read_excel("raw_data/ISE.xlsx", sheet = "Cuadro 1",
                  range = "A44:HS57", col_name = TRUE)
ISE <- ISE[,-c(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)] %>% 
  dplyr::rename(concepto = Concepto)

ISE$id <- c(1:13)

# Tratamiento de la base de datos -----------------------------------------
ISE_transformada <- ISE %>%
  gather(periodo, var_ISE, -c("id", "concepto"))


ISE_transformada$mes <- substr(ISE_transformada$periodo, 7, 8)
ISE_transformada$año <- substr(ISE_transformada$periodo, 3, 6)

ISE_transformada <- ISE_transformada %>%
  select(c("id", "concepto", "mes", "año", "var_ISE"))

ISE_transformada$mes <- str_pad(ISE_transformada$mes, width = 2, side = "left", pad = "0")
ISE_transformada$periodo <- paste(ISE_transformada$año, ISE_transformada$mes, "01", sep = "-") 

ISE_transformada <- ISE_transformada %>% 
  mutate(periodo = as.Date(periodo, format = "%Y-%m-%d"))

# Graficando series de tiempo ---------------------------------------------

ISE_total <- ISE_transformada %>% 
  filter(id == 13)

ggplot(ISE_total, mapping = aes(x = periodo, y = var_ISE),
       xlab = "Fecha", ylab = "Variación (%)") + 
  geom_line(colour = "darkblue") +
  geom_hline(yintercept = 0, colour = "black", lty = 2) +
  labs(x = "Fecha", y = "Variación (%)")
