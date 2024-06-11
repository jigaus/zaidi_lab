#read in DF from gdsc
gdsc <- read.table("GDSC2_fitted_dose_response_27Oct23.txt", sep="\t", header=T)

#filter based on high
high <- filter(gdsc, CELL_LINE_NAME %in%  c("A2058", "IGR-37", "IGR-1", "COLO-679", "SK-MEL-5", "SK-MEL-28", "MEL-HO", "SK-MEL-3", "UACC-257"))

high <- high[order(high$DRUG_ID, decreasing = FALSE),]

#filter based on low
low <- filter(gdsc, CELL_LINE_NAME %in% c("RVH-421", "HT-144", "SK-MEL-1", "COLO-800", "COLO-792", "LOXIMVI", "RPMI-7951", "WM-115", "WM793B"))

low <- low[order(low$DRUG_ID, decreasing = FALSE),]

#writing tables
write.table(combine, "calculated_gdsc_ctla4.txt", sep="\t", row.names = F, quote=F)

#math stuff (high)
high_avg <- high %>%
  group_by(DRUG_ID) %>%
  summarize(average = mean(LN_IC50, na.rm = TRUE))

high_med <- high %>%
  group_by(DRUG_ID) %>%
  summarize(median = median(LN_IC50, na.rm = TRUE))

high2 <- merge(high_avg, high_med, by="DRUG_ID")

#math stuff (low)
low_avg <- low %>%
  group_by(DRUG_ID) %>%
  summarize(average = mean(LN_IC50, na.rm = TRUE))

low_med <- low %>%
  group_by(DRUG_ID) %>%
  summarize(median = median(LN_IC50, na.rm = TRUE))

low2 <- merge(low_avg, low_med, by="DRUG_ID")

#ratio?
combine <- merge(high2, low2, by="DRUG_ID")
combine$RATIO_M <- combine$MEDIAN_H/combine$MEDIAN_L

#sign test
binom.test(168, 295, alternative = "two.sided") #successes, total
