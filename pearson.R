#READ IN
gdsc <- read.table("gdsc_drugcell_all.txt", sep="\t", header=T)
rpkm <- read.table("cell_line_RPKM.txt", sep="\t", header=T)
cells <- as.list(drug_ids_with_all_cell_lines)

gdsc <- gdsc[gdsc$DRUG_ID %in% cells, ] #filtering
gdsc <- gdsc[order(gdsc$DRUG_ID, decreasing = FALSE),]

write.table(gdsc, "gdsc_drugcell_all.txt", sep="\t", row.names = F, quote=F)

#PEARSON
library(ggpubr)

#merge by cell line 
merged_df <- merge(gdsc, rpkm, by = "CELL_LINE_NAME")

#split by grouped drug id
grouped_df <- split(merged_df, merged_df$DRUG_ID)

#empty table
pear <- data.frame(DRUG_ID = unique(gdsc$DRUG_ID), pear = numeric(length(unique(gdsc$DRUG_ID))))
rownames(pear) <- as.character(pear$DRUG_ID)
pear$DRUG_ID <- NULL

#loop
for (group_id in unique(gdsc$DRUG_ID)) {
 
   #extract ln_ic50 and rpkm values for the current group
  ln_ic50 <- grouped_df[[as.character(group_id)]]$LN_IC50
  rpkm <- grouped_df[[as.character(group_id)]]$RPKM
  
  #perform correlation test
  cor_test_result <- cor.test(ln_ic50, rpkm, method="pearson")
  
  #store p-value in the table
  pear[as.character(group_id), ] <- cor_test_result$estimate
}


pear$row_names <- row.names(pear)
pear <- cbind(row_names = row.names(pear), pear)
pear <- subset(pear, select = -c(ok) )

colnames(pear)[1] <- "DRUG_ID"

#PLOT
drug <- filter(merged_df, DRUG_ID %in% c("1060"))

?ggscatter


ggscatter(drug, x = "RPKM", y = "LN_IC50", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "RPKM", ylab = "LN IC50")

