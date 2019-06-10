#Denial Project, 03/28/2019
#Nick Cagliuso
#The purpose of this project is to measure how often denials occur among Buyers over the 2018-2019 Fiscal Year

library(readxl)
library(dplyr)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(kableExtra)
library(tidyr)
setwd("C:/Users/NCAGLIUSO/Desktop/Dan Z")
SLT_DENIAL_PUBLIC <- read_excel("C:/Users/NCAGLIUSO/Desktop/Dan Z/SLT_DENIAL_PUBLIC.xlsx")
Total_POs <- read_excel("C:/Users/NCAGLIUSO/Desktop/Dan Z/REQ_TO_PO_SPILT_PO_SIDE_DanZ.xlsx")

SLT_DENIAL_PUBLIC$Date_Time <- as_datetime(SLT_DENIAL_PUBLIC$Date_Time)
#Date_Time = Denial Date

SLT_DENIAL_PUBLIC$Dispatch_DTTM <- as_datetime(SLT_DENIAL_PUBLIC$Dispatch_DTTM)
#Dispatch_DTTM = Last date the requisition was changed

SLT_DENIAL_PUBLIC <- mutate(SLT_DENIAL_PUBLIC, Created_Month = SLT_DENIAL_PUBLIC$Date_Time %>% month())
SLT_DENIAL_PUBLIC$Created_Month <- month.abb[SLT_DENIAL_PUBLIC$Created_Month]

month_levels <- c("Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar")
#MBTA Fiscal Year runs from July through June, so months need to be put in that order
#April, May, and June are included before July because some reqs dispatched during FY were denied before it began

x1 <- c(SLT_DENIAL_PUBLIC$Created_Month)
y1 <- factor(x1, levels = month_levels)
SLT_DENIAL_PUBLIC <- with(SLT_DENIAL_PUBLIC, SLT_DENIAL_PUBLIC[order(y1),])
SLT_DENIAL_PUBLIC <- SLT_DENIAL_PUBLIC %>% filter(.data$Date_Time >= "2018-04-01 08:00:00")
sourcing_execs <- (Buyer = c("AFLYNN", "TDIONNE","EWELSH", "RWEINER", "JDELALLA","KHALL","JMOYNIHAN"))
inventory_buyers <- (Buyer = c("AKNOBEL", "DMARTINOS", "KLOVE", "PHONG", "TSULLIVAN1", "NSEQUEA", "DWELCH"))
non_inventory_buyers <- (Buyer = c("CFRANCIS", "JKIDD", "JLEBBOSSIERE", "TTOUSSAINT","IATHERTON","JMIELE"))

SLT_DENIAL_PUBLIC <- SLT_DENIAL_PUBLIC %>% mutate(Category = case_when(
  .data$Buyer %in% sourcing_execs ~ "SE",
  .data$Buyer %in% inventory_buyers ~ "INV",
  .data$Buyer %in% non_inventory_buyers ~ "NINV"
))

Month_Info <- SLT_DENIAL_PUBLIC %>% group_by(SLT_DENIAL_PUBLIC$Created_Month) %>% summarise(cnt = n())
Buyer_Info <- SLT_DENIAL_PUBLIC %>% group_by(SLT_DENIAL_PUBLIC$Buyer) %>% summarise(cnt = n())
#Count of denials by month and by buyer

names(Buyer_Info)[1]<-"Buyer"
names(Month_Info)[1]<-"Month"
a1 <- c(Month_Info$Month)
b1 <- factor(a1, levels = month_levels)
Month_Info <- with(Month_Info, Month_Info[order(b1),])

By_Month_By_Buyer <- SLT_DENIAL_PUBLIC %>% group_by(.data$Buyer, .data$Created_Month, .data$Category) %>% 
summarise(cnt = n())
#Denial count by buyer for each month with Buyer Team added as well

c1 <- c(By_Month_By_Buyer$Created_Month)
d1 <- factor(c1, levels = month_levels)
By_Month_By_Buyer <- with(By_Month_By_Buyer, By_Month_By_Buyer[order (d1),])

Month_Buyer_Table<- By_Month_By_Buyer %>% spread(Created_Month, cnt) %>% mutate(Category = case_when(
  .data$Buyer %in% sourcing_execs ~ "SE",
  .data$Buyer %in% inventory_buyers ~ "INV",
  .data$Buyer %in% non_inventory_buyers ~ "NINV"
))
#Matrix of denial count of each Buyer per month

Buyer_levels <- c("INV", "NINV", "SE")
e1 <- c(Month_Buyer_Table$Category)
f1 <- factor(e1, levels = Buyer_levels)
Month_Buyer_Table <- with(Month_Buyer_Table, Month_Buyer_Table[order(f1),])
Buyer_Sums <- rowSums(Month_Buyer_Table[, c(3:14)], na.rm = TRUE)
Buyer_Sums <- as.data.frame(Buyer_Sums)
Buyer_Sums <- Buyer_Sums %>% mutate(Buyer = Month_Buyer_Table$Buyer)
#Total denial count by Buyer

Month_Buyer_Table <- left_join(Buyer_Sums, Month_Buyer_Table, by = NULL)
#Total denial count by Buyer tacked on

colnames(Month_Buyer_Table)[colnames(Month_Buyer_Table)=="Buyer_Sums"] <- "Buyer_Totals"
Month_Buyer_Table <- Month_Buyer_Table[c("Buyer", "Category", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", 
                                         "Dec", "Jan", "Feb", "Mar", "Buyer_Totals")]
#Months go chronologically left to right

Buyer_Sums <- Buyer_Sums %>% filter(.data$Buyer != "CCHEEK")

Total_POs <- Total_POs %>% distinct(.data$PO_No., .keep_all = TRUE)
Total_Info <- Total_POs %>% group_by(.data$Buyer) %>% summarise(cnt = n())
#Total count of PO's by Buyer

Total_Info <- Total_Info[-c(3, 11, 16, 20, 23), ]
#Specific Buyers removed

Percentage <- left_join(Total_Info, Buyer_Sums)
Percentage <- Percentage[,c(1,3,2)]
colnames(Percentage)[colnames(Percentage)=="Buyer_Sums"] <- "Denial_Count"
colnames(Percentage)[colnames(Percentage)=="cnt"] <- "Total_Count"
Percentage <- Percentage %>% mutate(Denial_Percentage = .data$Denial_Count/.data$Total_Count)
Percentage$Denial_Percentage <- Percentage$Denial_Percentage %>% round(digits = 3)
Percentage <- Percentage %>% mutate(Buyer_Team = case_when(
  .data$Buyer %in% sourcing_execs ~ "SE",
  .data$Buyer %in% inventory_buyers ~ "INV",
  .data$Buyer %in% non_inventory_buyers ~ "NINV"
))
Percentage %>% kable() %>% kable_styling(bootstrap_options = c("striped", "condensed", full_width = F))
#Percentage of PO's that were denied, by Buyer, featuring Buyer Team