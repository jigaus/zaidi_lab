# Combine cell line information from both data frames
combined_cell_lines <- rbind(high, low)

# Get unique cell lines
unique_cell_lines <- unique(gdsc$CELL_LINE_NAME)

# Split combined data frame by drug ID
split_data <- split(gdsc, gdsc$DRUG_ID)

# Initialize a vector to store drug ID groups with all cell lines
drug_ids_with_all_cell_lines <- character(0)

# Loop through each drug ID group
for (DRUG_ID in names(split_data)) {
  # Get cell lines for the current drug ID group
  cell_lines <- split_data[[DRUG_ID]]$CELL_LINE_NAME
  
  # Check if the current drug ID group contains all unique cell lines
  if (all(unique_cell_lines %in% cell_lines)) {
    drug_ids_with_all_cell_lines <- c(drug_ids_with_all_cell_lines, DRUG_ID)
  }
}

# Output the drug ID groups with all cell lines
drug_ids_with_all_cell_lines

